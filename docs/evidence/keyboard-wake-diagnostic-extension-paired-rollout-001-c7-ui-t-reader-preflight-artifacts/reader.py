"""Offline evidence preflight. Never invokes tests, Simulator, LLDB or builds.
Outputs are coordinator rehearsal artifacts, never independent acceptance.
"""
import argparse, collections, hashlib, json, os, pathlib, re, subprocess, tempfile, time

def digest(path):
    return hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()

def load(path):
    return json.loads(pathlib.Path(path).read_text())

def canonical(value):
    return hashlib.sha256(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(',', ':')).encode()).hexdigest()

def atomic_write(path, content):
    # Same-directory replacement prevents a half-written report being accepted.
    path = pathlib.Path(path)
    with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=path.parent, delete=False) as f:
        name = f.name
        f.write(content)
        f.flush()
        os.fsync(f.fileno())
    os.replace(name, path)

def application_path(path):
    return path not in ('.', '.com.apple.mobile_container_manager.metadata.plist') and not (path == 'Library/SplashBoard/Snapshots' or path.startswith('Library/SplashBoard/Snapshots/'))

def compare(reference, actual, application=False):
    missing, added, changed, extra_attrs = [], [], [], collections.Counter()
    for path in sorted(set(reference) | set(actual)):
        if application and not application_path(path):
            continue
        if path not in actual:
            missing.append(path); continue
        if path not in reference:
            added.append(path); continue
        a, b = reference[path], dict(actual[path])
        attrs = dict(b.get('xattrs', {}))
        # Only a new provenance attribute can be normalized; old values must match.
        if 'com.apple.provenance' not in a.get('xattrs', {}) and 'com.apple.provenance' in attrs:
            attrs.pop('com.apple.provenance'); extra_attrs['com.apple.provenance'] += 1
        b['xattrs'] = attrs
        fields = [key for key in sorted(set(a) | set(b)) if a.get(key) != b.get(key)]
        if fields:
            changed.append({'path': path, 'fields': fields,
                            'xattr_keys': sorted(k for k in set(a.get('xattrs', {})) | set(b.get('xattrs', {})) if a.get('xattrs', {}).get(k) != b.get('xattrs', {}).get(k)) if 'xattrs' in fields else []})
    return {'missing': missing, 'added': added, 'changed': changed, 'normalized_new_attrs': dict(extra_attrs)}

def snapshots(inv):
    return collections.Counter(row['sha256'] for path, row in inv.items()
                               if path.startswith('Library/SplashBoard/Snapshots/') and row.get('kind') == 'file')

def inventory_comparison(before_path, after_path, application=False):
    before, after = load(before_path), load(after_path)
    return {root: compare(before[root], after[root], application) for root in before if root in after}

