"""E1 debugger setup; does not modify frozen owner_export_callback.py."""
import datetime
import json
from pathlib import Path
import lldb
import owner_export_callback

ROOT = Path('/private/tmp/ukey-host-activation-fix-owner-export-20261006')
SYMBOL = '$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF'
UUID = '4B207746-89A7-321F-83C4-91477259BB26'


def configure():
    fresh = json.loads((ROOT / 'e1-fresh-instance.json').read_text())
    debugger = lldb.debugger
    target = debugger.GetSelectedTarget()
    process = target.GetProcess()
    assert process.GetProcessID() == fresh['pid']
    assert process.GetState() == lldb.eStateStopped
    assert target.GetNumBreakpoints() == 0
    matches = [m for m in target.modules
               if m.GetFileSpec().GetFilename() == 'Keyboard.debug.dylib']
    assert len(matches) == 1 and matches[0].GetUUIDString() == UUID
    bp = target.BreakpointCreateByName(SYMBOL, 'Keyboard.debug.dylib')
    assert bp.IsValid() and bp.GetNumLocations() == 1 and bp.GetHitCount() == 0
    loc = bp.GetLocationAtIndex(0)
    address = loc.GetAddress()
    assert address.GetModule().GetUUIDString() == UUID
    assert address.GetLoadAddress(target) != lldb.LLDB_INVALID_ADDRESS
    mangled = None
    if address.GetSymbol().IsValid():
        mangled = address.GetSymbol().GetMangledName()
    func = address.GetFunction()
    func_name = func.GetName() if func.IsValid() else None
    binding = {
        'pid': process.GetProcessID(),
        'loaded_uuid': UUID,
        'symbol': SYMBOL,
        'breakpoint_pc': address.GetLoadAddress(target),
        'breakpoint_id': bp.GetID(),
        'location_id': loc.GetID(),
        'attach_stop_id': process.GetStopID(),
        'function_name': func_name,
        'symbol_mangled': mangled,
    }
    live = ROOT / 'live-binding.json'
    if live.exists():
        raise FileExistsError('live-binding already exists')
    live.write_text(json.dumps(binding, indent=2) + '\n')
    owner_export_callback.configure()
    bp.SetScriptCallbackFunction('owner_export_callback.export_hit')
    result = lldb.SBCommandReturnObject()
    debugger.GetCommandInterpreter().HandleCommand(
        'breakpoint command list %d' % bp.GetID(), result)
    assert result.Succeeded(), result.GetError()
    listed = result.GetOutput() or ''
    assert 'owner_export_callback.export_hit' in listed
    debugger.SetAsync(False)
    assert not debugger.GetAsync() and target.GetNumBreakpoints() == 1
    receipt = {
        'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'status': 'CONFIGURED',
        'binding': binding,
        'callback_configured': True,
        'async': debugger.GetAsync(),
        'breakpoint_locations': bp.GetNumLocations(),
        'hit_count': bp.GetHitCount(),
        'callback_list': listed,
        'function_name': func_name,
        'symbol_mangled': mangled,
    }
    (ROOT / 'e1-configuration-receipt.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print('OWN_EXPORT_CONFIGURED', json.dumps(receipt, sort_keys=True))
