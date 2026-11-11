const assert = require('node:assert/strict');
const {mappedIssues, complete} = require('../scripts/gallery/Complete-Issues.cjs');
const identity = {repository:'stadub/PowershellScripts',module:'Base64String',version:'1.3.0',sourceSha:'a'.repeat(40)};
const mapping = [{...identity, issues:[22,22]}];
assert.deepEqual(mappedIssues(mapping, identity),[22]);
for(const key of Object.keys(identity)) assert.deepEqual(mappedIssues(mapping, {...identity,[key]:'wrong'}),[]);
assert.deepEqual(mappedIssues([],identity),[]);
assert.throws(()=>mappedIssues([{...identity,issues:['22']}],identity));
(async()=>{
  let comments=[],state='open',writes=[];
  const github={rest:{issues:{
    get:async()=>({data:{state}}),
    listComments:()=>{},
    createComment:async({body})=>{comments.push({body,user:{type:'Bot'}});writes.push('comment')},
    update:async()=>{state='closed';writes.push('close')}
  }},paginate:async()=>comments};
  const args={github,context:{repo:{owner:'stadub',repo:'PowershellScripts'},runId:123},identity,mapping};
  await complete(args);
  assert.deepEqual(writes,['comment','close']);
  assert.match(comments[0].body,/packages\/Base64String\/1.3.0/);
  assert.match(comments[0].body,/actions\/runs\/123/);
  assert.match(comments[0].body,/releases\/tag\/Base64String-v1.3.0/);
  await complete(args);
  assert.equal(writes.length,2);
  state='open';await complete(args);assert.equal(writes.length,3); // recover comment-before-close interruption
  await complete({...args,identity:{...identity,version:'wrong'}});assert.equal(writes.length,3);
  github.rest.issues.get=async()=>({data:{state:'open',pull_request:{}}});
  await assert.rejects(complete(args),/not a PR/);
  console.log('Issue completion: exact mapping, evidence, retry idempotency and PR rejection passed.');
})().catch(e=>{console.error(e);process.exitCode=1});
