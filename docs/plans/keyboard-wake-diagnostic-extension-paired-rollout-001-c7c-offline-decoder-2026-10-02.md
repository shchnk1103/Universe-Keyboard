# C7-C 离线解析准备（只读固定metadata）

用途仅为未来复制出的KWOPROBE v1字节结构核对，不是产品实现、journal reader或自动根因判定。运行身份/操作归属/borrow有效性仍按[执行包](keyboard-wake-diagnostic-extension-paired-rollout-001-c7c-evidence-chain-plan-2026-10-02.md)人工与独立Quality核验。以下标准库片段已在scratch以18个虚构向量演算；未执行Swift/项目测试或读取设备。

提取`decoder.py`代码到本轮run scratch，再用Python读取本地snapshot.bin传给decode，保存JSON；禁止把模拟器路径直接传给脚本、文件拼接或结果选择性过滤。唯一return verdict为requires_manual_run_binding_and_independent_review，owner_absent_sequences只是定位候选，绝非自动验收。

```python
"""Offline decoder for the fixed content-free KWOPROBE v1 transport only."""
import hashlib
import struct

STAGES = {1: 'appearance', 2: 'armed', 3: 'insertBegin', 4: 'insertEnd',
          5: 'suspendBegin', 6: 'suspendEnd', 7: 'resumeBegin', 8: 'resumeEnd',
          9: 'schedule', 10: 'teardown', 11: 'replacement'}
HEADER_WORDS = 11
RECORD_WORDS = 11
MAX_BYTES = (HEADER_WORDS + 128 * RECORD_WORDS) * 8


def decode(raw):
    # Reject trailing bytes too: never repair, concatenate, or silently truncate a capture.
    if not 176 <= len(raw) <= MAX_BYTES or len(raw) % 8:
        raise ValueError('invalid_size')
    words = struct.unpack('<' + 'Q' * (len(raw) // 8), raw)
    magic, version, incomplete, run_hi, run_lo, process_hi, process_lo, armed, expiry, count, overflow = words[:11]
    if magic != 0x4B574F50524F4245 or version != 1:
        raise ValueError('unsupported_header')
    if incomplete not in (0, 1) or not 1 <= count <= 128 or len(words) != 11 + count * 11:
        raise ValueError('invalid_header')
    if not (run_hi or run_lo) or not (process_hi or process_lo):
        raise ValueError('missing_identity')
    if expiry != min(armed + 600_000_000_000, (1 << 64) - 1):
        raise ValueError('invalid_ttl')
    if overflow and not incomplete:
        raise ValueError('contradictory_completeness')
    events = []
    previous_time = armed
    for index in range(count):
        row = words[11 + index * 11:22 + index * 11]
        seq, timestamp, stage, coordinator, appearance, attempt, owner, receipt, teardown, epoch, revision = row
        if seq != index + 1 or not previous_time <= timestamp < expiry:
            raise ValueError('invalid_sequence_or_time')
        if stage not in STAGES or owner not in (0, 1) or receipt not in (0, 1) or teardown not in (0, 1, 2, 3):
            raise ValueError('invalid_enum')
        if stage == 9 and not owner and receipt:
            raise ValueError('contradictory_schedule')
        if index == 0 and tuple(row) != (1, armed, 2, 0, 0, 0, 0, 0, 0, 0, 0):
            raise ValueError('missing_synthetic_arm')
        previous_time = timestamp
        events.append(dict(zip(('sequence', 'timestamp', 'stage', 'coordinator', 'appearance',
                                'attempt', 'owner', 'receipt', 'teardown', 'epoch', 'revision'), row)))
    attempts = []
    for ordinal in sorted({e['attempt'] for e in events if e['attempt']}):
        rows = [e for e in events if e['attempt'] == ordinal]
        begins = [e for e in rows if e['stage'] == 3]
        ends = [e for e in rows if e['stage'] == 4]
        paired = (len(begins) == len(ends) == 1 and rows[0]['stage'] == 3 and rows[-1]['stage'] == 4
                  and begins[0]['coordinator'] != 0 and begins[0]['appearance'] != 0
                  and all(e['coordinator'] == begins[0]['coordinator']
                          and e['appearance'] == begins[0]['appearance'] for e in rows))
        schedules = [e for e in rows if e['stage'] == 9]
        attempts.append({'ordinal': ordinal, 'paired': paired,
                         'schedules': schedules,
                         'owner_absent_sequences': [e['sequence'] for e in schedules if not e['owner'] and not e['receipt']]
                         if paired and not incomplete and not overflow else []})
    # Completeness is the probe's local buffer flag, not proof of lifecycle/engine/host coverage.
    return {'sha256': hashlib.sha256(raw).hexdigest(), 'bytes': len(raw), 'record_count': count,
            'run_words': [run_hi, run_lo], 'process_words': [process_hi, process_lo],
            'buffer_complete': not incomplete and not overflow,
            'events': events, 'attempts': attempts,
            'verdict': 'requires_manual_run_binding_and_independent_review'}
```

