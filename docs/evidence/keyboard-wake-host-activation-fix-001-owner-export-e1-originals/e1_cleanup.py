"""Delete the one breakpoint and snapshot stop; no extra ReadMemory."""
import datetime, json
from pathlib import Path
import lldb

ROOT = Path('/private/tmp/ukey-host-activation-fix-owner-export-20261006')


def snapshot_and_delete():
    target = lldb.debugger.GetSelectedTarget()
    process = target.GetProcess()
    thread = process.GetSelectedThread()
    frame = thread.GetFrameAtIndex(0)
    config = json.loads((ROOT / 'live-binding.json').read_text())
    bp = target.FindBreakpointByID(config['breakpoint_id'])
    data = {
        'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'pid': process.GetProcessID(),
        'stop_id': process.GetStopID(),
        'state': process.GetState(),
        'thread_id': thread.GetThreadID(),
        'frame_id': frame.GetFrameID(),
        'frame_pc': frame.GetPC(),
        'frame_uuid': frame.GetModule().GetUUIDString() if frame.GetModule() else None,
        'function_name': frame.GetFunctionName(),
        'stop_reason': thread.GetStopReason(),
        'hit_count': bp.GetHitCount() if bp.IsValid() else None,
        'target_memory_reads': 0,
        'target_expressions': 0,
    }
    data['delete_success'] = target.BreakpointDelete(config['breakpoint_id'])
    data['remaining_breakpoints'] = target.GetNumBreakpoints()
    path = ROOT / 'e1-stop-and-cleanup.json'
    if path.exists():
        raise FileExistsError('cleanup snapshot already exists')
    path.write_text(json.dumps(data, indent=2) + '\n')
    print('OWN_EXPORT_STOP_CLEANUP', json.dumps(data, sort_keys=True))
