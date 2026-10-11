"""Debugger-side owner export at one stop; never imported into the app."""
import datetime
import json
import time
from pathlib import Path
import lldb

ROOT = Path('/private/tmp/ukey-host-activation-fix-owner-export-20261006')
# Live E1 writes here (ROOT). Host preflight rebinds to ROOT/host-fake/.
OUTPUT_ROOT = ROOT
CONFIG = None
HITS = []
READ_ATTEMPTS = 0
STOP_DEADLINE_NS = 120_000_000_000


def now_ns():
    return time.monotonic_ns()


def now_utc():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def configure():
    global CONFIG
    CONFIG = json.loads((ROOT / 'live-binding.json').read_text())
    if CONFIG['pid'] <= 0 or not CONFIG['loaded_uuid']:
        raise ValueError('fresh_live_binding_missing')
    CONFIG['configure_utc'] = now_utc()
    CONFIG['configure_monotonic_ns'] = now_ns()


def _out(name):
    return OUTPUT_ROOT / name


def _write_public(receipt):
    public = {
        'utc': receipt.get('utc'),
        'monotonic_ns': receipt.get('monotonic_ns'),
        'stop_utc': receipt.get('stop_utc'),
        'stop_monotonic_ns': receipt.get('stop_monotonic_ns'),
        'status': receipt.get('status'),
        'reason': receipt.get('reason'),
        'callback_count': receipt.get('callback_count'),
        'identity_match': receipt.get('identity_match'),
        'button_caller': receipt.get('button_caller'),
        'synchronous_borrow_caller': receipt.get('synchronous_borrow_caller'),
        'memory_snapshot_reads': receipt.get('memory_snapshot_reads', 0),
        'read_attempted': receipt.get('read_attempted', 0),
        'bytes': receipt.get('bytes'),
        'sha256': receipt.get('sha256'),
        'target_expressions': 0,
        'unexpected_multiple_hits': receipt.get('unexpected_multiple_hits', False),
        'deadline_exceeded': receipt.get('deadline_exceeded', False),
    }
    _out('callback.json').write_text(json.dumps(public, indent=2) + '\n')


def _persist_stage(receipt):
    """Write stage/time before any ReadMemory."""
    path = _out('callback-stage.json')
    path.write_text(json.dumps(receipt, indent=2) + '\n')
    os_chmod = __import__('os').chmod
    os_chmod(path, 0o600)


def _cleanup_copied_products():
    for name in ('owner-args.json', 'owner-buffer.bin'):
        path = _out(name)
        if path.exists():
            path.unlink()


def _stop_over_deadline(stop_ns, value):
    if now_ns() - stop_ns > STOP_DEADLINE_NS:
        value['deadline_exceeded'] = True
        return True
    return False


