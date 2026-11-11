const fs = require('node:fs');
const assert = require('node:assert/strict');
const workflow = fs.readFileSync('.github/workflows/release-gallery.yml','utf8');
const jobs = Object.fromEntries([...workflow.matchAll(/^  ([\w-]+):\n([\s\S]*?)(?=^  [\w-]+:\n|$(?![\s\S]))/gm)].map(m=>[m[1],m[2]]));
for(const name of ['publish','verify','complete-issues']) assert.ok(jobs[name],name);
assert.match(jobs.publish,/environment: powershell-gallery/);
assert.match(jobs.publish,/!inputs.dry_run && github.ref == 'refs\/heads\/master'/);
assert.match(jobs.publish,/needs: \[package, test, release\]/);
for(const [name,job] of Object.entries(jobs)) {
  if(name !== 'publish') assert.ok(!job.includes('secrets.PSGALLERY_API_KEY'),`Secret in ${name}`);
  if(name !== 'complete-issues') assert.ok(!job.includes('issues: write'),`Issue write in ${name}`);
}
for(const term of ['!inputs.dry_run',"github.ref == 'refs/heads/master'","needs.publish.result == 'success'","needs.publish.outputs.published == 'true'","needs.verify.result == 'success'","needs.verify.outputs.verified == 'true'"]) assert.ok(jobs['complete-issues'].includes(term),term);
assert.ok(!jobs['complete-issues'].includes('inputs.issue'));
assert.ok(!jobs['complete-issues'].includes('ref: ${{ inputs.source_sha }}'));
assert.match(workflow,/dry_run:[\s\S]*?default: true/);
assert.match(workflow,/cancel-in-progress: false/);
console.log('Workflow safety: trusted closure, secret/permission scope, dry-run and success gates passed.');
