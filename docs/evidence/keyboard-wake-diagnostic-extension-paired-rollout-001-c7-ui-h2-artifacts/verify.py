from pathlib import Path
import json,subprocess,hashlib,struct,uuid,plistlib
s=Path('/private/tmp/ukey-wake-probe-ui-h2-20261002');h=Path('/private/tmp/ukey-wake-probe-ui-candidate-20261002');r=Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard')
def sha(raw):return hashlib.sha256(raw).hexdigest()
def run(a):
 p=subprocess.run(a,capture_output=True,text=True);return {'argv':a,'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
def parse(raw):
 assert raw[:4]==b'\xcf\xfa\xed\xfe';assert struct.unpack_from('<I',raw,4)[0]==0x100000c
 count,bytes_=struct.unpack_from('<II',raw,16);off=32;ids=[]
 for _ in range(count):
  cmd,size=struct.unpack_from('<II',raw,off);assert size>=8 and off+size<=32+bytes_<=len(raw)
  if cmd==0x1b:ids.append(str(uuid.UUID(bytes=raw[off+8:off+24])).upper())
  off+=size
 assert off==32+bytes_ and len(ids)==1;return ids[0]
allrows=[]
for cfg,label in [('Debug','ordinary-debug'),('Release','ordinary-release')]:
 result=json.loads((s/(label+'-result.json')).read_text());assert result['exit_code']==0
 summary=run(['xcrun','xcresulttool','get','build-results','--path',str(s/(label+'.xcresult'))]);assert summary['exit']==0;xc=json.loads(summary['stdout']);assert xc['status']=='succeeded' and xc['errorCount']==0;(s/(label+'-xcresult.json')).write_text(summary['stdout']);(s/(label+'-xcresult-read.json')).write_text(json.dumps(summary,indent=2))
 app=s/(label+'-DerivedData')/'Build/Products'/f'{cfg}-iphonesimulator/Universe Keyboard.app';ext=app/'PlugIns/Keyboard.appex';assert app.is_dir() and ext.is_dir()
 files={str(p.relative_to(app)):sha(p.read_bytes()) for p in sorted(app.rglob('*')) if p.is_file()};assert not any('.xctest' in k or 'XCTest' in k for k in files)
 machos=[]
 for p in sorted(app.rglob('*')):
  if not p.is_file():continue
  raw=p.read_bytes()
  if raw[:4]!=b'\xcf\xfa\xed\xfe':continue
  identity=parse(raw);nm=run(['xcrun','nm',str(p)]);assert nm['exit']==0;matches=[l for l in nm['stdout'].splitlines() if any(token in l for token in ['installWakeOwnerProbeButton','setWakeOwnerProbeButton','installWakeOwnerProbeControls','refreshWakeOwnerProbeControls','handleWakeOwnerProbeButton','WakeOwnerProbeTouchObserver','onWakeOwnerProbeTouch','wakeOwnerProbeTouch','wakeOwnerProbeWillAppear','wakeOwnerProbeWillDisappear','recordWakeOwnerProbe','wakeOwnerProbeExportReady'])];assert not matches,(p,matches)
  du=run(['xcrun','dwarfdump','--uuid',str(p)]);assert du['exit']==0 and identity in du['stdout'];nmfile=label+'-'+str(p.relative_to(app)).replace('/','_')+'-nm.txt';(s/nmfile).write_text(nm['stdout']);machos.append({'path':str(p.relative_to(app)),'sha256':sha(raw),'uuid':identity,'bytes':len(raw),'nm_exit':nm['exit'],'nm_stderr':nm['stderr'],'nm_archive':nmfile,'probe_ui_export_symbols':matches,'dwarfdump':du})
 assert machos
 bundle=[]
 for p in [app,ext]:
  info=plistlib.loads((p/'Info.plist').read_bytes());sig=run(['codesign','--verify','--deep','--strict',str(p)]);assert sig['exit']==0;bundle.append({'bundle_id':info['CFBundleIdentifier'],'version':info['CFBundleShortVersionString'],'build':info['CFBundleVersion'],'signature':sig})
 lines=[]
 for line in (s/(label+'-build.log')).read_text().splitlines():
  if '/swiftc ' in line and ('-module-name Keyboard ' in line or '-module-name Universe_Keyboard ' in line):
   isdebug='-D DEBUG' in line or '-DDEBUG' in line;probe='KEYBOARD_WAKE_OWNER_PROBE' in line;assert '-swift-version 6 ' in line and '-warnings-as-errors' in line and not probe;assert isdebug==(cfg=='Debug');lines.append({'module':'Keyboard' if '-module-name Keyboard ' in line else 'Universe_Keyboard','swift6':True,'warnings_as_errors':True,'debug':isdebug,'probe':probe,'line':line})
 assert {x['module'] for x in lines}=={'Keyboard','Universe_Keyboard'}
 row={'mode':label,'configuration':cfg,'build_result':result,'xcresult_status':xc['status'],'warning_count':xc['warningCount'],'error_count':xc['errorCount'],'app_root':str(app),'file_count':len(files),'payload_sha256':sha(json.dumps(files,sort_keys=True,separators=(',',':')).encode()),'files':files,'machos':machos,'bundles':bundle,'compiler_rows':lines,'probe_ui_export_absent':True,'test_payload_absent':True,'installed':False,'runtime_verified':False};(s/(label+'-products.json')).write_text(json.dumps(row,indent=2));allrows.append(row)
old=json.loads((h/'paired-products.json').read_text());assert any('wakeOwnerProbeExportReady' in str(x['probe_ui_symbols']) and 'installWakeOwnerProbeButton' in str(x['probe_ui_symbols']) for x in old['machos'])
assert all(sha((Path(old['app_root'])/k).read_bytes())==v for k,v in old['file_hashes'].items())
m=json.loads((s/'build-input-manifest.json').read_text());checks={}
for name in ['source_and_build_inputs','vendor_files']:
 d=m[name];bad=[k for k,v in d.items() if not (r/k).is_file() or sha((r/k).read_bytes())!=v];assert not bad;checks[name]={'count':len(d),'mismatches':bad}
summary={'h1_positive_candidate':old['candidate'],'h1_payload78_unchanged':True,'h2_modes':[{'mode':x['mode'],'file_count':x['file_count'],'macho_count':len(x['machos']),'payload_sha256':x['payload_sha256'],'exit':x['build_result']['exit_code'],'elapsed_seconds':x['build_result']['elapsed_seconds'],'warning_count':x['warning_count'],'ui_export_absent':True} for x in allrows],'postbuild_inputs':checks,'scope':'host isolation only; ordinary Debug Core DEBUG hook not asserted absent; no runtime/Release/Gate'};(s/'verification-summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
