"""只读现有 xcresult / 日志；输出 JSON 键均为字符串，不访问模拟器。"""
from pathlib import Path
import json,hashlib,subprocess,sys,re
from collections import Counter
ROOT=Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard')
RUN=Path('/private/tmp/ukey-host-activation-fix-a2-validation-run-20261005')
E=ROOT/'docs/evidence/keyboard-wake-host-activation-fix-001-a2-validation-execution-artifacts'
P=ROOT/'docs/evidence/keyboard-wake-host-activation-fix-001-a2-validation-artifacts'
def nodes(value):
 if isinstance(value,dict):
  if value.get('nodeType')=='Test Case':yield value
  for child in value.values():yield from nodes(child)
 elif isinstance(value,list):
  for child in value:yield from nodes(child)
def identity(v):
 return {'method':v['nodeIdentifier'],'messages':[x['name'] for x in v.get('children',[]) if x.get('nodeType')=='Skip Message']}
def sorted_ids(rows):return sorted(rows,key=lambda x:x['method'])
def results():
 out={'xcresult':{},'gate':{},'runtime':{}}
 for kind in ['rimebridge','app-keyboard','keychain']:
  bundle=RUN/'xcresults'/(kind+'.xcresult')
  args=['xcrun','xcresulttool','get','test-results','tests','--path',str(bundle),'--format','json']
  p=subprocess.run(args,capture_output=True,text=True,check=True)
  cases=list(nodes(json.loads(p.stdout)));counter=Counter(v['result'] for v in cases)
  assert set(counter)<= {'Passed','Skipped'},counter
  row={'command':args,'total':len(cases),'counts':dict(counter),'actual_skips':sorted_ids([identity(v) for v in cases if v['result']=='Skipped'])}
  expected={'rimebridge':(105,85,20),'app-keyboard':(454,444,10),'keychain':(1,1,0)}[kind]
  assert (len(cases),counter['Passed'],counter['Skipped'])==expected
  if kind!='keychain':
   h=json.loads((P/('historical-'+kind+'-skip-list.json')).read_text())
   if 'skips' in h:
    hist=[{'method':x['class']+'/'+x['method']+'()','messages':['Test skipped - '+x['reason']]} for x in h['skips']]
   else:hist=[identity(x) for x in h['tests']]
   row['historical_identity_reason_match']=row['actual_skips']==sorted_ids(hist);assert row['historical_identity_reason_match']
  if kind=='app-keyboard':
   gate=[v for v in cases if v['nodeIdentifier'].startswith('KeyboardHostLifecycleRecoveryGateTests/')]
   methods=json.loads((E/'required-gate-methods.json').read_text())['methods']
   actual=[v['name'].removesuffix('()') for v in gate]
   assert len(gate)==23 and len(set(actual))==23 and set(actual)==set(methods) and all(v['result']=='Passed' for v in gate)
   frozen=json.loads((E/'gate-23-actual-results.json').read_text())
   assert sorted((v['nodeIdentifier'],v['result']) for v in gate)==sorted((v['nodeIdentifier'],v['result']) for v in frozen)
   out['gate']={'23_methods_match':True,'all_passed':True,'cases':[{'method':v['nodeIdentifier'],'result':v['result']} for v in gate]}
  out['xcresult'][kind]=row
 steps=json.loads((E/'step-receipts.json').read_text());fmt=[v for v in steps if v['step']=='A2-V-0-format'];assert len(fmt)==1 and fmt[0]['exit_code']==0 and 'lint --strict' in fmt[0]['command']
 assert Path(fmt[0]['log']).read_bytes()==b''
 out['strict_lint']={'receipt':fmt[0],'empty_log':True}
 core=(RUN/'logs/A2-V-1-keyboardcore.log').read_text().splitlines();hits=[{'line':i+1,'text':v} for i,v in enumerate(core) if 'Executed 1194 tests' in v and '0 failures' in v];assert hits
 rel=(RUN/'logs/A2-V-4-release-build.log').read_text().splitlines();success=[i+1 for i,v in enumerate(rel) if v.strip()=='** BUILD SUCCEEDED **'];assert success
 out['core']={'1194_zero_failures':hits};out['release']={'build_succeeded_lines':success,'release_publication':False}
 inventory=json.loads((ROOT/'docs/evidence/keyboard-wake-host-activation-fix-001-f3-f4-prepared-artifacts/runtime-log-inventory.json').read_text())
 rows=[]
 for row in inventory:
  log=RUN/'logs'/row['log'];b=log.read_bytes();assert hashlib.sha256(b).hexdigest()==row['log_sha256']
  lines=b.decode().splitlines();i=row['line']-1;assert lines[i]==row['text']
  start=next((v for v in reversed(lines[:i]) if v.startswith('Test Case ') and 'started.' in v),None)
  assert start==row['last_started_test']
  end=next((v for v in lines[i+1:] if v.startswith('Test Case ') and ('passed (' in v or 'failed (' in v)),None)
  rows.append({'log':row['log'],'line':row['line'],'kind':row['kind'],'text':row['text'],'last_started_test':start,'next_test_result':end})
 count=dict(Counter(v['kind'] for v in rows));assert count=={'rime_error':3,'iohid_loader_error':8,'iohid_factory_companion':8}
 source=ROOT/'Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift';lines=source.read_text().splitlines();idx=next(i for i,v in enumerate(lines) if 'func testRealDeployerFailsClosedForMalformedSchema' in v)
 out['runtime']={'counts':count,'rows':rows,'malformed_fixture_source':{'path':str(source),'start_line':idx+1,'text':'\n'.join(lines[idx:idx+17])},'impact_not_automatically_accepted':True}
 return out
if __name__=='__main__':
 output=Path(sys.argv[1]);data=results();blob=json.dumps(data,ensure_ascii=False,indent=2)+'\n'
 output.write_text(blob);assert json.loads(output.read_text())==data
 print(json.dumps({'ok':True,'output':str(output),'sha256':hashlib.sha256(output.read_bytes()).hexdigest(),'gate':23,'skip_identities':30,'runtime_counts':data['runtime']['counts']}))
