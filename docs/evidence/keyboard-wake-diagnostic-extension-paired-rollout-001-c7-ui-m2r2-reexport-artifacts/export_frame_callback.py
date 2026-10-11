"""Prepared debugger-only callback; never imported into or run by the app."""
import datetime
import json
from pathlib import Path
import lldb

OUTPUT = Path('/private/tmp/ukey-wake-m2r2-reexport-20261004/export-frame.json')
EXPECTED_PID = 55759
EXPECTED_SYMBOL = '$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF'
EXPECTED_UUID = '77BD18E2-E090-37D7-865F-84D762E69F70'


def export_hit(frame, bp_loc, internal_dict):
    # Use LLDB's hit-frame argument; the CLI's selected frame may be stale.
    result = {'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'status': 'unavailable', 'memory_snapshot_reads': 0}
    try:
        process = frame.GetThread().GetProcess()
        result['pid'] = process.GetProcessID()
        result['frame_id'] = frame.GetFrameID()
        result['symbol'] = frame.GetSymbol().GetMangledName()
        result['module_uuid'] = frame.GetModule().GetUUIDString()
        if (result['pid'] != EXPECTED_PID or result['frame_id'] != 0
                or result['symbol'] != EXPECTED_SYMBOL
                or result['module_uuid'].upper() != EXPECTED_UUID):
            raise ValueError('hit_frame_identity_mismatch')
        names = []
        for i in range(8):
            caller = frame.GetThread().GetFrameAtIndex(i)
            if not caller.IsValid():
                break
            names.append(caller.GetFunctionName() or '')
        result['caller_function_names'] = names
        if not any('handleWakeOwnerProbeButton' in n for n in names[1:]):
            raise ValueError('missing_button_caller')
        if not any('withUnsafeBytes' in n for n in names[1:]):
            raise ValueError('missing_synchronous_borrow')
        address = frame.FindVariable('address', lldb.eNoDynamicValues).GetNonSyntheticValue()
        count = frame.FindVariable('byteCount', lldb.eNoDynamicValues).GetNonSyntheticValue()
        pointer = address.GetChildMemberWithName('_rawValue', lldb.eNoDynamicValues)
        length = count.GetChildMemberWithName('_value', lldb.eNoDynamicValues)
        if not pointer.IsValid() or not length.IsValid():
            raise ValueError('static_argument_unavailable')
        error = lldb.SBError()
        result['address'] = pointer.GetValueAsUnsigned(error, 0)
        if error.Fail():
            raise ValueError('static_pointer_unavailable')
        result['byteCount'] = length.GetValueAsUnsigned(error, 0)
        if error.Fail():
            raise ValueError('static_count_unavailable')
        if (not result['address'] or result['address'] % 8
                or not 176 <= result['byteCount'] <= 11352
                or result['byteCount'] % 8):
            raise ValueError('invalid_pointer_or_size')
        result['status'] = 'static_arguments_available'
    except ValueError as exc:
        result['reason'] = str(exc)
    except Exception:
        result['reason'] = 'debugger_api_error'
    OUTPUT.parent.mkdir(mode=0o700,parents=True,exist_ok=True)
    OUTPUT.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    # Never resume, re-arm or read the transport here: root validates then reads once.
    return True
