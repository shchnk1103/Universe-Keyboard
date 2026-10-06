from pathlib import Path
import json,subprocess,hashlib,plistlib,struct,uuid
s=Path('/private/tmp/ukey-wake-probe-ui-candidate-20261002');app=s/'CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app';ext=app/'PlugIns/Keyboard.appex';assert app.is_dir() and ext.is_dir()
def sha(b):return hashlib.sha256(b).hexdigest()
def run(argv):
 p=subprocess.run(argv,capture_output=True,text=True);return {'argv':argv,'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
def macho(raw):
 assert raw[:4]==b'\xcf\xfa\xed\xfe','expected thin little endian MachO64'
 cpu,ncmds,cmdbytes=struct.unpack_from('<IxxxxII',raw,4);assert cpu==0x100000c,'expected arm64';cursor=32;uuids=[];sections=[]
 for _ in range(ncmds):
  cmd,size=struct.unpack_from('<II',raw,cursor);assert size>=8 and cursor+size<=32+cmdbytes<=len(raw)
  if cmd==0x1b:uuids.append(str(uuid.UUID(bytes=raw[cursor+8:cursor+24])).upper())
  if cmd==0x19:
   count=struct.unpack_from('<I',raw,cursor+64)[0];assert 72+count*80<=size
   for i in range(count):
    pos=cursor+72+i*80;name=raw[pos:pos+16].rstrip(b'\0');segment=raw[pos+16:pos+32].rstrip(b'\0');address,length,offset=struct.unpack_from('<QQI',raw,pos+32)
    if name==b'__entitlements' and segment==b'__TEXT':
     assert offset+length<=len(raw);sections.append({'offset':offset,'bytes':length,'data':raw[offset:offset+length]})
  cursor+=size
 assert len(uuids)==1 and cursor==32+cmdbytes
 return uuids[0],sections
files={str(p.relative_to(app)):sha(p.read_bytes()) for p in sorted(app.rglob('*')) if p.is_file()};assert not any('.xctest' in n or 'XCTest' in n for n in files),'contains test payload'
rows=[];entrows=[];mrows=[]
for b,expected,stage,stem,generated in [(app,'com.DoubleShy0N.Universe-Keyboard','Universe Keyboard.build','app','Universe Keyboard.app-Simulated.xcent'),(ext,'com.DoubleShy0N.Universe-Keyboard.Keyboard','Keyboard.build','keyboard','Keyboard.appex-Simulated.xcent')]:
 info=plistlib.loads((b/'Info.plist').read_bytes());assert info['CFBundleIdentifier']==expected;exe=b/info['CFBundleExecutable'];raw=exe.read_bytes();u,sections=macho(raw);assert len(sections)==1
 sign=run(['codesign','--verify','--deep','--strict',str(b)]);assert sign['exit']==0,sign
 display=run(['codesign','--display','--entitlements',':-',str(b)]);assert display['exit']==0
 x=s/'CandidateDerivedData/Build/Intermediates.noindex/Universe Keyboard.build/Debug-iphonesimulator'/stage/generated;assert x.is_file();data=sections[0]['data'];xb=x.read_bytes();assert data==xb,'embedded section must equal exact generated xcent bytes (no stripping/normalizing)';ent=plistlib.loads(data);assert ent['com.apple.security.application-groups']==['group.com.DoubleShy0N.Universe-Keyboard'];appid=ent.get('application-identifier',ent.get('com.apple.application-identifier'));assert appid and appid.endswith('.'+expected)
 (s/(stem+'-Simulated.xcent')).write_bytes(xb);(s/(stem+'-embedded-entitlements.plist')).write_bytes(data);(s/(stem+'-codesign-display.txt')).write_text(display['stdout'])
 row={'path':str(b),'bundle_id':expected,'version':info['CFBundleShortVersionString'],'build':info['CFBundleVersion'],'executable':info['CFBundleExecutable'],'info_sha256':sha((b/'Info.plist').read_bytes()),'executable_sha256':sha(raw),'executable_uuid':u,'sign_verify':sign,'codesign_entitlements_display':display};rows.append(row)
 entrows.append({'bundle_id':expected,'mach_o_relative':str(exe.relative_to(app)),'macho_sha256':sha(raw),'macho_uuid':u,'xcent_locator':str(x),'xcent_copy':stem+'-Simulated.xcent','xcent_sha256':sha(xb),'embedded_section_offset':sections[0]['offset'],'embedded_section_bytes':sections[0]['bytes'],'embedded_section_sha256':sha(data),'exact_byte_equal':True,'entitlements':ent,'runtime_verified':False})
assert rows[0]['version']==rows[1]['version'] and rows[0]['build']==rows[1]['build']
for p in sorted(app.rglob('*')):
 if not p.is_file():continue
 raw=p.read_bytes()
 if raw[:4]!=b'\xcf\xfa\xed\xfe':continue
 u,_=macho(raw);nm=run(['xcrun','nm',str(p)]);assert nm['exit']==0
 syms=[l for l in nm['stdout'].splitlines() if 'wakeOwnerProbeExportReady' in l or 'installWakeOwnerProbeButton' in l];du=run(['xcrun','dwarfdump','--uuid',str(p)]);assert du['exit']==0 and u in du['stdout'];mrows.append({'path':str(p.relative_to(app)),'sha256':sha(raw),'bytes':len(raw),'uuid':u,'dwarfdump':du,'probe_ui_symbols':syms})
assert any('wakeOwnerProbeExportReady' in str(m['probe_ui_symbols']) for m in mrows if m['path']=='PlugIns/Keyboard.appex/Keyboard.debug.dylib')
payload=sha(json.dumps(files,sort_keys=True,separators=(',',':')).encode());binding={'build_input_manifest_sha256':sha((s/'build-input-manifest.json').read_bytes()),'candidate_command_sha256':sha((s/'candidate-command.json').read_bytes()),'payload_digest_sha256':payload,'entitlement_rows_sha256':sha(json.dumps(entrows,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode())};candidate=sha(json.dumps(binding,sort_keys=True,separators=(',',':')).encode());products={'candidate':candidate,'candidate_digest_rule':'SHA256(sorted compact ASCII JSON of binding keys)','binding':binding,'app_root':str(app),'file_count':len(files),'file_hashes':files,'payload_digest_sha256':payload,'bundles':rows,'machos':mrows,'contains_test_host':False,'installed':False,'runtime_verified':False,'dsyms':[str(p) for p in (s/'CandidateDerivedData/Build/Products/Debug-iphonesimulator').glob('*.dSYM')]};(s/'paired-products.json').write_text(json.dumps(products,ensure_ascii=False,indent=2)+'\n');(s/'simulator-entitlements.json').write_text(json.dumps({'bundles':entrows,'runtime_verified':False},ensure_ascii=False,indent=2)+'\n');print(json.dumps({'candidate':candidate,'payload':payload,'files':len(files),'machos':len(mrows),'sign_verify':[b['sign_verify']['exit'] for b in rows],'entitlements_exact_byte_equal':[e['exact_byte_equal'] for e in entrows],'dsyms':products['dsyms']},indent=2))
