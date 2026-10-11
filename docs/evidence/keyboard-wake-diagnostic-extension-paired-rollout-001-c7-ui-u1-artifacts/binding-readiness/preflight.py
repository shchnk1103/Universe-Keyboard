from pathlib import Path
import json,subprocess,hashlib,plistlib,datetime,time
r=Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard');b=Path('/private/tmp/ukey-wake-ui-u1-execution-20261003/binding-readiness');u='405D994F-28CB-4F89-BB22-B64AD81C05A2';bid='com.DoubleShy0N.Universe-Keyboard';gid='group.com.DoubleShy0N.Universe-Keyboard'
def run(argv):
 start=time.monotonic_ns();request=datetime.datetime.now(datetime.timezone.utc).isoformat();p=subprocess.run(argv,capture_output=True,text=True,timeout=30);response=datetime.datetime.now(datetime.timezone.utc).isoformat();end=time.monotonic_ns()
 with (b/'preflight-command-ledger.jsonl').open('a') as f:f.write(json.dumps({'argv':argv,'request_utc':request,'response_utc':response,'monotonic_start_ns':start,'monotonic_end_ns':end,'exit':p.returncode})+'\n')
 assert p.returncode==0,p.stderr;return p.stdout.strip()
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert run(['git','-C',str(r),'branch','--show-current'])=='codex/keyboard-wake-v3-compatibility-gate';assert run(['git','-C',str(r),'rev-parse','HEAD'])=='84b9c19227330b0fe6ff391be001ee398010fd6a'
(b/'before-dirty.txt').write_text(run(['git','-C',str(r),'status','--short'])+'\n')
tracked=run(['git','-C',str(r),'ls-files','--cached','--others','--exclude-standard','-z']).split('\0');before={p:sha(r/p) for p in tracked if p and (r/p).is_file()};(b/'before-files.json').write_text(json.dumps(before,ensure_ascii=False,indent=2)+'\n')
f=json.loads((r/'docs/plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-prepared-artifacts/freeze-inputs.json').read_text());assert all(sha(p)==v for p,v in f['hash_only_source_vendor_inputs'].items());assert all(sha(r/p)==v for m in ['reference_sha256','prepared_output_sha256'] for p,v in f[m].items())
devices=json.loads(run(['xcrun','simctl','list','devices','--json']));matches=[(runtime,x) for runtime,rows in devices['devices'].items() for x in rows if x['udid']==u];assert len(matches)==1;runtime,device=matches[0];assert device['name']=='iPhone 18 Pro' and device['state']=='Booted' and runtime.endswith('iOS-27-0')
app=Path(run(['xcrun','simctl','get_app_container',u,bid,'app']));groups=run(['xcrun','simctl','get_app_container',u,bid,'groups']);group=Path(dict(x.split('\t',1) for x in groups.splitlines())[gid]);paired=json.loads((r/'docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-artifacts/paired-products.json').read_text());actual={str(p.relative_to(app)):sha(p) for p in app.rglob('*') if p.is_file()};assert actual==paired['file_hashes']
pref=group/'Library/Preferences'/f'{gid}.plist';d=plistlib.loads(pref.read_bytes()) if pref.exists() else {};selected={k:{'exists':k in d,'value':d.get(k)} for k in ['logging_enabled','diagnostics_high_fidelity_expiration']};assert all(not x['exists'] for x in selected.values())
exe=app/'PlugIns/Keyboard.appex/Keyboard';rows=[]
for line in run(['ps','-axo','pid=,comm=']).splitlines():
 parts=line.strip().split(None,1)
 if len(parts)==2 and parts[1]==str(exe):rows.append({'pid':int(parts[0]),'executable':parts[1]})
assert len(rows)==1,'exact current Keyboard appex PID unavailable or ambiguous';assert sha(exe)==paired['file_hashes']['PlugIns/Keyboard.appex/Keyboard']
backups={str(root):{'exists':root.is_dir(),'components_present':all((root/name).is_dir() for name in ['main-data','app-group','installed-app'])} for root in [Path('/private/tmp/ukey-wake-ui-i0-20261003/backup'),Path('/private/tmp/ukey-wake-ui-i1-20261003/after-preservation')]};assert all(x['exists'] and x['components_present'] for x in backups.values())
receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'device':device,'runtime':runtime,'candidate':paired['candidate'],'source_input_count':len(f['hash_only_source_vendor_inputs']),'source_drift':[],'installed_files':len(actual),'payload_matches_H1':True,'process':rows[0],'selected_diagnostic_preferences':selected,'historical_backup_presence':backups,'backup_content_reverification_this_run':False,'not_latest_post_U0_data_recovery_proof':True,'before_files_count':len(before),'no_launch_install_deploy_arm_lldb_input':True}
(b/'machine-entry.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n');print(json.dumps(receipt,ensure_ascii=False))