def export_hit(frame, bp_loc, internal_dict):
    global READ_ATTEMPTS
    stop_utc = now_utc()
    stop_monotonic_ns = now_ns()
    value = {
        'utc': stop_utc,
        'monotonic_ns': stop_monotonic_ns,
        'stop_utc': stop_utc,
        'stop_monotonic_ns': stop_monotonic_ns,
        'status': 'unavailable',
        'memory_snapshot_reads': 0,
        'read_attempted': READ_ATTEMPTS,
        'target_expressions': 0,
        'argument_reads': 0,
        'deadline_exceeded': False,
    }
    try:
        _persist_stage(dict(value, phase='callback_entered', callback_count=len(HITS) + 1))
        if CONFIG is None:
            raise ValueError('callback_not_configured')
        # 120s freeze is from this hit entry. configure_monotonic_ns is not the anchor.
        if len(HITS) != 0:
            value['unexpected_multiple_hits'] = True
            raise ValueError('multiple_hits')
        thread = frame.GetThread()
        process = thread.GetProcess()
        target = process.GetTarget()
        address = bp_loc.GetAddress()
        symbol = frame.GetSymbol()
        function = frame.GetFunction()
        data_count = thread.GetStopReasonDataCount()
        value.update(
            pid=process.GetProcessID(), thread_id=thread.GetThreadID(),
            frame_id=frame.GetFrameID(), stop_id=process.GetStopID(),
            process_state=process.GetState(), stop_reason=thread.GetStopReason(),
            stop_reason_data=[thread.GetStopReasonDataAtIndex(i)
                              for i in range(min(data_count, 16))],
            stop_reason_data_count=data_count,
            frame_pc=frame.GetPC(), frame_uuid=frame.GetModule().GetUUIDString(),
            symbol_mangled=symbol.GetMangledName() if symbol.IsValid() else None,
            function_mangled=function.GetMangledName() if function.IsValid() else None,
            breakpoint_id=bp_loc.GetBreakpoint().GetID(), location_id=bp_loc.GetID(),
            breakpoint_pc=address.GetLoadAddress(target),
            breakpoint_uuid=address.GetModule().GetUUIDString(),
        )
        callers = []
        for i in range(8):
            caller = thread.GetFrameAtIndex(i)
            if not caller.IsValid():
                break
            callers.append(caller.GetFunctionName() or '')
        value['caller_function_names'] = callers
        pairs = [value['stop_reason_data'][i:i + 2]
                 for i in range(0, len(value['stop_reason_data']), 2)]
        checks = {
            'pid': value['pid'] == CONFIG['pid'],
            'frame0': value['frame_id'] == 0,
            'pc': value['frame_pc'] == value['breakpoint_pc'] == CONFIG['breakpoint_pc'],
            'module': value['frame_uuid'] == value['breakpoint_uuid'] == CONFIG['loaded_uuid'],
            'mangled': CONFIG['symbol'] in [value['symbol_mangled'], value['function_mangled']],
            'breakpoint': value['breakpoint_id'] == CONFIG['breakpoint_id']
                          and value['location_id'] == CONFIG['location_id'],
            'reason': value['stop_reason'] == lldb.eStopReasonBreakpoint
                      and data_count <= 16
                      and [CONFIG['breakpoint_id'], CONFIG['location_id']] in pairs,
            'new_stop': value['stop_id'] > CONFIG['attach_stop_id'],
            'thread': value['thread_id'] != 0,
        }
        value['identity_checks'] = checks
        value['identity_match'] = all(checks.values())
        value['button_caller'] = any('handleWakeOwnerProbeButton' in n for n in callers[1:])
        value['synchronous_borrow_caller'] = any('withUnsafeBytes' in n for n in callers[1:])
        if not value['identity_match'] or not value['button_caller'] or not value['synchronous_borrow_caller']:
            raise ValueError('hit_frame_identity_mismatch')
        addr_var = frame.FindVariable('address', lldb.eNoDynamicValues).GetNonSyntheticValue()
        count_var = frame.FindVariable('byteCount', lldb.eNoDynamicValues).GetNonSyntheticValue()
        pointer = addr_var.GetChildMemberWithName('_rawValue', lldb.eNoDynamicValues)
        length = count_var.GetChildMemberWithName('_value', lldb.eNoDynamicValues)
        value['argument_reads'] = 1
        if not pointer.IsValid() or not length.IsValid():
            raise ValueError('static_argument_unavailable')
        error = lldb.SBError()
        raw_address = pointer.GetValueAsUnsigned(error, 0)
        if error.Fail():
            raise ValueError('static_pointer_unavailable')
        raw_count = length.GetValueAsUnsigned(error, 0)
        if error.Fail():
            raise ValueError('static_count_unavailable')
        if (not raw_address or raw_address % 8
                or not 176 <= raw_count <= 11352
                or raw_count % 8
                or raw_address + raw_count > (1 << 64) - 1):
            raise ValueError('invalid_pointer_or_size')
        private = {
            'utc': value['utc'],
            'address': raw_address,
            'byteCount': raw_count,
            'pid': value['pid'],
            'stop_id': value['stop_id'],
        }
        args_path = _out('owner-args.json')
        args_path.write_text(json.dumps(private) + '\n')
        __import__('os').chmod(args_path, 0o600)
        if READ_ATTEMPTS != 0:
            raise ValueError('read_already_attempted')
        if _stop_over_deadline(stop_monotonic_ns, value):
            _cleanup_copied_products()
            raise ValueError('stop_deadline_exceeded')
        READ_ATTEMPTS = 1
        value['read_attempted'] = 1
        _persist_stage(dict(value, phase='read_attempted_before_memory'))
        mem_error = lldb.SBError()
        blob = process.ReadMemory(raw_address, raw_count, mem_error)
        value['memory_snapshot_reads'] = 1
        if mem_error.Fail() or blob is None or len(blob) != raw_count:
            raise ValueError('read_memory_unavailable')
        bin_path = _out('owner-buffer.bin')
        bin_path.write_bytes(blob)
        __import__('os').chmod(bin_path, 0o600)
        if _stop_over_deadline(stop_monotonic_ns, value):
            _cleanup_copied_products()
            raise ValueError('stop_deadline_exceeded')
        value['bytes'] = len(blob)
        value['sha256'] = __import__('hashlib').sha256(blob).hexdigest()
        value['status'] = 'owner_buffer_copied'
    except ValueError as exc:
        value['reason'] = str(exc)
        if value.get('status') != 'owner_buffer_copied':
            value['status'] = 'unavailable'
    except Exception as exc:
        value['reason'] = type(exc).__name__ + ': ' + str(exc)
        value['status'] = 'unavailable'
    HITS.append(value)
    receipt = dict(value)
    receipt['callback_count'] = len(HITS)
    receipt['hits_status'] = [h.get('status') for h in HITS]
    receipt['unexpected_multiple_hits'] = len(HITS) != 1
    try:
        _write_public(receipt)
        priv = _out('callback-private.json')
        priv.write_text(json.dumps(receipt, indent=2) + '\n')
        __import__('os').chmod(priv, 0o600)
    except Exception as exc:
        print('OWN_EXPORT_HOST_WRITE_FAILED: ' + type(exc).__name__)
    return True
