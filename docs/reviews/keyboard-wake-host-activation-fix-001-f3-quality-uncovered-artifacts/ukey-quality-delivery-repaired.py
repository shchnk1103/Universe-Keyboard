"""校验已冻结packet身份，写作者提供的报告与真实用量，并立即读回。"""
from pathlib import Path
import json,hashlib,datetime,sys

def deliver(packet_path,expected_sha,draft_path,calls):
 packet_path=Path(packet_path).resolve();blob=packet_path.read_bytes()
 assert hashlib.sha256(blob).hexdigest()==expected_sha,'packet SHA mismatch'
 packet=json.loads(blob);q=Path(packet['output_directory']).resolve()
 # packet是独立冻结身份，不要求它把自己的路径列进allowed_files。
 assert q.parent==packet_path.parent and q.name=='quality','unexpected output root'
 draft_path=Path(draft_path).resolve();assert draft_path.parent==q,'draft outside output root'
 draft=json.loads(draft_path.read_text());assert draft['report'].strip()
 assert draft['status'] in ['Pass','Pass with conditions','Partial']
 now=datetime.datetime.now(datetime.timezone.utc);start=datetime.datetime.fromisoformat(packet['start_utc']);elapsed=(now-start).total_seconds()
 assert 0<=calls<=packet['budget']['calls']
 usage={'reviewer':packet['reviewer'],'packet_sha256':expected_sha,'start_utc':packet['start_utc'],'end_utc':now.isoformat(),'elapsed_seconds':elapsed,'actual_tool_calls':calls,'budget_calls':packet['budget']['calls'],'budget_wall_seconds':packet['budget']['wall_seconds'],'within_call_budget':True,'within_wall_budget':elapsed<=packet['budget']['wall_seconds'],'status':draft['status'],'covered':draft['covered'],'uncovered':draft['uncovered'],'stop_reason':draft['stop_reason']}
 if draft['status']!='Partial':assert not draft['uncovered'] and usage['within_wall_budget']
 files={'review.md':draft['report'].rstrip()+'\n','usage.json':json.dumps(usage,ensure_ascii=False,indent=2)+'\n'}
 for name,text in files.items():
  f=q/name;temporary=q/(name+'.tmp');temporary.write_text(text);temporary.replace(f);assert f.read_text()==text
 hashes={name:hashlib.sha256((q/name).read_bytes()).hexdigest() for name in ['ack.json','review.md','usage.json']}
 (q/'delivery-readback.json').write_text(json.dumps({'hashes':hashes,'actual_calls_including_this_call':calls,'readback_ok':True},indent=2)+'\n')
 return hashes
if __name__=='__main__':print(json.dumps(deliver(sys.argv[1],sys.argv[2],sys.argv[3],int(sys.argv[4]))))