## 离线虚构向量（独立于真实数据）

```python
import json,struct
from pathlib import Path
from decoder import decode
s=Path(__file__).parent
armed=100;expiry=armed+600_000_000_000
synthetic=(1,armed,2,0,0,0,0,0,0,0,0)
def event(seq,stage,attempt=0,owner=1,receipt=0,coord=3,app=1):
 return (seq,armed+seq,stage,coord,app,attempt,owner,receipt,0,1,receipt)
def blob(rows,incomplete=0,overflow=0,version=1,count=None):
 header=(0x4B574F50524F4245,version,incomplete,11,12,21,22,armed,expiry,len(rows) if count is None else count,overflow)
 values=header+sum((tuple(x) for x in rows),());return struct.pack('<'+'Q'*len(values),*values)
base=[synthetic,event(2,2),event(3,3,1),event(4,9,1,1,1),event(5,4,1)]
failure=base+[event(6,3,2,0),event(7,9,2,0),event(8,4,2,0)]
cases=[]
def check(name,raw,expected_error=None,absent_count=None,buffer_complete=None,paired=None):
 try:
  d=decode(raw);assert expected_error is None,name
  if absent_count is not None:assert sum(len(a['owner_absent_sequences']) for a in d['attempts'])==absent_count,name
  if buffer_complete is not None:assert d['buffer_complete']==buffer_complete,name
  if paired is not None:assert d['attempts'][-1]['paired']==paired,name
  cases.append({'case':name,'result':'expected_decode','records':d['record_count'],'absent_sequences':[x for a in d['attempts'] for x in a['owner_absent_sequences']]})
 except ValueError as e:
  assert str(e)==expected_error,(name,str(e),expected_error);cases.append({'case':name,'result':'expected_rejection','reason':str(e)})
check('paired_baseline_then_absent',blob(failure),absent_count=1,buffer_complete=True,paired=True)
check('synthetic_arm_only_no_absence',blob([synthetic]),absent_count=0)
check('coordinator_zero_no_absence',blob([synthetic,event(2,3,1,0,coord=0),event(3,9,1,0,coord=0),event(4,4,1,0,coord=0)]),absent_count=0,paired=False)
check('orphan_schedule_no_absence',blob([synthetic,event(2,9,1,0)]),absent_count=0,paired=False)
check('unclosed_attempt_no_absence',blob([synthetic,event(2,3,1,0),event(3,9,1,0)],incomplete=1),absent_count=0,buffer_complete=False,paired=False)
check('expiry_or_reentrant_no_absence',blob(failure,incomplete=1),absent_count=0,buffer_complete=False)
check('overflow_no_absence',blob(failure,incomplete=1,overflow=1),absent_count=0,buffer_complete=False)
check('no_receipt_owner_present_not_absence',blob([synthetic,event(2,3,1),event(3,9,1),event(4,4,1)]),absent_count=0)
check('duplicated_resume_retained',blob(base+[event(6,7),event(7,7),event(8,8),event(9,8)]),absent_count=0)
check('truncated',blob(failure)[:-1],expected_error='invalid_size')
check('trailing_bytes',blob(failure)+b'12345678',expected_error='invalid_header')
check('count_mismatch',blob(failure,count=7),expected_error='invalid_header')
check('future_version',blob(failure,version=2),expected_error='unsupported_header')
bad=failure.copy();bad[6]=event(7,9,2,0,1);check('absent_with_receipt',blob(bad),expected_error='contradictory_schedule')
bad=failure.copy();bad[6]=event(6,9,2,0);check('duplicate_sequence',blob(bad),expected_error='invalid_sequence_or_time')
check('contradictory_overflow',blob(failure,overflow=1),expected_error='contradictory_completeness')
bad=failure.copy();bad[6]=event(7,99,2,0);check('unknown_stage',blob(bad),expected_error='invalid_enum')
maxrows=[synthetic]+[event(i,7) for i in range(2,129)];check('capacity_128_exact_11352_bytes',blob(maxrows),absent_count=0)
(s/'offline-example-results.json').write_text(json.dumps({'scope':'synthetic fixed transport examples only, not project or runtime tests','cases':cases,'all_expected':True},ensure_ascii=False,indent=2)+'\n')
print(f'{len(cases)} offline transport examples matched; no project code executed.')
```
