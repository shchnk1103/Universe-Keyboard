"""Host-only fake-API and decoder/format preflight. No simulator, no inferior."""
import datetime, hashlib, json, os, struct, subprocess, sys, time, types
from pathlib import Path

ROOT = Path('/private/tmp/ukey-host-activation-fix-owner-export-20261006')
FAKE_ROOT = ROOT / 'host-fake'
LIVE_PRODUCTS = (
    'callback.json', 'callback-stage.json', 'callback-private.json',
    'owner-args.json', 'owner-buffer.bin',
)
sys.path.insert(0, str(ROOT))
results = []

# Preflight must not unlink live evidence. If live products exist, stop.
live_present = [name for name in LIVE_PRODUCTS if (ROOT / name).exists()]
if live_present:
    fail = {
        'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'all_pass': False,
        'reason': 'live_products_present_preflight_refuses_unlink',
        'live_present': live_present,
    }
    print(json.dumps(fail, ensure_ascii=False, indent=2))
    (ROOT / 'e0-correction-preflight-results.json').write_text(
        json.dumps(fail, indent=2) + '\n')
    sys.exit(4)

FAKE_ROOT.mkdir(mode=0o700, exist_ok=True)


class SBError:
    def __init__(self):
        self._fail = False
        self._msg = ''
    def Fail(self):
        return self._fail
    def fail(self, msg='fail'):
        self._fail = True
        self._msg = msg

class Value:
    def __init__(self, valid=True, unsigned=0, children=None, fail=False):
        self._valid = valid
        self._unsigned = unsigned
        self._children = children or {}
        self._fail = fail
    def IsValid(self):
        return self._valid
    def GetNonSyntheticValue(self):
        return self
    def GetChildMemberWithName(self, name, *_):
        return self._children.get(name, Value(valid=False))
    def GetValueAsUnsigned(self, error, default=0):
        if self._fail:
            error.fail('unsigned')
            return default
        return self._unsigned

class Symbol:
    def __init__(self, name, valid=True):
        self._name = name
        self._valid = valid
    def IsValid(self):
        return self._valid
    def GetMangledName(self):
        return self._name

class Address:
    def __init__(self, pc, uuid):
        self._pc = pc
        self._uuid = uuid
    def GetLoadAddress(self, target):
        return self._pc
    def GetModule(self):
        return Module(self._uuid)

class Module:
    def __init__(self, uuid):
        self._uuid = uuid
    def GetUUIDString(self):
        return self._uuid

class Breakpoint:
    def __init__(self, bid, loc):
        self._id = bid
        self._loc = loc
    def GetID(self):
        return self._id

class BPLoc:
    def __init__(self, bid=1, loc=1, pc=0x1000, uuid='4B207746-89A7-321F-83C4-91477259BB26'):
        self._bp = Breakpoint(bid, loc)
        self._id = loc
        self._addr = Address(pc, uuid)
    def GetBreakpoint(self):
        return self._bp
    def GetID(self):
        return self._id
    def GetAddress(self):
        return self._addr

class Frame:
    def __init__(self, process, thread, fid=0, pc=0x1000, uuid='4B207746-89A7-321F-83C4-91477259BB26',
                 mangled='$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF', variables=None):
        self._process = process
        self._thread = thread
        self._fid = fid
        self._pc = pc
        self._uuid = uuid
        self._mangled = mangled
        self._variables = variables or {}
    def GetThread(self):
        return self._thread
    def GetFrameID(self):
        return self._fid
    def GetPC(self):
        return self._pc
    def GetModule(self):
        return Module(self._uuid)
    def GetSymbol(self):
        return Symbol(self._mangled)
    def GetFunction(self):
        return Symbol(self._mangled)
    def GetFunctionName(self):
        return self._mangled
    def FindVariable(self, name, *_):
        return self._variables.get(name, Value(valid=False))
    def IsValid(self):
        return True

class Thread:
    def __init__(self, process, tid=7, reason=3, data=(1, 1), frames=None):
        self._process = process
        self._tid = tid
        self._reason = reason
        self._data = list(data)
        self.frames = frames or []
    def GetProcess(self):
        return self._process
    def GetThreadID(self):
        return self._tid
    def GetStopReason(self):
        return self._reason
    def GetStopReasonDataCount(self):
        return len(self._data)
    def GetStopReasonDataAtIndex(self, i):
        return self._data[i]
    def GetFrameAtIndex(self, i):
        if i < len(self.frames):
            return self.frames[i]
        class Invalid:
            def IsValid(self):
                return False
        return Invalid()

