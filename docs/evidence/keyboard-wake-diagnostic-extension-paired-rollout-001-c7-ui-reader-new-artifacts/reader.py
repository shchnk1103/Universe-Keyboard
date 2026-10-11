"""Read-only candidate inspector. All output writes are caller-owned scratch."""
from pathlib import Path
import hashlib,json,struct,uuid,plistlib,subprocess,sys

def require(ok, message):
    if not ok: raise ValueError(message)
def sha(data): return hashlib.sha256(data).hexdigest()
def canonical(data, ascii=False): return json.dumps(data,sort_keys=True,separators=(',',':'),ensure_ascii=ascii).encode()
def check_map(mapping):
    require(isinstance(mapping,dict),'input map must be path -> SHA')
    for path, expected in mapping.items():
        require(isinstance(path,str) and Path(path).is_absolute(),'input key must be absolute path')
        require(isinstance(expected,str) and len(expected)==64 and all(c in '0123456789abcdef' for c in expected),'value must be SHA256')

def parse_macho(raw):
    require(isinstance(raw,bytes) and len(raw)>=32,'truncated header')
    magic,cpu,_,_,count,cmdbytes,_,_=struct.unpack_from('<8I',raw)
    require(magic==0xfeedfacf and cpu==0x100000c,'expected little-endian arm64 MachO64')
    end=32+cmdbytes; require(end<=len(raw),'load commands exceed file')
    offset=32; identities=[]; entitlements=[]
    for _ in range(count):
        require(offset+8<=end,'truncated command')
        command,size=struct.unpack_from('<II',raw,offset)
        require(size>=8 and size%8==0 and offset+size<=end,'invalid command size')
        if command==0x1b:
            require(size==24,'invalid UUID command'); identities.append(str(uuid.UUID(bytes=raw[offset+8:offset+24])).upper())
        if command==0x19:
            require(size>=72,'truncated segment'); sections=struct.unpack_from('<I',raw,offset+64)[0]
            require(72+sections*80<=size,'truncated sections')
            for index in range(sections):
                pos=offset+72+index*80
                name=raw[pos:pos+16].rstrip(b'\0'); segment=raw[pos+16:pos+32].rstrip(b'\0')
                length=struct.unpack_from('<Q',raw,pos+40)[0]; file_offset=struct.unpack_from('<I',raw,pos+48)[0]
                if segment==b'__TEXT' and name==b'__entitlements':
                    require(file_offset>=end and file_offset+length<=len(raw),'entitlement section out of file bounds')
                    entitlements.append({'offset':file_offset,'length':length,'raw':raw[file_offset:file_offset+length]})
        offset+=size
    require(offset==end and len(identities)==1,'load-command/UUID count mismatch')
    return {'uuid':identities[0],'entitlements':entitlements}

def self_test():
    content=plistlib.dumps({'fixture':'content-free'})
    uuid_cmd=struct.pack('<II',0x1b,24)+uuid.UUID(int=1).bytes
    segment=bytearray(152);struct.pack_into('<II',segment,0,0x19,152);struct.pack_into('<I',segment,64,1)
    segment[72:88]=b'__entitlements'.ljust(16,b'\0');segment[88:104]=b'__TEXT'.ljust(16,b'\0')
    struct.pack_into('<Q',segment,112,len(content));struct.pack_into('<I',segment,120,208)
    header=struct.pack('<8I',0xfeedfacf,0x100000c,0,2,2,176,0,0);raw=header+uuid_cmd+segment+content
    result=parse_macho(raw);section=result['entitlements'][0]['raw'];require(isinstance(section,bytes) and section==content,'section must return exact bytes')
    require(plistlib.loads(section)=={'fixture':'content-free'},'plist bytes contract');check_map({'/fixture/input':'a'*64})
    cases={'short_header':raw[:20],'wrong_cpu':raw[:4]+struct.pack('<I',7)+raw[8:],'section_out_of_bounds':raw[:120+32+24]+struct.pack('<I',len(raw)+1)+raw[120+32+24+4:],'bad_command_size':raw[:36]+struct.pack('<I',7)+raw[40:],'missing_uuid':header[:16]+struct.pack('<I',1)+struct.pack('<I',152)+header[24:]+segment[:120]+struct.pack('<I',184)+segment[124:]+content}
    for label,data in cases.items():
        try: parse_macho(data)
        except ValueError: continue
        raise ValueError('negative fixture unexpectedly accepted: '+label)
    try: check_map({'a'*64:'/fixture/input'})
    except ValueError: pass
    else: raise ValueError('reversed input map accepted')
    return {'valid_section_bytes_and_plist':True,'negative_cases':list(cases)+['reversed_input_map'],'passed':True}

def run(argv):
    p=subprocess.run(argv,capture_output=True,text=True)
    require(p.returncode==0,'readonly tool failed: '+repr(argv)+' '+p.stderr)
    return {'argv':argv,'exit':p.returncode,'stdout':p.stdout,'stderr':p.stderr}

