from pathlib import Path
import json,hashlib,subprocess,concurrent.futures,time
r=Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard');base=Path('/private/tmp/ukey-wake-ui-t-split-r2-20261003/skip-reasons');base.mkdir(exist_ok=True);d=r/'docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-artifacts';jobs=[]
for suite,name in [('Rime','Rime-skipped-tests.json'),('AppKeyboard','AppKeyboard-skipped-tests.json')]:
 for row in json.loads((d/name).read_text()):jobs.append((suite,row['nodeIdentifier']))
def collect(job):
 suite,identity=job;bundle=f'/private/tmp/ukey-wake-ui-t1-execution-20261003/{suite}.xcresult';argv=['xcrun','xcresulttool','get','test-results','test-details','--path',bundle,'--compact','--test-id',identity];p=subprocess.run(argv,capture_output=True,text=True);assert p.returncode==0,(identity,p.stderr);details=json.loads(p.stdout);assert details['testResult']=='Skipped' and details['testIdentifier']==identity
 devices=[x['deviceId'] for x in details['devices']];assert devices==['405D994F-28CB-4F89-BB22-B64AD81C05A2']
 reasons=[]
 def visit(node):
  if isinstance(node,dict):
   if str(node.get('name','')).startswith('Test skipped - '):reasons.append(node['name'])
   for value in node.values():visit(value)
  elif isinstance(node,list):
   for value in node:visit(value)
 visit(details['testRuns']);assert reasons,identity
 filename=f'{suite}-{hashlib.sha256(identity.encode()).hexdigest()[:16]}.json';(base/filename).write_text(json.dumps(details,ensure_ascii=False,indent=2)+'\n')
 return {'suite':suite,'testIdentifier':identity,'result':'Skipped','device_ids':devices,'reasons':reasons,'detail_file':filename,'detail_sha256':hashlib.sha256((base/filename).read_bytes()).hexdigest(),'read_argv':argv}
start=time.time()
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:rows=list(pool.map(collect,jobs))
receipt={'role':'Coordinator same historical xcresult read; not independent acceptance','records':rows,'record_count':len(rows),'all_have_explicit_reason':all(x['reasons'] for x in rows),'no_test_rerun':True,'elapsed_seconds':time.time()-start};(base/'skip-reasons-index.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n');print('Collected',len(rows),'all explicit reasons',receipt['all_have_explicit_reason']);print(json.dumps({'unique_reasons':sorted({reason for row in rows for reason in row['reasons']})},ensure_ascii=False))
