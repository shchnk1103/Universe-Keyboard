from pathlib import Path
import subprocess,os,json,hashlib,time,datetime,signal,sys,importlib.util,dataclasses,re,shutil
R=Path('/private/tmp/uk-finalci1');B=json.loads((R/'binding-original.json').read_text());S=Path(B['source_writer']);M=Path(B['delivery_manifest']);env=os.environ.copy();env.update(DEVELOPER_DIR=B['Xcode'],TMPDIR=str(R/'tmp')+'/');start=time.monotonic();rec={'run_id':'TC2-CI-20261011-INT003-FINAL-001','started_at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'binding_sha256':hashlib.sha256((R/'binding-original.json').read_bytes()).hexdigest(),'steps':[],'stop_reason':None,'outcome':'running'}
def h(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def save(): (R/'execution-receipt.json').write_text(json.dumps(rec,ensure_ascii=False,indent=2)+'\n')
def cmd(stage,argv,limit=1800):
 remain=7200-(time.monotonic()-start)
 if remain<=0:raise RuntimeError('total_wall_budget')
 row={'stage':stage,'argv':argv,'attempt':1,'started_at':datetime.datetime.now(datetime.timezone.utc).isoformat()};rec['steps'].append(row);save();print('START '+stage,flush=True)
 log=R/'Logs'/('%02d-'%len(rec['steps'])+re.sub(r'[^a-zA-Z0-9_-]','_',stage)+'.log');row['log']=str(log);tick=time.monotonic()
 with log.open('wb') as f:
  proc=subprocess.Popen(argv,cwd=S,env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
  try:row['exit_code']=proc.wait(timeout=min(limit,remain))
  except subprocess.TimeoutExpired:
   os.killpg(proc.pid,signal.SIGTERM)
   try:proc.wait(timeout=10)
   except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
   row['exit_code']=proc.returncode;row['timeout']=True
 row['elapsed_s']=time.monotonic()-tick;row['ended_at']=datetime.datetime.now(datetime.timezone.utc).isoformat();row['log_sha256']=h(log);save();print('END '+stage+' exit='+str(row['exit_code'])+' seconds='+str(round(row['elapsed_s'],2)),flush=True)
 if row['exit_code']!=0 or row.get('timeout'):raise RuntimeError('first_failed_stage:'+stage)
 return log
try:
 assert h(M)==B['delivery_manifest_sha256'];manifest=json.loads(M.read_text());assert len(manifest['source_paths'])==28
 for row in manifest['source_paths']:assert h(S/row['path'])==row['sha256'],row['path']
 rec['entry_source_paths_matched']=28;rec['source_status_before']=subprocess.check_output(['git','status','--porcelain','-z'],cwd=S).decode();assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=S,text=True).strip()==B['source_head'];assert subprocess.check_output(['git','rev-parse','HEAD^{tree}'],cwd=S,text=True).strip()==B['source_tree'];assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=S,text=True).strip()
 space=shutil.disk_usage(R);rec['entry_disk_free_bytes']=space.free
 if space.free<20*1024**3:raise RuntimeError('entry_disk_free_below20GiB')
 assert Path('/private/tmp/uk-armimpl1/SourcePackages').is_dir()
 cmd('xcode_identity',['/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild','-version'],60)
 cmd('sdk_identity',['/usr/bin/xcrun','--sdk','iphonesimulator','--show-sdk-version'],60)
 simlog=cmd('simulator_entry',['/usr/bin/xcrun','simctl','list','devices','--json'],60);sims=json.loads(simlog.read_text());matches=[(rt,d) for rt,ds in sims['devices'].items() for d in ds if d['udid']==B['device']['UDID']];assert len(matches)==1;rt,dev=matches[0];assert dev['state']=='Booted' and dev.get('isAvailable') and 'iOS-27-0' in rt;rec['device_observed']={'runtime':rt,**dev};save()
 spec=importlib.util.spec_from_file_location('final_ci_classifier',S/'scripts/ci/classify_changes.py');module=importlib.util.module_from_spec(spec);sys.modules[spec.name]=module;spec.loader.exec_module(module);full=module.classify_paths([row['path'] for row in manifest['source_paths']]);docs=module.classify_paths(['docs/assignments/typo-correction-002.md']);assert full.name=='full' and docs.name=='docs_only';rec['classification']={'full':dataclasses.asdict(full),'docs_only':dataclasses.asdict(docs)}
 cmd('whitespace',['git','diff','--check'],60)
 for row in manifest['source_paths']:
  for number,line in enumerate((S/row['path']).read_text().splitlines(),1):assert line==line.rstrip(' \t'),(row['path'],number,'trailing_whitespace')
 json.loads((S/'.kos/project.json').read_text())
 cmd('lightweight_python',['/usr/bin/python3','-m','unittest','discover','-s','scripts/ci/tests','-p','test_*.py'],180)
 cmd('lightweight_final_gate',['/bin/bash','scripts/ci/tests/test_verify_final_gate.sh'],180)
 cmd('lightweight_kos_trigger',['/bin/bash','scripts/ci/tests/test_kos_trigger_paths.sh'],180)
 cmd('vendor_pinned',['/bin/bash','scripts/ensure_rime_vendor.sh','verify' if (S/'Packages/RimeBridge/Vendor').is_dir() else 'fetch'],600)
 for c in B['commands']:cmd(c['stage']+(':'+c['argv'][-1] if c['stage']=='strict_format' else ''),c['argv'],120 if c['stage']=='strict_format' else 1800)
 readout_start=time.monotonic();rec['summaries']={}
 for stage in ['rimebridge','app_keyboard','keychain']:
  log=cmd('readout_'+stage,['/usr/bin/xcrun','xcresulttool','get','test-results','summary','--path',str(R/'Results'/(stage+'.xcresult'))],min(180,900-(time.monotonic()-readout_start)));summary=json.loads(log.read_text());rec['summaries'][stage]=summary
 for row in manifest['source_paths']:assert h(S/row['path'])==row['sha256'],row['path']
 after=subprocess.check_output(['git','status','--porcelain','-z'],cwd=S).decode();assert after==rec['source_status_before'],'source_git_status_changed';rec['source_closeout_paths_matched']=28;rec['outcome']='required_matrix_passed_executor_recorded';save()
except Exception as e:
 rec['stop_reason']=str(e);rec['outcome']='stopped_first_failure';save();print('STOP '+str(e),flush=True)
finally:
 rec['ended_at']=datetime.datetime.now(datetime.timezone.utc).isoformat();rec['elapsed_s']=time.monotonic()-start;save();print('FINAL '+rec['outcome'],flush=True)
