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