class Process:
    def __init__(self, pid=4242, stop_id=2, memory=None, short=False, mem_fail=False):
        self._pid = pid
        self._stop = stop_id
        self.memory = memory or {}
        self.short = short
        self.mem_fail = mem_fail
        self.read_calls = 0
        self.target = object()
    def GetProcessID(self):
        return self._pid
    def GetStopID(self):
        return self._stop
    def GetState(self):
        return 5
    def GetTarget(self):
        return self.target
    def ReadMemory(self, address, count, error):
        self.read_calls += 1
        if self.mem_fail:
            error.fail('sberror')
            return None
        blob = self.memory.get(address, b'\x00' * count)
        if self.short:
            return blob[: max(0, count - 8)]
        return blob[:count]

def make_lldb():
    m = types.ModuleType('lldb')
    m.eNoDynamicValues = 1
    m.eStopReasonBreakpoint = 3
    m.SBError = SBError
    return m

def reset_callback(cb, pid=4242, stop=1):
    FAKE_ROOT.mkdir(mode=0o700, exist_ok=True)
    cb.OUTPUT_ROOT = FAKE_ROOT
    cb.CONFIG = {
        'pid': pid,
        'loaded_uuid': '4B207746-89A7-321F-83C4-91477259BB26',
        'symbol': '$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF',
        'breakpoint_pc': 0x1000,
        'breakpoint_id': 1,
        'location_id': 1,
        'attach_stop_id': stop,
    }
    cb.CONFIG['configure_monotonic_ns'] = time.monotonic_ns()
    cb.HITS = []
    cb.READ_ATTEMPTS = 0
    for name in LIVE_PRODUCTS:
        p = FAKE_ROOT / name
        if p.exists():
            p.unlink()

def public_receipt(cb):
    path = cb.OUTPUT_ROOT / 'callback.json'
    if path.exists():
        return json.loads(path.read_text())
    return {}

def good_vars(addr=0x2000, count=176):
    return {
        'address': Value(children={'_rawValue': Value(unsigned=addr)}),
        'byteCount': Value(children={'_value': Value(unsigned=count)}),
    }

def callers():
    names = [
        '$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF',
        'handleWakeOwnerProbeButton',
        'Array.withUnsafeBytes',
    ]
    class Named(Frame):
        def __init__(self, n):
            self._n = n
        def IsValid(self):
            return True
        def GetFunctionName(self):
            return self._n
    return [Named(n) for n in names]

def run_case(cb, name, process, mutate=None, expect_reads=0, expect_status=None, expect_reason=None):
    reset_callback(cb)
    thread = Thread(process)
    frame0 = Frame(process, thread, variables=good_vars())
    extra = callers()
    extra[0] = frame0
    thread.frames = extra
    frame0._thread = thread
    if mutate:
        mutate(cb, frame0, thread, process)
    bp = BPLoc()
    before = process.read_calls
    cb.export_hit(frame0, bp, {})
    after = process.read_calls
    public = public_receipt(cb)
    row = {
        'case': name,
        'read_calls': after - before,
        'total_read_calls': after,
        'status': public.get('status'),
        'reason': public.get('reason'),
        'read_attempted': public.get('read_attempted'),
        'bytes': public.get('bytes'),
        'pass': (after - before) == expect_reads,
    }
    if expect_status is not None:
        row['pass'] = row['pass'] and public.get('status') == expect_status
    if expect_reason is not None:
        row['pass'] = row['pass'] and public.get('reason') == expect_reason
    results.append(row)
    return row

sys.modules['lldb'] = make_lldb()
import importlib
if 'owner_export_callback' in sys.modules:
    del sys.modules['owner_export_callback']
import owner_export_callback as cb
cb.OUTPUT_ROOT = FAKE_ROOT

blob176 = b'\x11' * 176
proc = lambda **k: Process(memory={0x2000: blob176}, **k)

run_case(cb, 'identity_mismatch_pid', proc(),
         mutate=lambda c,f,t,p: setattr(p, '_pid', 99),
         expect_reads=0, expect_reason='hit_frame_identity_mismatch')

def multi(c, f, t, p):
    c.HITS.append({'status': 'already'})
run_case(cb, 'multiple_hits', proc(), mutate=multi,
         expect_reads=0, expect_reason='multiple_hits')

run_case(cb, 'args_unavailable', proc(),
         mutate=lambda c,f,t,p: setattr(f, '_variables', {}),
         expect_reads=0, expect_reason='static_argument_unavailable')

run_case(cb, 'pointer_zero', proc(),
         mutate=lambda c,f,t,p: setattr(f, '_variables', good_vars(addr=0, count=176)),
         expect_reads=0, expect_reason='invalid_pointer_or_size')