def verify(packet_path):
    p=json.loads(Path(packet_path).read_text());digest=p.pop('packet_digest_sha256');require(sha(canonical(p))==digest,'packet digest mismatch')
    for group in ['allowed_content_inputs','allowed_binary_inputs','allowed_generated_xcent_inputs','allowed_hash_only_repo_inputs']:
        check_map(p[group])
        for path,expected in p[group].items(): require(sha(Path(path).read_bytes())==expected,'input hash mismatch: '+path)
    def one(suffix):
        paths=[k for k in p['allowed_content_inputs'] if k.endswith(suffix)];require(len(paths)==1,'input locator ambiguous: '+suffix);return Path(paths[0])
    products=json.loads(one('/paired-products.json').read_text());er=json.loads(one('/simulator-entitlements.json').read_text())['bundles'];require(len(er)==2,'two entitlement rows required')
    app=Path(products['app_root']);paths=[x for x in sorted(app.rglob('*')) if x.is_file()]
    require(set(str(x) for x in paths)<=set(p['allowed_binary_inputs']),'unexpected payload path outside allowlist')
    files={str(x.relative_to(app)):sha(x.read_bytes()) for x in paths};require(files==products['file_hashes'] and len(files)==78,'payload mismatch')
    require(not any('.xctest' in x or 'XCTest' in x for x in files),'test host payload present')
    ent=[]
    for row in er:
        exe=app/row['mach_o_relative'];binary=exe.read_bytes();parsed=parse_macho(binary)
        require(sha(binary)==p['allowed_binary_inputs'][str(exe)]==row['macho_sha256'],'executable identity mismatch')
        require(parsed['uuid']==row['macho_uuid'] and len(parsed['entitlements'])==1,'entitlement UUID/section count mismatch')
        section=parsed['entitlements'][0];data=section['raw'];require(isinstance(data,bytes),'plist must receive section bytes')
        archive=one('/'+row['xcent_copy']);generated=Path(row['xcent_locator'])
        require(str(generated) in p['allowed_generated_xcent_inputs'],'generated locator outside allowlist')
        require(data==archive.read_bytes()==generated.read_bytes(),'exact entitlement bytes mismatch')
        parsed_plist=plistlib.loads(data);bid=row['bundle_id'];require(parsed_plist['com.apple.security.application-groups']==['group.com.DoubleShy0N.Universe-Keyboard'],'AppGroup mismatch')
        require(parsed_plist.get('application-identifier',parsed_plist.get('com.apple.application-identifier','')).endswith('.'+bid),'application identifier mismatch')
        require(parsed_plist==row['entitlements'] and section['offset']==row['embedded_section_offset'] and len(data)==row['embedded_section_bytes'] and sha(data)==row['embedded_section_sha256'],'row does not match actual section')
        ent.append({'executable':str(exe),'sha256':sha(binary),'uuid':parsed['uuid'],'section_offset':section['offset'],'section_bytes':len(data),'section_sha256':sha(data),'both_xcent_exact':True,'entitlements':parsed_plist})
    binding={'build_input_manifest_sha256':sha(one('/build-input-manifest.json').read_bytes()),'candidate_command_sha256':sha(one('/candidate-command.json').read_bytes()),'payload_digest_sha256':sha(canonical(files,True)),'entitlement_rows_sha256':sha(canonical(er))}
    candidate=sha(canonical(binding,True));require(binding==products['binding'] and candidate==products['candidate']==p['baseline']['candidate'],'candidate binding mismatch')
    bundles=[]
    for bundle in [app,app/'PlugIns/Keyboard.appex']:
        info=plistlib.loads((bundle/'Info.plist').read_bytes());expected=next(x for x in products['bundles'] if x['bundle_id']==info['CFBundleIdentifier'])
        require(info['CFBundleShortVersionString']==expected['version'] and info['CFBundleVersion']==expected['build'],'version mismatch')
        signature=run(['codesign','--verify','--deep','--strict',str(bundle)]);bundles.append({'id':info['CFBundleIdentifier'],'version':expected['version'],'build':expected['build'],'signature':signature})
    require(bundles[0]['version']==bundles[1]['version'] and bundles[0]['build']==bundles[1]['build'],'pair mismatch')
    machos=[]
    for row in products['machos']:
        path=app/row['path'];data=path.read_bytes();u=parse_macho(data)['uuid'];du=run(['xcrun','dwarfdump','--uuid',str(path)]);require(sha(data)==row['sha256'] and u==row['uuid'] and u in du['stdout'],'MachO UUID mismatch')
        machos.append({'path':row['path'],'sha256':sha(data),'uuid':u,'dwarfdump':du})
    require(len(machos)==6,'expected six MachOs')
    return {'packet_digest':digest,'candidate':candidate,'binding':binding,'payload_count':len(files),'entitlements':ent,'bundles':bundles,'machos':machos,'input_counts':{g:len(p[g]) for g in ['allowed_content_inputs','allowed_binary_inputs','allowed_generated_xcent_inputs','allowed_hash_only_repo_inputs']},'note':'Source impact is an independent reviewer criterion; this reader does not infer source semantics.'}

if __name__=='__main__':
    if sys.argv[1:]==['--self-test']: print(json.dumps(self_test(),indent=2))
    else:
        require(len(sys.argv)==4 and sys.argv[1]=='--verify','usage: --self-test OR --verify packet output')
        packet=Path(sys.argv[2]);out=Path(sys.argv[3]);p=json.loads(packet.read_text());require(out.resolve().parent==Path(p['outputs']['scratch']).resolve(),'output outside own scratch')
        result=verify(packet);out.write_text(json.dumps(result,indent=2));print(json.dumps({'candidate':result['candidate'],'entitlements':len(result['entitlements']),'machos':len(result['machos']),'payload_count':result['payload_count']},indent=2))
