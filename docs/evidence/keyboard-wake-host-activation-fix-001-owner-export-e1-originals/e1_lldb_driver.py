#!/usr/bin/env python3
"""Persistent LLDB PTY driver for OWN-EXPORT E1. Does not import app code."""
import datetime, json, os, pty, select, subprocess, sys, time
from pathlib import Path

ROOT = Path('/private/tmp/ukey-host-activation-fix-owner-export-20261006')
PTY_LOG = ROOT / 'e1-pty-transcript.txt'
CMD_FIFO = ROOT / 'e1-lldb.cmd'
STATUS = ROOT / 'e1-pre-arm-status.json'
PROMPT = '(lldb) '


def log_write(fh, data):
    fh.write(data)
    fh.flush()


class Lldb:
    def __init__(self, pid, logfh, timeout=30):
        self.timeout = timeout
        self.logfh = logfh
        self.child_pid, self.fd = pty.fork()
        if self.child_pid == 0:
            os.execvp('xcrun', ['xcrun', 'lldb', '--no-use-colors', '-p', str(pid)])
        self.buf = ''
        os.set_blocking(self.fd, False)

    def _read_some(self, deadline):
        remain = deadline - time.time()
        if remain <= 0:
            return ''
        r, _, _ = select.select([self.fd], [], [], min(remain, 1.0))
        if not r:
            return ''
        try:
            chunk = os.read(self.fd, 4096)
        except OSError:
            return ''
        if not chunk:
            return ''
        text = chunk.decode('utf-8', 'replace')
        log_write(self.logfh, text)
        return text

    def expect_prompt(self):
        deadline = time.time() + self.timeout
        while time.time() < deadline:
            self.buf += self._read_some(deadline)
            if PROMPT in self.buf:
                # wait until prompt at end (allow trailing spaces)
                if self.buf.rstrip().endswith(PROMPT.rstrip()):
                    return True
        raise TimeoutError('lldb prompt timeout: ' + self.buf[-800:])

    def cmd(self, line):
        os.write(self.fd, (line + '\n').encode())
        log_write(self.logfh, line + '\n')
        self.buf = ''
        self.expect_prompt()
        return self.buf

    def close_write(self, line):
        os.write(self.fd, (line + '\n').encode())
        log_write(self.logfh, line + '\n')


def ps_pid(pid):
    r = subprocess.run(['ps', '-axo', 'pid=,lstart=,stat=,command='], capture_output=True, text=True)
    lines = [ln for ln in r.stdout.splitlines() if ln.strip().startswith(str(pid)+' ') or ln.strip().startswith(str(pid)+'\t')]
    # safer: pid field exact
    hits = []
    for ln in r.stdout.splitlines():
        parts = ln.strip().split(None, 1)
        if parts and parts[0] == str(pid):
            hits.append(ln)
    stdout = '\n'.join(hits) + ('\n' if hits else '')
    return {'returncode': 0 if hits else 1, 'stdout': stdout, 'stderr': r.stderr}


def main():
    fresh = json.loads((ROOT / 'e1-fresh-instance.json').read_text())
    pid = fresh['pid']
    fifo = str(CMD_FIFO)
    if CMD_FIFO.exists():
        CMD_FIFO.unlink()
    os.mkfifo(fifo)
    os.chmod(fifo, 0o600)
    with PTY_LOG.open('w') as logfh:
        lldb = Lldb(pid, logfh, timeout=30)
        lldb.expect_prompt()
        # formatter then setup
        lldb.cmd('command source -s true ' + str(ROOT / 'lldb-format-suppress.lldb'))
        fmt = lldb.cmd('settings show frame-format')
        thr = lldb.cmd('settings show thread-format')
        dis = lldb.cmd('settings show stop-disassembly-display')
        img = lldb.cmd('image list Keyboard.debug.dylib')
        lldb.cmd('command script import ' + str(ROOT / 'owner_export_callback.py'))
        lldb.cmd('command script import ' + str(ROOT / 'e1_setup.py'))
        lldb.cmd('command script import ' + str(ROOT / 'e1_checkpoint.py'))
        cfg_out = lldb.cmd('script e1_setup.configure()')
        # configure() records async=false; CLI continue needs async true or it never returns.
        lldb.cmd('script lldb.debugger.SetAsync(True)')
        lldb.cmd('continue')
        snap_out = lldb.cmd("script e1_checkpoint.capture_debugger_state('%s', 'pre-arm')" % ROOT)
        (ROOT / 'e1-formatter-live-readback.txt').write_text(fmt + '\n' + thr + '\n' + dis + '\n' + img)
        # evaluate on host using written files
        config = json.loads((ROOT / 'e1-configuration-receipt.json').read_text())
        snapshot = json.loads((ROOT / 'pre-arm-debugger-state.json').read_text())
        ps_result = ps_pid(pid)
        callback_exists = (ROOT / 'callback.json').exists()
        sys.path.insert(0, str(ROOT))
        import e1_checkpoint
        rec = e1_checkpoint.record_and_evaluate(
            ROOT / 'e1-pre-arm-evaluation.json',
            fresh, config, snapshot, ps_result, callback_exists)
        status = {
            'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
            'status': rec['status'],
            'failures': rec.get('failures'),
            'pid': pid,
            'formatter_has_pc': 'frame.pc' in fmt.lower() or 'pc=' in fmt.lower(),
            'formatter_has_reason': 'stop-reason' in thr.lower() or 'stop=' in thr.lower(),
            'formatter_banned': any(b in (fmt+thr).lower() for b in ('formatted-arguments','name-with-args')),
            'image_list_tail': img[-800:],
            'callback_exists': callback_exists,
        }
        STATUS.write_text(json.dumps(status, indent=2) + '\n')
        # wait for fifo commands
        while True:
            with open(fifo, 'r') as fh:
                line = fh.readline().strip()
            if not line:
                time.sleep(0.2)
                continue
            log_write(logfh, '\n# FIFO ' + line + '\n')
            if line == 'PRE_FREEZE':
                lldb.cmd("script e1_checkpoint.capture_debugger_state('%s', 'pre-freeze')" % ROOT)
                (ROOT / 'e1-pre-freeze-fifo-ack.json').write_text(json.dumps({
                    'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    'ack': 'PRE_FREEZE',
                }, indent=2)+'\n')
            elif line == 'BREAKPOINT_LIST':
                out = lldb.cmd('breakpoint list')
                (ROOT / 'e1-breakpoint-list.txt').write_text(out)
            elif line == 'DETACH_QUIT':
                lldb.cmd('process detach')
                lldb.close_write('quit')
                time.sleep(1)
                (ROOT / 'e1-driver-exit.json').write_text(json.dumps({
                    'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
                    'status': 'quit_sent',
                }, indent=2)+'\n')
                return 0
            elif line.startswith('RAW '):
                lldb.cmd(line[4:])
            else:
                (ROOT / 'e1-fifo-unknown.json').write_text(json.dumps({'line': line}, indent=2)+'\n')


if __name__ == '__main__':
    try:
        sys.exit(main() or 0)
    except Exception as exc:
        Path('/private/tmp/ukey-host-activation-fix-owner-export-20261006/e1-pre-arm-status.json').write_text(
            json.dumps({'status': 'DRIVER_ERROR', 'error': type(exc).__name__ + ': ' + str(exc)}, indent=2)+'\n')
        raise
