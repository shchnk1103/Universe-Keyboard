from pathlib import Path
import json, subprocess, hashlib, plistlib, datetime
r=Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard')
b=Path('/private/tmp/ukey-wake-ui-u0-20261003')
udid='405D994F-28CB-4F89-BB22-B64AD81C05A2'; bid='com.DoubleShy0N.Universe-Keyboard';gid='group.com.DoubleShy0N.Universe-Keyboard'
def run(argv):
 p=subprocess.run(argv,capture_output=True,text=True,check=True);return p.stdout.strip()
p=json.loads((r/'docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-artifacts/paired-products.json').read_text())
app=Path(run(['xcrun','simctl','get_app_container',udid,bid,'app']))
group_rows=run(['xcrun','simctl','get_app_container',udid,bid,'groups'])
group=Path(dict(line.split('\t',1) for line in group_rows.splitlines())[gid])
actual={str(x.relative_to(app)):hashlib.sha256(x.read_bytes()).hexdigest() for x in app.rglob('*') if x.is_file()}
assert actual==p['file_hashes'],'installed payload mismatch'
f=group/'Library/Preferences'/f'{gid}.plist'; d=plistlib.loads(f.read_bytes()) if f.exists() else {}
keys=['logging_enabled','diagnostics_high_fidelity_expiration']; selected={k:{'exists':k in d,'value':d.get(k)} for k in keys}
expected=json.loads(Path('/private/tmp/ukey-wake-ui-i1-20261003/postinstall-verification.json').read_text())['selected_preferences']
assert selected=={k:expected[k] for k in keys},'diagnostic preference drift'
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'udid':udid,'candidate':p['candidate'],'installed_files':len(actual),'installed_payload_matches_H1':True,'selected_diagnostic_preferences':selected,'diagnostic_original_presence_and_values_unchanged_from_I1':True,'only_installed_binary_hashes_and_selected_preferences_read':True,'no_user_content_read':True,'no_full_data_equality_claim':True,'no_install_launch_input_arm_lldb_maps':True}
(b/'post-human-readback.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(json.dumps(result,ensure_ascii=False))
