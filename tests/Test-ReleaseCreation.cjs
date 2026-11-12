// Exercise real archive/evidence logic with a local gh stub; no GitHub writes.
const fs=require('node:fs'),os=require('node:os'),path=require('node:path'),crypto=require('node:crypto');
const {execFileSync,spawnSync}=require('node:child_process');
const assert=require('node:assert/strict');
const root=fs.mkdtempSync(path.join(os.tmpdir(),'release-create-'));
try {
  fs.mkdirSync(path.join(root,'bin'));fs.mkdirSync(path.join(root,'stage/Base64String'),{recursive:true});
  fs.mkdirSync(path.join(root,'remote'));
  const payload='reviewed package bytes';
  fs.writeFileSync(path.join(root,'stage/Base64String/module.ps1'),payload);
  const evidence={module:'Base64String',version:'1.3.0',sourceSha:'a'.repeat(40),files:[{path:'module.ps1',sha256:crypto.createHash('sha256').update(payload).digest('hex').toUpperCase()}]};
  fs.writeFileSync(path.join(root,'stage/evidence.json'),JSON.stringify(evidence));
  fs.writeFileSync(path.join(root,'bin/gh'),`#!/usr/bin/env node
const fs=require('node:fs');const args=process.argv.slice(2);
const state=fs.existsSync('remote/tag.json')?JSON.parse(fs.readFileSync('remote/tag.json')):[];
if(args[0]==='api') process.stdout.write(JSON.stringify(state));
else if(args[1]==='create') {
 fs.writeFileSync('remote/tag.json',JSON.stringify([{ref:'refs/tags/'+args[2],object:{type:'commit',sha:process.env.SHA}}]));
 fs.copyFileSync('stage/evidence.json','remote/evidence.json');fs.copyFileSync('package.tar.gz','remote/package.tar.gz');
} else if(args[1]==='download') {
 const file=args[args.indexOf('--pattern')+1],dir=args[args.indexOf('--dir')+1];
 fs.copyFileSync('remote/'+file,dir+'/'+file);
} else process.exit(1);
`,{mode:0o755});
  const script=path.resolve('scripts/gallery/Create-Release.cjs');
  const env={...process.env,PATH:path.join(root,'bin')+path.delimiter+process.env.PATH,MODULE:'Base64String',VERSION:'1.3.0',SHA:evidence.sourceSha,GITHUB_REPOSITORY:'stadub/PowershellScripts',GITHUB_RUN_ID:'123'};
  const run=()=>spawnSync(process.execPath,[script],{cwd:root,env,encoding:'utf8'});
  let result=run();assert.equal(result.status,0,result.stderr); // create
  result=run();assert.equal(result.status,0,result.stderr); // existing exact tag and archive
  fs.rmSync(path.join(root,'existing-release'),{recursive:true});
  fs.writeFileSync(path.join(root,'stage/Base64String/module.ps1'),'tampered package');
  execFileSync('tar',['-czf','remote/package.tar.gz','-C','stage','Base64String'],{cwd:root});
  result=run();assert.notEqual(result.status,0);assert.match(result.stderr,/archive differs/);
  fs.rmSync(path.join(root,'existing-release'),{recursive:true});
  fs.writeFileSync(path.join(root,'remote/tag.json'),JSON.stringify([{ref:'refs/tags/Base64String-v1.3.0',object:{type:'commit',sha:'b'.repeat(40)}}]));
  result=run();assert.notEqual(result.status,0);assert.match(result.stderr,/not the tested commit/);
  console.log('Release creation: create, idempotent retry, changed archive and moved tag checks passed.');
} finally { fs.rmSync(root,{recursive:true,force:true}); }
