// No package/source code executes in the issues:write job.
const fs = require('node:fs');
function mappedIssues(mapping, identity) {
  return mapping.filter(m => m.repository === identity.repository &&
    m.module === identity.module && m.version === identity.version &&
    m.sourceSha === identity.sourceSha).flatMap(m => m.issues).filter((n, i, a) => {
      if (!Number.isSafeInteger(n) || n <= 0) throw Error('Invalid mapped issue');
      return a.indexOf(n) === i;
    });
}
async function complete({github, context, identity, mapping}) {
  const issues = mappedIssues(mapping, identity);
  const run = `https://github.com/${identity.repository}/actions/runs/${context.runId}`;
  const gallery = `https://www.powershellgallery.com/packages/${identity.module}/${identity.version}`;
  const release = `https://github.com/${identity.repository}/releases/tag/${identity.module}-v${identity.version}`;
  const marker = `<!-- gallery-completion:${identity.module}:${identity.version}:${identity.sourceSha} -->`;
  for (const issue_number of issues) {
    const args = {...context.repo, issue_number};
    const issue = (await github.rest.issues.get(args)).data;
    if (issue.pull_request) throw Error('Mapping must name an issue, not a PR');
    const comments = await github.paginate(github.rest.issues.listComments, {...args, per_page:100});
    if (!comments.some(c => c.user?.type === 'Bot' && c.body.includes(marker))) {
      await github.rest.issues.createComment({...args, body: `${marker}\nActual Gallery publish succeeded and the exact downloaded package passed content-hash, manifest, import and installed regression checks.\n\nPackage: ${gallery}\nRelease: ${release}\nSnapshot: ${identity.sourceSha}\nWorkflow and verification artifact: ${run}`});
    }
    if (issue.state !== 'closed') await github.rest.issues.update({...args, state:'closed', state_reason:'completed'});
  }
}
module.exports = {mappedIssues, complete};
