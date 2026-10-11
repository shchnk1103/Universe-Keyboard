from pathlib import Path
import hashlib,json,plistlib,subprocess,re,datetime,stat
r=Path('/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard');b=Path('/private/tmp/ukey-host-activation-fix-f4-p-build-20261005')
receipt=json.loads((b/'build-receipt.json').read_text());assert receipt['exit_code']==0 and not receipt['timeout'],'build did not succeed'
log=(b/'logs/build.log').read_text();assert '** BUILD SUCCEEDED **' in log
assert not re.search(r'^.*\.swift:\d+:\d+: (?:warning|error):',log,re.M),'Swift diagnostic present'
assert not re.search(r'^.*\berror:',log,re.M),'build error diagnostic present'
flags={}
for module in ['Keyboard','Universe_Keyboard']:
 rows=[{'line':i+1,'text':line} for i,line in enumerate(log.splitlines()) if '-module-name '+module+' ' in line and 'swiftc ' in line]
 assert rows,module+' compiler invocation absent'
 for row in rows:
  line=row['text'];assert '-DDEBUG' in line and '-DKEYBOARD_WAKE_OWNER_PROBE' in line,line
  assert '-swift-version 6' in line and '-warnings-as-errors' in line,line
  assert 'T9_P3_D1_LIFECYCLE_HARNESS' not in line and 'T9_RESPONSIVE_CANARY_INTERNAL' not in line,line
 flags[module]=rows
app=b/'CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app';assert app.is_dir()
rows=[]
for f in sorted(app.rglob('*')):
 rel=str(f.relative_to(app));assert '.xctest' not in rel and 'XCTest' not in rel and 'libXCTest' not in rel,'test-host injection '+rel
 if f.is_symlink():rows.append({'path':rel,'type':'symlink','target':str(f.readlink())})
 elif f.is_file():
  blob=f.read_bytes();rows.append({'path':rel,'bytes':len(blob),'sha256':hashlib.sha256(blob).hexdigest(),'mode':oct(stat.S_IMODE(f.stat().st_mode))})
