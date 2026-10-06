"""Host-only pre-click recorder; no frame or argument inspection."""
import datetime
import json
from pathlib import Path


def record_and_evaluate(output, fresh, config, snapshot, ps_result, callback_exists):
    output = Path(output)
    if output.exists():
        raise FileExistsError('checkpoint record already exists')
    record = {'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'status': 'RECORDED_NOT_EVALUATED', 'fresh': fresh, 'config': config,
              'snapshot': snapshot, 'ps': ps_result, 'callback_exists': callback_exists,
              'checks': {}, 'failures': []}
    output.write_text(json.dumps(record, indent=2) + '\n')
    checks = {}
    try:
        parts = ps_result['stdout'].strip().split(None, 7)
        expected = fresh['ps'].strip().split(None, 7)
        checks['ps_command_succeeded'] = ps_result['returncode'] == 0
        checks['ps_fields_complete'] = len(parts) == len(expected) == 8
        if checks['ps_fields_complete']:
            checks['ps_pid_matches'] = int(parts[0]) == fresh['pid']
            checks['start_time_matches'] = parts[1:6] == expected[1:6]
            checks['exact_binary_path'] = parts[7] == fresh['binary']
            record['ps_stat_observed'] = parts[6]
        checks['configured'] = config.get('status') == 'CONFIGURED'
        checks['same_binding_pid'] = config.get('binding', {}).get('pid') == fresh['pid']
        checks['hit_zero'] = config.get('hit_count') == 0
        checks['one_location'] = config.get('breakpoint_locations') == 1
        checks['callback_configured'] = config.get('callback_configured') is True
        checks['sync_mode'] = config.get('async') is False
        checks['callback_absent'] = callback_exists is False
        checks['same_snapshot_pid'] = snapshot.get('pid') == fresh['pid']
        checks['process_valid'] = snapshot.get('process_valid') is True
        checks['process_running'] = snapshot.get('state_is_running') is True
        checks['snapshot_hit_zero'] = snapshot.get('hit_count') == 0
        checks['snapshot_utc_present'] = bool(snapshot.get('utc'))
        checks['uuid_bound'] = config.get('binding', {}).get('loaded_uuid') == '4B207746-89A7-321F-83C4-91477259BB26'
        checks['symbol_bound'] = config.get('binding', {}).get('symbol') == '$s8Keyboard25wakeOwnerProbeExportReadyyySV_SitF'
    except (KeyError, TypeError, ValueError, AttributeError) as error:
        record['evaluation_error'] = type(error).__name__ + ': ' + str(error)
        checks['parse_complete'] = False
    record['checks'] = checks
    record['failures'] = [name for name, passed in checks.items() if not passed]
    record['status'] = 'PASS_PRECLICK_METADATA' if checks and not record['failures'] else 'STOP_PRECLICK'
    output.write_text(json.dumps(record, indent=2) + '\n')
    return record


def capture_debugger_state(root, phase="pre-arm"):
    import lldb
    root = Path(root)
    if phase not in ("pre-arm", "pre-freeze"):
        raise ValueError("invalid checkpoint phase")
    target = lldb.debugger.GetSelectedTarget()
    process = target.GetProcess()
    binding = json.loads((root / 'live-binding.json').read_text())
    breakpoint = target.FindBreakpointByID(binding['breakpoint_id'])
    value = {'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
             'pid': process.GetProcessID(), 'process_valid': process.IsValid(),
             'state_code': process.GetState(),
             'state_is_running': process.GetState() == lldb.eStateRunning,
             'hit_count': breakpoint.GetHitCount(), 'breakpoint_id': breakpoint.GetID(),
             'target_memory_reads': 0, 'argument_reads': 0, 'target_expressions': 0}
    value['phase'] = phase
    path = root / (phase + '-debugger-state.json')
    if path.exists():
        raise FileExistsError('debugger checkpoint already exists')
    path.write_text(json.dumps(value, indent=2) + '\n')
    print('OWN_EXPORT_STATE', json.dumps(value, sort_keys=True))