def main():
    args = argparse.ArgumentParser()
    args.add_argument('--packet', required=True)
    args.add_argument('--external', required=True)
    args.add_argument('--output', required=True)
    opt = args.parse_args()
    start = time.time()
    pp = pathlib.Path(opt.packet).resolve()
    packet = load(pp)
    external = load(opt.external)
    expected_self = packet['packet_digest_sha256']
    plain = dict(packet); plain.pop('packet_digest_sha256')
    assert canonical(plain) == expected_self, 'canonical packet mismatch'
    assert digest(pp) == external['whole_file_digest'], 'whole packet mismatch'
    # Use the frozen explicit baseline, not a fragile parents[n] calculation.
    root = pathlib.Path(packet['baseline']['worktree']).resolve()
    assert (root / 'AGENTS.md').is_file()
    actual_head = subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD'], text=True).strip()
    actual_branch = subprocess.check_output(['git', '-C', str(root), 'branch', '--show-current'], text=True).strip()
    assert actual_head == packet['baseline']['HEAD'] and actual_branch == packet['baseline']['branch']
    inputs = packet['allowed_content_inputs']
    missing = [path for path in inputs if not pathlib.Path(path).is_file()]
    assert not missing, 'missing allowlisted input'
    drift = [path for path, sha in inputs.items() if digest(path) != sha]
    source_drift = [path for path, sha in packet['hash_only_source_vendor_inputs'].items() if digest(path) != sha]
    assert not drift, 'allowlisted content hash mismatch: ' + ', '.join(drift)
    assert not source_drift, 'hash-only source mismatch'
    result = {'role': 'Coordinator offline reader preflight; not independent review',
              'packet': str(pp), 'self_digest': expected_self, 'whole_file_digest': digest(pp),
              'baseline_identity_matches': True, 'content_input_count': len(inputs),
              'content_hash_drift': drift, 'hash_only_count': len(packet['hash_only_source_vendor_inputs']),
              'hash_only_drift': source_drift, 'observations': {}}
    def one(suffix):
        matches = [path for path in inputs if path.endswith(suffix)]
        assert len(matches) == 1, f'expected unique locator: {suffix}'
        return pathlib.Path(matches[0])
    obs = result['observations']
    for name, suffix in [('Rime', '/Rime-test-summary.json'), ('AppKeyboard', '/AppKeyboard-test-summary.json'), ('Keychain', '/xcresult-summary.json')]:
        paths = [p for p in inputs if p.endswith(suffix)]
        if paths:
            summary = load(one(suffix))
            obs[name] = {key: summary[key] for key in ['totalTestCount', 'passedTests', 'failedTests', 'skippedTests']}
            obs[name]['device_ids'] = [d['device']['deviceId'] for d in summary['devicesAndConfigurations']]
    core = [p for p in inputs if p.endswith('/package-input-manifest.json')]
    if core:
        manifest = load(core[0])['all_package_files']
        package = root / 'Packages/KeyboardCore'
        actual = set(subprocess.check_output(['git', '-C', str(root), 'ls-files', '--cached', '--others', '--exclude-standard', '--', 'Packages/KeyboardCore'], text=True).splitlines())
        expected = {'Packages/KeyboardCore/' + p for p in manifest}
        obs['core'] = {'file_count': len(manifest), 'missing': sorted(expected - actual), 'extra': sorted(actual - expected),
                       'hash_mismatches': [p for p, sha in manifest.items() if digest(package / p) != sha],
                       'test_summary': load(one('c7b2-core-artifacts/test-summary.json'))}
    manifests = [p for p in inputs if p.endswith('/build-input-manifest.json')]
    if manifests:
        manifest = load(manifests[0])
        obs['candidate_manifest'] = {}
        for field in ['source_and_build_inputs', 'vendor_files']:
            mapping = manifest[field]
            obs['candidate_manifest'][field] = {'count': len(mapping), 'mismatches': [path for path, sha in mapping.items() if digest(root / path) != sha], 'hash_only_map_disagreements': [path for path, sha in mapping.items() if packet['hash_only_source_vendor_inputs'].get(str(root / path)) != sha]}
        obs['candidate_manifest']['recorded_toolchain'] = manifest['toolchain']
        obs['compiler_log_observations'] = {}
        for path in inputs:
            if pathlib.Path(path).name in ['Rime.log', 'AppKeyboard.log', 'Keychain.log']:
                lines = pathlib.Path(path).read_text().splitlines()
                drivers = [line for line in lines if 'swiftc -module-name' in line]
                obs['compiler_log_observations'][pathlib.Path(path).name] = {'driver_invocations': len(drivers), 'swift6': sum('-swift-version 6' in line for line in drivers), 'probe_define': sum('KEYBOARD_WAKE_OWNER_PROBE' in line for line in drivers), 'warnings_as_errors': sum('-warnings-as-errors' in line for line in drivers), 'literal_strict_complete': sum('-strict-concurrency=complete' in line for line in drivers), 'log_sha256': digest(path)}
        def commands(value):
            found = []
            if isinstance(value, dict):
                if isinstance(value.get('argv'), list) and value['argv'] and value['argv'][0] == 'xcodebuild':
                    found.append(value['argv'])
                for child in value.values():
                    found.extend(commands(child))
            elif isinstance(value, list):
                for child in value:
                    found.extend(commands(child))
            return found
        obs['frozen_xcodebuild_argv'] = {path: commands(load(path)) for path in inputs if path.endswith('frozen-packet.json')}
        obs['binding_limit'] = 'Static inputs/recorded argv/raw drivers are evidence locators; standalone candidate versus test-host compilation equivalence still requires reviewer assessment.'
    inventories = [p for p in inputs if p.endswith('-inventories.json')]
    if inventories:
        pairs = [
            ('initial_restore', '/ukey-wake-ui-t0-20261003/before-inventories.json', '/ukey-wake-ui-t2-restore-20261003/restored-inventories.json', True),
            ('fresh_backup', '/ukey-wake-ui-keychain-continuation-20261003/before-inventories.json', '/ukey-wake-ui-keychain-continuation-20261003/backup-inventories.json', False),
            ('fresh_restore', '/ukey-wake-ui-keychain-continuation-20261003/before-inventories.json', '/ukey-wake-ui-keychain-continuation-20261003/minimal-restoration/restored-inventories.json', True),
            ('final_vs_postinstall', '/ukey-wake-ui-keychain-continuation-20261003/minimal-restoration/postinstall-inventories.json', '/ukey-wake-ui-keychain-continuation-20261003/minimal-restoration/restored-inventories.json', False)]
        obs['inventories'] = {}
        for name, a, b, app in pairs:
            before_path, after_path = one(a), one(b)
            comparisons = inventory_comparison(before_path, after_path, app)
            obs['inventories'][name] = comparisons
            before, after = load(before_path), load(after_path)
            obs['inventories'][name]['snapshot_sha_multiset_same'] = snapshots(before['main-data']) == snapshots(after['main-data'])
        obs['system_rows_final_vs_postinstall'] = {}
        before = load(one(pairs[-1][1])); after = load(one(pairs[-1][2]))
        for group in before:
            system = {p: v for p, v in before[group].items() if p in ('.', '.com.apple.mobile_container_manager.metadata.plist')}
            current = {p: v for p, v in after[group].items() if p in system}
            obs['system_rows_final_vs_postinstall'][group] = compare(system, current)
    # Always exercise the output contract, including a non-Complete result.
    out = pathlib.Path(opt.output).resolve()
    assert str(out).startswith('/private/tmp/ukey-wake-ui-t-reader-preflight-20261003/')
    out.mkdir(parents=True, exist_ok=True)
    atomic_write(out / 'reader-result.json', json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    report = '# Coordinator reader rehearsal\n\nThis is not an independent report or acceptance.\n\n'
    report += f'Input count: {len(inputs)}. Drift: {len(drift)}. Source drift: {len(source_drift)}.\n\n'
    report += 'Criteria remain Not assessed by an independent reviewer; overall T Hold.\n'
    atomic_write(out / 'report.md', report)
    usage = {'role': 'Coordinator rehearsal only', 'independent_leaf_calls': 'not applicable',
             'start_epoch': start, 'report_sha256': digest(out / 'report.md'),
             'reader_result_sha256': digest(out / 'reader-result.json'), 'coverage': 'Not an independent assessment'}
    usage['end_epoch_before_usage_write'] = time.time()
    usage['elapsed_before_usage_write_seconds'] = usage['end_epoch_before_usage_write'] - start
    atomic_write(out / 'usage.json', json.dumps(usage, indent=2) + '\n')
    assert load(out / 'usage.json')['report_sha256'] == digest(out / 'report.md')
    assert load(out / 'reader-result.json')['packet'] == str(pp)
    print(json.dumps({'output': str(out), 'content_drift_count': len(drift), 'source_drift_count': len(source_drift),
                      'report_and_usage_roundtrip': True, 'elapsed_through_readback_seconds': time.time() - start}))

if __name__ == '__main__':
    failure_start = time.time()
    try:
        main()
    except Exception as error:
        # Failures also leave a report/usage pair; they never become acceptance.
        import sys
        if '--output' in sys.argv:
            target = pathlib.Path(sys.argv[sys.argv.index('--output') + 1]).resolve()
            if str(target).startswith('/private/tmp/ukey-wake-ui-t-reader-preflight-20261003/'):
                target.mkdir(parents=True, exist_ok=True)
                atomic_write(target / 'report.md', '# Coordinator reader rehearsal: FAILED\n\n' + type(error).__name__ + ': ' + str(error) + '\n\nNot an independent assessment.\n')
                atomic_write(target / 'usage.json', json.dumps({'role': 'Coordinator failure rehearsal', 'coverage': 'Partial', 'error_type': type(error).__name__, 'error': str(error), 'report_sha256': digest(target / 'report.md'), 'failure_observed_epoch': time.time(), 'elapsed_before_failure_usage_write_seconds': time.time() - failure_start}, indent=2) + '\n')
        raise
