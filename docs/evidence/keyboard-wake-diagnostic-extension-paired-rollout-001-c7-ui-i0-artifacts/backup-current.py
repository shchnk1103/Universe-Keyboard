"""I0 private full backup. Read live state; never mutate Simulator data."""
from pathlib import Path
import os,stat,subprocess,json,hashlib,datetime,plistlib,time
b=Path('/private/tmp/ukey-wake-ui-i0-20261003');udid='405D994F-28CB-4F89-BB22-B64AD81C05A2';bid='com.DoubleShy0N.Universe-Keyboard';gid='group.com.DoubleShy0N.Universe-Keyboard'
h=lambda data:hashlib.sha256(data).hexdigest()
def run(argv):
 p=subprocess.run(argv,capture_output=True,text=True);assert p.returncode==0,(argv,p.stderr);return p.stdout.strip()
def discover():return {kind:run(['xcrun','simctl','get_app_container',udid,bid,kind]) for kind in ['app','data','groups']}
c=discover();assert c==json.loads((b/'container-discovery.json').read_text());groupmap=dict(line.split('\t',1) for line in c['groups'].splitlines());assert set(groupmap)=={gid};roots={'main-data':Path(c['data']),'app-group':Path(groupmap[gid]),'installed-app':Path(c['app'])}
def absent():
 assert not [line for line in run(['ps','-axo','pid=,comm=']).splitlines() if c['app'] in line],'target process returned; stop'
def attrs(path):
 names=run(['/usr/bin/xattr','-s',str(path)]).splitlines()
 return {key:h(bytes.fromhex(run(['/usr/bin/xattr','-p','-x','-s',key,str(path)]))) for key in sorted(names)}
def inventory(root):
 rows={}
 def visit(path,relative):
  st=path.lstat();row={'mode':stat.S_IMODE(st.st_mode),'uid':st.st_uid,'gid':st.st_gid,'xattrs':attrs(path)}
  if stat.S_ISLNK(st.st_mode):
   target=os.readlink(path);assert (path.parent/target).resolve().is_relative_to(root.resolve()),'external symlink; stop';row.update(kind='symlink',target=target)
  elif stat.S_ISDIR(st.st_mode):row['kind']='directory'
  elif stat.S_ISREG(st.st_mode):row.update(kind='file',size=st.st_size,sha256=h(path.read_bytes()))
  else:raise RuntimeError('special file; stop')
  rows[relative]=row
  if row['kind']=='directory':
   for child in sorted(path.iterdir()):visit(child,str(child.relative_to(root)))
 visit(root,'.');return rows
absent();before={name:inventory(root) for name,root in roots.items()};(b/'before-inventories.json').write_text(json.dumps(before,ensure_ascii=False,indent=2)+'\n')
backup=b/'backup';backup.mkdir(mode=0o700,exist_ok=False)
for name,root in roots.items():run(['/usr/bin/ditto','--rsrc','--extattr','--acl',str(root),str(backup/name)])
after={name:inventory(root) for name,root in roots.items()};copied={name:inventory(backup/name) for name in roots};final={name:inventory(root) for name,root in roots.items()}
for label,value in [('after-inventories',after),('backup-inventories',copied),('final-live-inventories',final)]: (b/(label+'.json')).write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
assert before==after==final,'live contents changed; stop';assert discover()==c;absent();added={}
for name,reference in before.items():
 assert set(reference)==set(copied[name]),'structure changed; stop';count=0
 for path,row in reference.items():
  actual=dict(copied[name][path]);attrs=dict(actual['xattrs'])
  if 'com.apple.provenance' not in row['xattrs'] and 'com.apple.provenance' in attrs:attrs.pop('com.apple.provenance');count+=1
  actual['xattrs']=attrs;assert actual==row,(name,path,'copy differs beyond classified new provenance')
 added[name]=count
signatures={}
for name,path in [('main',backup/'installed-app'),('keyboard',backup/'installed-app/PlugIns/Keyboard.appex')]:
 p=subprocess.run(['codesign','--verify','--deep','--strict',str(path)],capture_output=True,text=True);assert p.returncode==0;signatures[name]={'exit':p.returncode}
prefs=roots['app-group']/f'Library/Preferences/{gid}.plist';data=plistlib.loads(prefs.read_bytes()) if prefs.exists() else {};keys=['logging_enabled','diagnostics_high_fidelity_expiration','rime_deployed','rime_needs_deploy','rime_is_deploying'];selected={key:{'exists':key in data,'value':data.get(key)} for key in keys}
for row in selected.values():
 if isinstance(row['value'],datetime.datetime):row['value']=row['value'].isoformat()
receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'I0 current post-health full backup, not old T0 baseline','udid':udid,'backup_root':str(backup),'backup_root_mode':'0700','containers':c,'source_three_reads_equal':True,'container_paths_stable':True,'app_appex_absent_before_after':True,'copy_bytes_structure_modes_owners_original_xattrs_equal':True,'copy_added_provenance_classification':added,'all_metadata_exact_claim':False,'internal_symlinks_checked':True,'backup_strict_signatures':signatures,'selected_preferences':selected,'counts':{name:{'files':sum(row['kind']=='file' for row in inv.values()),'directories':sum(row['kind']=='directory' for row in inv.values()),'symlinks':sum(row['kind']=='symlink' for row in inv.values()),'file_bytes':sum(row.get('size',0) for row in inv.values()),'inventory_sha256':h(json.dumps(inv,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode())} for name,inv in before.items()},'keychain_and_simulator_system_settings_not_backed_up':True,'old_backups_preserved':True,'no_install_launch_restore_or_test':True}
(b/'backup-receipt.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n');print(json.dumps({key:value for key,value in receipt.items() if key not in ['containers']},ensure_ascii=False))
