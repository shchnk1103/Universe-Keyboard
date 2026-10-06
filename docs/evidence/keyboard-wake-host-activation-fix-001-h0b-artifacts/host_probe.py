"""Task-owned host fixture only; record stop identity, never target contents."""
import datetime
import json
import os
from pathlib import Path
import shutil
import select
import subprocess
import time
import lldb

ROOT = Path('/private/tmp/ukey-host-activation-fix-h0b-20261006')
EXPECTED_PID = None
TARGET = None
HITS = []


def utc():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def describe(frame, location=None):
    thread = frame.GetThread()
    process = thread.GetProcess()
    value = {
        'utc': utc(), 'pid': process.GetProcessID(),
        'thread_id': thread.GetThreadID(), 'frame_id': frame.GetFrameID(),
        'stop_id': process.GetStopID(), 'process_state': process.GetState(),
        'stop_reason': thread.GetStopReason(),
        'stop_reason_data': [thread.GetStopReasonDataAtIndex(i)
                             for i in range(thread.GetStopReasonDataCount())],
        'frame_pc': frame.GetPC(),
        'function': frame.GetFunctionName(),
        'module_uuid': frame.GetModule().GetUUIDString(),
    }
    if location is not None:
        address = location.GetAddress()
        value.update(breakpoint_id=location.GetBreakpoint().GetID(),
                     location_id=location.GetID(),
                     breakpoint_pc=address.GetLoadAddress(TARGET),
                     breakpoint_module_uuid=address.GetModule().GetUUIDString())
    return value


def export_hit(frame, bp_loc, internal_dict):
    # Preserve the passed frame; never substitute the CLI selected frame.
    value = describe(frame, bp_loc)
    value['expected_pid'] = EXPECTED_PID
    value['memory_reads'] = 0
    HITS.append(value)
    (ROOT / 'callback.json').write_text(json.dumps(HITS, indent=2) + '\n')
    return True


STATE = {}