run_case(cb, 'length_oob_low', proc(),
         mutate=lambda c,f,t,p: setattr(f, '_variables', good_vars(count=168)),
         expect_reads=0, expect_reason='invalid_pointer_or_size')

run_case(cb, 'length_oob_high', proc(),
         mutate=lambda c,f,t,p: setattr(f, '_variables', good_vars(count=11360)),
         expect_reads=0, expect_reason='invalid_pointer_or_size')

run_case(cb, 'exact_size_success', proc(),
         expect_reads=1, expect_status='owner_buffer_copied')

run_case(cb, 'short_read_no_retry', Process(memory={0x2000: blob176}, short=True),
         expect_reads=1, expect_reason='read_memory_unavailable')

run_case(cb, 'sberror_no_retry', Process(memory={0x2000: blob176}, mem_fail=True),
         expect_reads=1, expect_reason='read_memory_unavailable')

# output failure after a successful read must not re-read
reset_callback(cb)
p = Process(memory={0x2000: blob176})
thread = Thread(p)
frame0 = Frame(p, thread, variables=good_vars())
extra = callers(); extra[0] = frame0; thread.frames = extra; frame0._thread = thread
real_write = cb._write_public
def boom(receipt):
    raise OSError('disk')
cb._write_public = boom
cb.export_hit(frame0, BPLoc(), {})
cb._write_public = real_write
results.append({
    'case': 'output_fail_no_reread',
    'read_calls': p.read_calls,
    'pass': p.read_calls == 1,
})

def _hit(cb, process):
    thread = Thread(process)
    frame0 = Frame(process, thread, variables=good_vars())
    extra = callers(); extra[0] = frame0; thread.frames = extra; frame0._thread = thread
    cb.export_hit(frame0, BPLoc(), {})

# configure already >120s; a fresh hit still reads. Must not use configure as stop clock.
reset_callback(cb)
cb.CONFIG['configure_monotonic_ns'] = time.monotonic_ns() - 121_000_000_000
p = Process(memory={0x2000: blob176})
_hit(cb, p)
public = public_receipt(cb)
results.append({
    'case': 'configure_old_but_fresh_hit',
    'read_calls': p.read_calls,
    'status': public.get('status'),
    'reason': public.get('reason'),
    'pass': p.read_calls == 1 and public.get('status') == 'owner_buffer_copied',
})

# genuine stop >120s before ReadMemory → 0 reads
reset_callback(cb)
p = Process(memory={0x2000: blob176})
seq = {'n': 0}
real_now = cb.now_ns
t0 = real_now()
def before_read_clock():
    seq['n'] += 1
    if seq['n'] == 1:
        return t0
    return t0 + 121_000_000_000
cb.now_ns = before_read_clock
_hit(cb, p)
cb.now_ns = real_now
public = public_receipt(cb)
results.append({
    'case': 'stop_over_120s_before_read',
    'read_calls': p.read_calls,
    'reason': public.get('reason'),
    'deadline_exceeded': public.get('deadline_exceeded'),
    'pass': p.read_calls == 0 and public.get('reason') == 'stop_deadline_exceeded'
            and public.get('deadline_exceeded') is True,
})

# stop over 120s after ReadMemory → 1 read, unsuccessful, copied products cleaned
reset_callback(cb)
p = Process(memory={0x2000: blob176})
seq = {'n': 0}
t0 = cb.now_ns()
def after_read_clock():
    seq['n'] += 1
    if seq['n'] <= 2:
        return t0
    return t0 + 121_000_000_000
cb.now_ns = after_read_clock
_hit(cb, p)
cb.now_ns = real_now
args_exists = (cb.OUTPUT_ROOT / 'owner-args.json').exists()
bin_exists = (cb.OUTPUT_ROOT / 'owner-buffer.bin').exists()
public = public_receipt(cb)
results.append({
    'case': 'stop_over_120s_after_read',
    'read_calls': p.read_calls,
    'status': public.get('status'),
    'reason': public.get('reason'),
    'args_exists': args_exists,
    'bin_exists': bin_exists,
    'pass': p.read_calls == 1
            and public.get('status') == 'unavailable'
            and public.get('reason') == 'stop_deadline_exceeded'
            and public.get('deadline_exceeded') is True
            and not args_exists and not bin_exists,
})

# decoder fixtures
import decoder
MAGIC = 0x4B574F50524F4245
armed = 1_000_000
expiry = armed + 600_000_000_000

def pack(words):
    return struct.pack('<' + 'Q' * len(words), *words)