ident=[];commands=[];executable_group=[]
for target in [app,app/'PlugIns/Keyboard.appex']:
 info=plistlib.loads((target/'Info.plist').read_bytes());exe=target/info['CFBundleExecutable']
 modules=[]
 for f in [exe,target/(info['CFBundleExecutable']+'.debug.dylib')]:
  assert f.exists(),f
  argv=['dwarfdump','--uuid',str(f)];p=subprocess.run(argv,capture_output=True,text=True,check=True);commands.append({'argv':argv,'exit_code':p.returncode,'stdout':p.stdout,'stderr':p.stderr})
  symbols=subprocess.run(['nm',str(f)],capture_output=True,text=True,check=True).stdout
  modules.append({'path':str(f.relative_to(app)),'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'uuid_output':p.stdout.strip(),'probe_export_symbols':[line.strip() for line in symbols.splitlines() if 'wakeOwnerProbeExportReady' in line],'host_active_symbols':[line.strip() for line in symbols.splitlines() if 'extensionHostDidBecomeActive' in line],'host_resign_symbols':[line.strip() for line in symbols.splitlines() if 'extensionHostWillResignActive' in line]})
 argv=['codesign','--verify','--deep','--strict',str(target)];p=subprocess.run(argv,capture_output=True,text=True);commands.append({'argv':argv,'exit_code':p.returncode,'stdout':p.stdout,'stderr':p.stderr});assert p.returncode==0,p.stderr
 z=subprocess.run(['xcrun','otool','-s','__TEXT','__entitlements',str(exe)],capture_output=True,text=True,check=True);raw=b''
 for line in z.stdout.splitlines():
  if re.match(r'^[0-9a-fA-F]{16}\s',line):
   for token in line.split()[1:]:
    if re.fullmatch(r'[0-9a-fA-F]{8}',token):raw+=bytes.fromhex(token)[::-1]
    elif re.fullmatch(r'[0-9a-fA-F]{2}',token):raw+=bytes.fromhex(token)
 ent=plistlib.loads(raw.rstrip(b'\x00'));assert ent['com.apple.security.application-groups']==['group.com.DoubleShy0N.Universe-Keyboard']
 executable_group.append({'module':str(exe.relative_to(app)),'section':'__TEXT,__entitlements','plist':ent,'section_sha256':hashlib.sha256(raw).hexdigest()})
 ident.append({'bundle_identifier':info['CFBundleIdentifier'],'version':info['CFBundleShortVersionString'],'build':info['CFBundleVersion'],'relative_root':str(target.relative_to(app)),'modules':modules,'codesign_verify':True})
keyboard=ident[1];mods=keyboard['modules'];assert any(m['probe_export_symbols'] for m in mods),'probe export missing';assert any(m['host_active_symbols'] for m in mods);assert any(m['host_resign_symbols'] for m in mods)
count=0
for name in ['source-tree-manifest.json','app-source-manifest.json','vendor-byte-manifest.json']:
 d=json.loads((b/name).read_text());expected={x['path'] for x in d['files']};roots=d['roots_or_vendor'];roots=[roots] if isinstance(roots,str) else roots;actual=set()
 for root in roots:
  for f in (r/root).rglob('*'):
   if not f.is_file():continue
   rel=str(f.relative_to(r))
   if name=='source-tree-manifest.json' and ('.xcframework' in rel or rel.startswith('Packages/RimeBridge/TestTool/') or f.name=='.DS_Store' or 'xcuserdata' in f.parts or any(x.endswith('.xcuserdatad') for x in f.parts)):continue
   if name=='app-source-manifest.json' and f.name=='.DS_Store':continue
   actual.add(rel)
 assert actual==expected,name+' membership drift'
 for row in d['files']:
  blob=(r/row['path']).read_bytes();assert len(blob)==row['bytes'] and hashlib.sha256(blob).hexdigest()==row['sha256'],row['path'];count+=1
for row in json.loads((b/'pinned-inputs.json').read_text()):assert hashlib.sha256((r/row['path']).read_bytes()).hexdigest()==row['sha256']
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip()=='84b9c19227330b0fe6ff391be001ee398010fd6a'
assert subprocess.check_output(['git','branch','--show-current'],cwd=r,text=True).strip()=='codex/keyboard-wake-v3-compatibility-gate'
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r,text=True).strip()
regular=[v for v in rows if 'sha256' in v];aggregate=hashlib.sha256(''.join(f"{v['path']}\t{v['bytes']}\t{v['sha256']}\n" for v in regular).encode()).hexdigest()
for name,data in [('paired-products.json',ident),('payload-manifest.json',rows),('actual-compiler-flags.json',flags),('simulated-entitlements.json',executable_group),('inspection-commands.json',commands)]:
 (b/name).write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
(b/'dirty-after.txt').write_bytes(subprocess.check_output(['git','status','--porcelain=v1','--untracked-files=all'],cwd=r))
other=[{'line':i+1,'text':line} for i,line in enumerate(log.splitlines()) if re.search(r'\bwarning:',line)]
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'status':'F4-P build and byte freeze complete; not installation/runtime acceptance','app_path':str(app),'regular_files':len(regular),'file_bytes':sum(v['bytes'] for v in regular),'payload_sha256':aggregate,'sha_algorithm':'raw bytes per-file; sorted path TAB bytes TAB sha LF listing SHA256','1156_inputs_and_membership_match':count==1156,'13_pinned_match':True,'probe_export_present':True,'real_host_symbols_present':True,'standalone_no_xctest_or_injection':True,'two_level_signature_and_embedded_group_pass':True,'non_swift_warnings':other,'test_run':False,'device_instance_operated':False,'install':False,'source_written':False,'next':'independent scoped product/flag applicability preflight and F4-I fresh backup, all separately authorized'}
(b/'freeze-receipt.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n');print(json.dumps(result,ensure_ascii=False))