def prepare(debugger):
    global EXPECTED_PID, TARGET
    STATE['started_utc'] = utc()
    STATE['started_monotonic'] = time.monotonic()
    STATE['previous_async'] = debugger.GetAsync()
    debugger.SetAsync(False)
    fixture = subprocess.Popen([str(ROOT / 'fixture')], stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    STATE['fixture'] = fixture
    EXPECTED_PID = fixture.pid
    readable, _, _ = select.select([fixture.stdout], [], [], 5)
    if not readable or fixture.stdout.read(1) != b'R':
        fixture.stdin.close()
        fixture.terminate()
        fixture.wait(timeout=2)
        raise RuntimeError('ready_handshake_failed; own fixture cleaned')
    STATE['ready_utc'] = utc()
    if fixture.poll() is not None:
        raise RuntimeError('fixture_exited_before_attach')
    TARGET = debugger.CreateTarget(str(ROOT / 'fixture'))
    error = lldb.SBError()
    process = TARGET.AttachToProcessWithID(debugger.GetListener(), fixture.pid, error)
    STATE['process'] = process
    if error.Fail() or not process.IsValid():
        raise RuntimeError('attach_failed: ' + str(error))
    attach_thread = process.GetSelectedThread()
    attach_frame = attach_thread.GetFrameAtIndex(0)
    STATE['attach_frame'] = describe(attach_frame)
    callers = []
    for i in range(8):
        caller = attach_thread.GetFrameAtIndex(i)
        if not caller.IsValid():
            break
        callers.append(caller.GetFunctionName() or '')
    module_name = attach_frame.GetModule().GetFileSpec().GetFilename() or ''
    STATE['wait_proof'] = {
        'ready_received_utc': STATE['ready_utc'],
        'attach_module': module_name, 'caller_names': callers,
        'initial_system_wait_verified': (
            'read' in (attach_frame.GetFunctionName() or '').lower()
            and module_name.startswith('libsystem_kernel')
            and 'main' in callers),
    }
    if not STATE['wait_proof']['initial_system_wait_verified']:
        (ROOT / 'wait-entry-failure.json').write_text(
            json.dumps(STATE['wait_proof'], indent=2) + '\n')
        finish(debugger)
        raise RuntimeError('actual_wait_frame_not_verified; stopped and cleaned')
    breakpoint = TARGET.BreakpointCreateByName('h0_export_ready')
    STATE['breakpoint'] = breakpoint
    if breakpoint.GetNumLocations() != 1:
        raise RuntimeError('expected_one_breakpoint_location')
    breakpoint.SetScriptCallbackFunction('host_probe.export_hit')
    token_fd = fixture.stdin.fileno()
    helper = subprocess.Popen([shutil.which('python3'), '-c',
                               'import os,time; time.sleep(0.5); os.write(int(__import__("sys").argv[1]),b"G")',
                               str(token_fd)], pass_fds=(token_fd,),
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    STATE['helper'] = helper
    receipt = {'fixture_pid': fixture.pid, 'helper_pid': helper.pid,
               'fixture_path': str(ROOT / 'fixture'), 'attach_frame': STATE['attach_frame'],
               'wait_proof': STATE['wait_proof'],
               'breakpoint_id': breakpoint.GetID(),
               'location_pc': breakpoint.GetLocationAtIndex(0).GetAddress().GetLoadAddress(TARGET)}
    (ROOT / 'prepare-receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(receipt, indent=2))
    # Only publish the continue command after the fresh wait gate passes.
    debugger.HandleCommand('command alias h0_go continue')
    # Return to LLDB before CLI continue; do not hold its Python command context
    # while waiting for the Python breakpoint callback.


def finish(debugger):
    fixture = STATE.get('fixture')
    helper = STATE.get('helper')
    process = STATE.get('process')
    breakpoint = STATE.get('breakpoint')
    report = {'started_utc': STATE.get('started_utc'), 'status': 'unavailable',
              'scope': 'isolated macOS fixture, no Simulator', 'memory_reads': 0,
              'target_expressions': 0, 'callbacks': HITS, 'cleanup': {},
              'wait_proof': STATE.get('wait_proof')}
    try:
        report['fixture_pid'] = fixture.pid
        report['fixture_path'] = str(ROOT / 'fixture')
        report['attach_frame'] = STATE.get('attach_frame')
        if not HITS:
            raise RuntimeError('callback_not_observed')
        report['selected_stop_frame'] = describe(process.GetSelectedThread().GetFrameAtIndex(0))
        hit = HITS[0]
        report['passed_frame_matches_location'] = (
            hit['pid'] == fixture.pid and hit['frame_id'] == 0
            and hit['frame_pc'] == hit['breakpoint_pc']
            and hit['module_uuid'] == hit['breakpoint_module_uuid']
            and hit['breakpoint_id'] == breakpoint.GetID()
            and 'h0_export_ready' in (hit['function'] or ''))
        report['callback_count'] = len(HITS)
        report['breakpoint_hit_count'] = breakpoint.GetHitCount()
        report['status'] = 'host_identity_match' if report['passed_frame_matches_location'] else 'host_identity_mismatch'
    except Exception as exc:
        report['reason'] = str(exc)
    finally:
        if TARGET is not None and breakpoint is not None:
            report['cleanup']['breakpoint_deleted'] = TARGET.BreakpointDelete(breakpoint.GetID())
        if process is not None and process.IsValid() and process.GetState() not in (lldb.eStateDetached, lldb.eStateExited):
            error = process.Detach()
            report['cleanup']['detach_success'] = error.Success()
            report['cleanup']['detach_error'] = str(error)
        if fixture is not None:
            fixture.stdin.close()
            if fixture.stdout is not None:
                fixture.stdout.close()
            try:
                report['cleanup']['fixture_exit_code'] = fixture.wait(timeout=2)
            except subprocess.TimeoutExpired:
                fixture.terminate()
                report['cleanup']['own_fixture_sigterm_sent'] = True
                try:
                    report['cleanup']['fixture_exit_code'] = fixture.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    report['cleanup']['fixture_still_alive'] = True
        if helper is not None:
            try:
                report['cleanup']['helper_exit_code'] = helper.wait(timeout=2)
            except subprocess.TimeoutExpired:
                helper.terminate()
                report['cleanup']['own_helper_sigterm_sent'] = True
        debugger.SetAsync(STATE.get('previous_async', False))
        report['ended_utc'] = utc()
        report['wall_seconds'] = time.monotonic() - STATE.get('started_monotonic', time.monotonic())
        (ROOT / 'run-receipt.json').write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps(report, indent=2))
