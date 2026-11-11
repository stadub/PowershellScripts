const {execFileSync} = require('node:child_process');
const fs = require('node:fs');
const {MODULE:moduleName, VERSION:version, SHA:sha, GITHUB_REPOSITORY:repo, GITHUB_RUN_ID:run} = process.env;
const tag = `${moduleName}-v${version}`;
const gh = (...args) => execFileSync('gh', args, {encoding:'utf8'}).trim();
const evidence = JSON.parse(fs.readFileSync('stage/evidence.json'));
if(evidence.module !== moduleName || evidence.version !== version || evidence.sourceSha !== sha) throw Error('Release identity mismatch');
// Tag must either be absent or resolve exactly to the tested commit; never retarget it.
const tags = JSON.parse(gh('api', `repos/${repo}/git/matching-refs/tags/${tag}`));
const existing = tags.find(r => r.ref === `refs/tags/${tag}`);
if (existing) {
  if(existing.object.type !== 'commit' || existing.object.sha !== sha) throw Error('Existing tag is not the tested commit');
  fs.mkdirSync('existing-release', {recursive:true});
  gh('release','download',tag,'--pattern','evidence.json','--dir','existing-release');
  if(fs.readFileSync('stage/evidence.json','utf8') !== fs.readFileSync('existing-release/evidence.json','utf8')) throw Error('Existing release evidence differs');
  gh('release','download',tag,'--pattern','package.tar.gz','--dir','existing-release');
  const entries = execFileSync('tar',['-tzf','existing-release/package.tar.gz'],{encoding:'utf8'}).trim().split('\n');
  if(entries.some(p => !p.startsWith(moduleName + '/') || p.split('/').includes('..'))) throw Error('Unsafe archive entries');
  const crypto = require('node:crypto');
  const expectedPaths = evidence.files.map(f => moduleName+'/'+f.path).sort();
  const archivePaths = entries.filter(p => !p.endsWith('/')).sort();
  if(JSON.stringify(expectedPaths) !== JSON.stringify(archivePaths)) throw Error('Existing archive file list differs');
  // Read members to stdout; never extract a release archive on a write-token runner.
  for(const file of evidence.files) {
    const bytes = execFileSync('tar',['-xOzf','existing-release/package.tar.gz',moduleName+'/'+file.path]);
    if(crypto.createHash('sha256').update(bytes).digest('hex').toUpperCase() !== file.sha256) throw Error('Existing release archive differs from tested package');
  }
  console.log(`Verified existing release ${tag}`);
} else {
  // Archive is a convenience asset; evidence contains the canonical per-file hashes.
  execFileSync('tar',['-czf','package.tar.gz','-C','stage',moduleName]);
  gh('release','create',tag,'package.tar.gz','stage/evidence.json','--target',sha,'--title',tag,
    '--notes',`Tested immutable release snapshot ${sha}. Source and installed package tests: https://github.com/${repo}/actions/runs/${run}. Gallery publication is a separate protected job; this release does not imply deployment.`);
}
