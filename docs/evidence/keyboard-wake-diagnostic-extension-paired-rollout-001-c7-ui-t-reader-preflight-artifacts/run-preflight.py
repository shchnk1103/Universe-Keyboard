import json,pathlib,hashlib,subprocess,time
b=pathlib.Path('/private/tmp/ukey-wake-ui-t-reader-preflight-20261003');r=pathlib.Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard');h=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
reader=b/'reader.py';results=[]
for lane in ['S','P']:
 old=r/f'docs/reviews/c7-ui-t-split-{lane.lower()}-packet-2026-10-03.json';p=json.loads(old.read_text());p.pop('packet_digest_sha256')
 p['status']='Coordinator reader preflight only; no independent execution authorization';p['budget']={'independent_execution':'NOT AUTHORIZED by this preflight packet'}
 for key in ['budget_clock_start_epoch','budget_clock_start_utc','budget_clock_deadline_epoch']:p.pop(key,None)
 p['allowed_content_inputs']={path:h(path) for path in p['allowed_content_inputs']};p['allowed_content_inputs'][str(reader)]=h(reader)
 p['packet_digest_sha256']=hashlib.sha256(json.dumps(p,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode()).hexdigest();pp=b/f'{lane}-preflight-packet.json';pp.write_text(json.dumps(p,ensure_ascii=False,indent=2)+'\n');e=b/f'{lane}-identity.json';e.write_text(json.dumps({'whole_file_digest':h(pp),'self_digest':p['packet_digest_sha256']},indent=2))
 start=time.time();a=subprocess.run(['python3',str(reader),'--packet',str(pp),'--external',str(e),'--output',str(b/f'{lane}-fresh')],capture_output=True,text=True);assert a.returncode==0,a.stderr
 results.append({'case':lane+' fresh success','exit':a.returncode,'elapsed_including_output_write_and_readback':time.time()-start,'stdout':json.loads(a.stdout)})
# Two meaningful fail-closed cases exercise the exact past hazards.
for name,packet,external in [('old-input-drift',r/'docs/reviews/c7-ui-t-split-s-packet-2026-10-03.json',pathlib.Path('/private/tmp/ukey-wake-ui-t-split-review-20261003/S/external-identity.json')),('packet-digest-mismatch',b/'S-preflight-packet.json',b/'wrong-identity.json')]:
 if name=='packet-digest-mismatch':(b/'wrong-identity.json').write_text(json.dumps({'whole_file_digest':'0'*64}))
 start=time.time();out=b/name;a=subprocess.run(['python3',str(reader),'--packet',str(packet),'--external',str(external),'--output',str(out)],capture_output=True,text=True);assert a.returncode!=0
 u=json.loads((out/'usage.json').read_text());assert u['coverage']=='Partial' and u['report_sha256']==h(out/'report.md');assert not (out/'reader-result.json').exists()
 results.append({'case':name,'exit':a.returncode,'error':u['error'],'failure_report_usage_roundtrip':True,'elapsed_including_output_write_and_readback':time.time()-start})
(b/'preflight-receipt.json').write_text(json.dumps({'role':'Coordinator preflight; not independent acceptance','reader_sha256':h(reader),'cases':results},ensure_ascii=False,indent=2)+'\n');print(json.dumps(results,ensure_ascii=False))
