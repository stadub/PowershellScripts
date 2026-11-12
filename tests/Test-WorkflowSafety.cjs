const fs = require('node:fs');
const assert = require('node:assert/strict');
const workflow = fs.readFileSync('.github/workflows/release-gallery.yml','utf8');
const jobs = Object.fromEntries([...workflow.matchAll(/^  ([\w-]+):\n([\s\S]*?)(?=^  [\w-]+:\n|$(?![\s\S]))/gm)].map(m=>[m[1],m[2]]));
for(const name of ['publish','verify','complete-issues']) assert.ok(jobs[name],name);
assert.match(jobs.publish,/environment: powershell-gallery/);
assert.match(jobs.publish,/!inputs.dry_run && github.ref == 'refs\/heads\/master'/);
assert.match(jobs.publish,/needs: \[package, test, release\]/);
for(const [name,job] of Object.entries(jobs)) {
  if(name !== 'publish') assert.ok(!job.includes('secrets.') && !job.includes('secrets['),`Secret in ${name}`);
  if(name !== 'complete-issues') assert.ok(!job.includes('issues: write'),`Issue write in ${name}`);
}
for(const term of ['!inputs.dry_run',"github.ref == 'refs/heads/master'","needs.publish.result == 'success'","needs.publish.outputs.published == 'true'","needs.verify.result == 'success'","needs.verify.outputs.verified == 'true'"]) assert.ok(jobs['complete-issues'].includes(term),term);
assert.ok(!jobs['complete-issues'].includes('inputs.issue'));
assert.ok(!jobs['complete-issues'].includes('ref: ${{ inputs.source_sha }}'));
assert.match(workflow,/dry_run:[\s\S]*?default: true/);
assert.match(workflow,/cancel-in-progress: false/);
console.log('Workflow safety: trusted closure, secret/permission scope, dry-run and success gates passed.');

assert.match(jobs.publish,/PSGALLERY_API_KEY: \$\{\{ secrets\[steps\.account\.outputs\.secret\] \}\}/);
assert.match(jobs.publish,/PSGALLERY_ACCOUNT: \$\{\{ steps\.account\.outputs\.name \}\}/);
assert.ok(!workflow.includes('secrets.PSGALLERY_API_KEY'));
assert.ok(!workflow.includes('inputs.account') && !workflow.includes('inputs.secret'));
const selector = jobs.publish.split('      - name: Select configured Gallery account')[1].split('      - name: Publish tested package')[0];
assert.ok(selector.includes('Get-ReleaseConfig.ps1'));
assert.ok(selector.includes('config.GallerySecret') && selector.includes('config.GalleryAccount'));
assert.ok(!selector.includes('secrets[') && !selector.includes('secrets.'));
console.log('Credential safety: only selected configured account key reaches upload, with no fallback or dispatch override.');
const candidateValidation = fs.readFileSync('.github/workflows/validate-release-candidate.yml','utf8');
assert.ok(candidateValidation.includes('workflow_call:'));
assert.match(candidateValidation,/permissions:\n  contents: read/);
for (const forbidden of ['secrets.', 'secrets[', 'issues: write', 'contents: write', 'environment:', 'Publish-GalleryPackage.ps1', 'Complete-Issues']) {
  assert.ok(!candidateValidation.includes(forbidden), `Candidate validation unexpectedly contains ${forbidden}`);
}
assert.ok(candidateValidation.includes('inputs.source_sha') && candidateValidation.includes('inputs.automation_sha'));
console.log('Candidate validation is read-only, immutable-input-only, and cannot publish or complete issues.');
const moduleValidation = fs.readFileSync('.github/workflows/validate-module-source.yml','utf8');
assert.match(moduleValidation,/permissions:\n  contents: read/);
for (const forbidden of ['secrets.', 'secrets[', 'issues: write', 'contents: write', 'environment:', 'Publish-GalleryPackage.ps1']) assert.ok(!moduleValidation.includes(forbidden));
assert.ok(moduleValidation.includes('inputs.source_sha') && moduleValidation.includes('inputs.automation_sha'));
assert.ok(moduleValidation.includes('Invoke-ModuleTests.ps1'));
console.log('Module source validation remains read-only and tests exact source commits.');

const ciWorkflow = fs.readFileSync('.github/workflows/ci.yml','utf8');
assert.ok(ciWorkflow.includes('Resolve-CiSources.ps1'));
assert.ok(ciWorkflow.includes('ref: ${{ matrix.source_sha }}'));
assert.ok(ciWorkflow.includes('-SourceRoot ./module-source'));
assert.ok(ciWorkflow.includes('source-identity.json'));
assert.ok(!ciWorkflow.includes('continue-on-error: true'));
console.log('Aggregate CI tests and records exact selected source commits without allow-failure.');

const dispatchForm = workflow.slice(0, workflow.indexOf('permissions:'));
assert.match(dispatchForm, /module:[\s\S]*?type: choice/);
assert.match(dispatchForm, /version:[\s\S]*?type: string/);
assert.ok(!dispatchForm.includes('source_sha:'));
assert.equal((jobs.package.match(/Resolve-ReleaseSnapshot.ps1/g) || []).length, 1);
assert.ok(jobs.package.includes('source_sha: ${{ steps.snapshot.outputs.sha }}'));
assert.ok(jobs.package.includes('ref: ${{ steps.snapshot.outputs.sha }}'));
assert.ok(!workflow.includes('inputs.source_sha'));
for (const name of ['test','release','publish','verify','complete-issues']) {
  assert.ok(jobs[name].includes('needs.package.outputs.source_sha'), `Unpinned release source in ${name}`);
}
assert.match(jobs.verify, /needs: \[package, publish\]/);
assert.match(jobs['complete-issues'], /needs: \[package, publish, verify\]/);
console.log('Release form selects a module/version and propagates one resolved immutable snapshot through every job.');