header = [MAGIC, 1, 0, 1, 2, 3, 4, armed, expiry, 1, 0]
row = [1, armed, 2, 0, 0, 0, 0, 0, 0, 0, 0]
valid = pack(header + row)
dec_cases = []

def dec(name, raw, expect_error=None):
    try:
        out = decoder.decode(raw)
        ok = expect_error is None
        dec_cases.append({'case': name, 'pass': ok, 'error': None, 'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()})
        return out
    except ValueError as e:
        dec_cases.append({'case': name, 'pass': str(e) == expect_error if expect_error else False, 'error': str(e)})

dec('valid_176', valid)
dec('trailing_bytes', valid + b'\x00' * 8, 'invalid_header')
dec('bad_magic', pack([0xDEAD] + header[1:] + row), 'unsupported_header')
dec('oob_size', b'\x00' * 168, 'invalid_size')
bad_count = list(header); bad_count[9] = 2
dec('count_mismatch', pack(bad_count + row), 'invalid_header')
incomplete = list(header); incomplete[2] = 1
# incomplete=1 is allowed by decoder if other fields ok; completeness flag not a raise.
# Entry: decoder 须核 incomplete. Use overflow without incomplete.
overflow = list(header); overflow[10] = 1
dec('overflow_without_incomplete', pack(overflow + row), 'contradictory_completeness')
ttl = list(header); ttl[8] = armed + 1
dec('bad_ttl', pack(ttl + row), 'invalid_ttl')

# formatter suppression via host lldb, no inferior
cmd = [
    'xcrun', 'lldb', '-b',
    '-o', 'settings show frame-format',
    '-o', 'settings show thread-format',
    '-o', 'command source -s true ' + str(ROOT / 'lldb-format-suppress.lldb'),
    '-o', 'settings show frame-format',
    '-o', 'settings show thread-format',
    '-o', 'settings show stop-disassembly-display',
]
fmt = {'pass': False, 'reason': 'not_run'}
try:
    proc = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    text = proc.stdout + '\n' + proc.stderr
    pty_path = ROOT / 'lldb-format-preflight-correction.pty.txt'
    pty_path.write_text(text)
    os.chmod(pty_path, 0o600)
    banned = ('formatted-arguments', 'name-with-args', 'frame-variables', 'current-frame-vars')
    lines = text.splitlines()
    after = []
    seen_source = False
    for line in lines:
        if 'lldb-format-suppress.lldb' in line or 'Executing commands' in line:
            seen_source = True
        if seen_source:
            after.append(line)
    after_text = '\n'.join(after).lower()
    has_banned = any(b in after_text for b in banned)
    has_pc = 'frame.pc' in after_text or 'pc=' in after_text
    has_reason = 'stop-reason' in after_text or 'stop=' in after_text
    fmt = {
        'lldb_exit': proc.returncode,
        'banned_after': has_banned,
        'has_pc': has_pc,
        'has_reason': has_reason,
        'pass': proc.returncode == 0 and not has_banned and has_pc and has_reason,
        'stdout_sha256': hashlib.sha256(text.encode()).hexdigest(),
        'bytes': len(text.encode()),
    }
    if not fmt['pass']:
        fmt['reason'] = 'cannot_suppress_default_argument_display'
except Exception as exc:
    fmt = {'pass': False, 'reason': type(exc).__name__ + ': ' + str(exc)}

live_after = {name: (ROOT / name).exists() for name in LIVE_PRODUCTS}
live_isolated = not any(live_after.values())
fake_only = all(
    (not (ROOT / name).exists()) or True
    for name in LIVE_PRODUCTS
)

out = {
    'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'kind': 'e0_correction_preflight',
    'fake_output_root': str(FAKE_ROOT),
    'fake_api_cases': results,
    'decoder_cases': dec_cases,
    'formatter': fmt,
    'live_root_products_after': live_after,
    'live_isolated': live_isolated,
    'fake_api_pass': all(r['pass'] for r in results),
    'decoder_pass': all(c['pass'] for c in dec_cases),
    'formatter_pass': fmt.get('pass') is True,
    'live_isolated_pass': live_isolated,
}
out['all_pass'] = (out['fake_api_pass'] and out['decoder_pass']
                   and out['formatter_pass'] and out['live_isolated_pass'])
print(json.dumps(out, ensure_ascii=False, indent=2))
# Do not overwrite original e0-preflight-results.json.
dest = ROOT / 'e0-correction-preflight-results.json'
dest.write_text(json.dumps(out, indent=2) + '\n')
os.chmod(dest, 0o600)
sys.exit(0 if out['all_pass'] else 3)
