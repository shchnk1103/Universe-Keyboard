from pathlib import Path
import json,subprocess,time,datetime
s=Path('/private/tmp/ukey-wake-probe-ui-h2-20261002')
for label in ['ordinary-debug','ordinary-release']:
 c=json.loads((s/(label+'-command.json')).read_text());start=datetime.datetime.now(datetime.timezone.utc).isoformat();t=time.monotonic()
 with (s/(label+'-build.log')).open('w') as out:p=subprocess.run(c['argv'],cwd=c['cwd'],stdout=out,stderr=subprocess.STDOUT)
 result={'start_utc':start,'end_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'elapsed_seconds':time.monotonic()-t,'exit_code':p.returncode,'command':label+'-command.json'};(s/(label+'-result.json')).write_text(json.dumps(result,indent=2));print(label,json.dumps(result),flush=True)
 if p.returncode:raise SystemExit(p.returncode)
