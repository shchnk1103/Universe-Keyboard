from pathlib import Path
import json,subprocess,hashlib,os,signal,time,datetime
r=Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard');b=Path('/private/tmp/ukey-wake-ui-u1r1-execution-20261003');u='405D994F-28CB-4F89-BB22-B64AD81C05A2';bid='com.DoubleShy0N.Universe-Keyboard';expected=json.loads((b/'machine-entry.json').read_text())['process'];paired=json.loads((r/'docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-h1-artifacts/paired-products.json').read_text())
def run(argv):return subprocess.run(argv,capture_output=True,text=True,check=True,timeout=30).stdout.strip()
def matches():
 out=[]
 for line in run(['ps','-axo','pid=,comm=']).splitlines():
  p=line.strip().split(None,1)
  if len(p)==2 and p[1]==expected['executable']:out.append(int(p[0]))
 return out
app=Path(run(['xcrun','simctl','get_app_container',u,bid,'app']));exe=app/'PlugIns/Keyboard.appex/Keyboard';assert str(exe)==expected['executable'];assert hashlib.sha256(exe.read_bytes()).hexdigest()==paired['file_hashes']['PlugIns/Keyboard.appex/Keyboard'];ids=matches();assert ids in [[],[expected['pid']]],'unexpected exact extension PID; stop'
receipt={'request_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'human_app_closed_and_exclusive_confirmed':True,'expected_pid':expected['pid'],'executable':expected['executable'],'sha256':paired['file_hashes']['PlugIns/Keyboard.appex/Keyboard'],'exact_pids_before':ids,'signal':'SIGTERM','attempts':0,'normal_exit_only':True,'no_force_retry_or_other_process_signal':True}
if ids:
 marker=b/'sigterm-started.json';assert not marker.exists(),'signal already attempted; stop';marker.write_text(json.dumps(receipt,indent=2)+'\n');start=time.monotonic_ns();os.kill(expected['pid'],signal.SIGTERM);receipt['attempts']=1
 deadline=time.monotonic()+10
 while time.monotonic()<deadline and matches():time.sleep(0.2)
 receipt['monotonic_start_ns']=start;receipt['monotonic_end_ns']=time.monotonic_ns()
receipt['exact_pids_after']=matches();receipt['original_extension_exited']=not receipt['exact_pids_after'];receipt['response_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();(b/'sigterm-receipt.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n');print(json.dumps(receipt,ensure_ascii=False));assert receipt['original_extension_exited'],'SIGTERM did not complete; no retry'
