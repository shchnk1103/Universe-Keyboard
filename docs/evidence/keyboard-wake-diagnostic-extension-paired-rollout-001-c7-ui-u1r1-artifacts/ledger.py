from pathlib import Path
import sys,json,datetime,time,hashlib
b=Path('/private/tmp/ukey-wake-ui-u1r1-execution-20261003');e=json.loads(sys.argv[1]);e['writer_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();e['writer_monotonic_ns']=time.monotonic_ns()
if 'raw_result' in e:
 raw=(json.dumps(e.pop('raw_result'),ensure_ascii=False,indent=2)+'\n').encode();p=b/f"debug-call-{e['sequence']:02d}-raw.json";p.write_bytes(raw);e['raw_receipt_file']=str(p);e['raw_receipt_sha256']=hashlib.sha256(raw).hexdigest()
with (b/'debug-command-ledger.jsonl').open('a') as f:f.write(json.dumps(e,ensure_ascii=False)+'\n')
print(json.dumps({k:v for k,v in e.items() if k in ['sequence','phase','writer_utc','writer_monotonic_ns','raw_receipt_sha256']}))
