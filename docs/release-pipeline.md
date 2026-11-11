# Tested releases and protected PowerShell Gallery publication

This is automation for issue #29, not a deployment of the #22 fix. #22 stays open.
No live Gallery upload, release, issue mutation, secret edit, master edit, or sibling
worktree edit was performed while implementing this branch.

## Ownership and integration

`ci/release-pipeline` selectively reuses the routing/runner from the read-only
`github-actions-ci` worktree and configuration/staging/preflight checks from the
read-only `psgallery-deploy` worktree. The sibling files were uncommitted and have
continued owner activity: merge this integrated implementation deliberately, not
both its workflow and the sibling `publish-gallery.yml`. Preserve the five publication
routes and Gallery account ownership. The single environment secret interface is
`PSGALLERY_API_KEY`; its owner must have publishing rights to the selected package
(Stadub for Bookmarks/7zip-Archive/Currency-Conv; MiniModules for Base64String/Pipe).
Do not install a second publishing workflow using different secret names.

Retain the sibling CI owner's README/badge changes and legacy YAML deletions as a
separate reviewed cutover. This branch intentionally does not delete them. The
AppVeyor audit reports no required branch contexts, rulesets, or AppVeyor webhooks;
historical failed statuses on PR #28 are not required checks. External AppVeyor
projects 610315 SharedFunctions (`powershellscripts-v9ncj`) and 607412 Currency-Conv
(`powershellscripts-7m2fk`) still point here and have `skipBranchesWithoutAppveyorYml`
false. The audit lacked AppVeyor login/token and GitHub app-installation enumeration
access. An owner must disable those external triggers; see that owner's
`docs/ci/appveyor-cutover`. Do not claim YAML deletion disables external services.
Only require `CI status` after a real hosted run succeeds on each maintained branch.

## Inputs and behavior

Run `release-gallery.yml` manually. Supply one configured module, its stable
manifest version, and a **full 40-character reviewed release commit SHA**. The
workflow rejects snapshots outside the configured release branch's history.
It never checks out a development ref for publishing. The routes are:

| Module | Release branch | Package directory |
| --- | --- | --- |
| Bookmarks | Bookmarks/release/latest | Bookmarks/out |
| 7zip-Archive | 7-Zip/release/latest | 7Zip/out |
| Currency-Conv | Currency-Conv/release/latest | Currency-Conv/out |
| Base64String | base64String/release/latest | Shared-Functions/Base64String/out |
| Pipe | Pipe/release/latest | Shared-Functions/Pipe/out |

The user requested the two numbered release sources be changed to `latest`.
Live inspection found **no** `7-Zip/release/latest` or `Currency-Conv/release/latest`
branch. An owner must establish reviewed snapshots there before those modules can
deploy; the workflow fails closed if either ref is missing. Existing numbered
branches remain historical baselines, not fallback publication sources.

`PackagePath` follows one rule for every configured module:
**<module source directory>/out** within the reviewed release snapshot. The nested
Shared-Functions prefix remains part of Base64String's and Pipe's source layout.
Staging never falls back to source files beside out/ when a package is missing.

The historical numbered 7Zip and Currency-Conv snapshots used their module
directories directly. Their new latest snapshots must instead contain reviewed
`7Zip/out` and `Currency-Conv/out` packages with matching source/manifest bytes.
Preparing those release snapshots remains a rollout prerequisite; this automation
change does not generate or commit release artifacts into development source.
A branch named latest does not imply a directory named latest.

`GallerySecret = 'PSGALLERY_API_KEY'` is the secret's **name**, not its value. To set
it up, the owner opens repository Settings -> Environments -> powershell-gallery
-> Environment secrets -> Add environment secret, enters that name and securely
supplies the Gallery API key. Preserve master-only deployment restrictions and
configure independent reviewers as described below. Live reinspection still found
zero secrets. The key must authorize the selected module's Gallery account.

After integration into master and preparation of a tested release snapshot, open
Actions -> Tested release and protected Gallery deployment -> Run workflow. Select
master, module, version and full reviewed release SHA. Start with dry_run=true and
create_release=false. Inspect the resulting package/tests, optionally create the
GitHub release with create_release=true while retaining dry_run=true, and only
when actual deployment is authorized choose dry_run=false and approve its protected
environment. Configuring a secret does not itself trigger a deployment.

`dry_run=true` (default) prevents Gallery publication and issue completion.
`create_release=false` (default) also prevents GitHub release creation. A release-only
run explicitly sets `create_release=true`, retaining `dry_run=true`. Any mutation
requires dispatch from master. Setting `dry_run=false` creates/verifies the tested
GitHub release first, then requests the protected environment before upload.
Concurrency serializes each module, and never cancels an active publish.

Staging copies only allowed flat package files plus LICENSE from the immutable
snapshot. This reproduces reviewed release output; it does not recover historical
PSM-Release.ps1 or regenerate stale out/ content implicitly. Every staged script,
module and manifest must match the corresponding source bytes (flattened names
must be unique). Source/package divergence blocks release. Reconcile known Pipe
and Bookmarks helper/manifest differences in their component release reviews.

The same staged artifact is tested on Windows PowerShell 5.1 and pwsh on Windows,
Linux and macOS (7zip-Archive runtime suites remain Windows-only). Tests use pinned
Pester 4.10.1. Source suites run separately against an installed copy, imported by
absolute manifest path; suite files never enter the publish payload. Pipe runs its source Pester suites when present, with manifest checks on older
snapshots without suites. CI now covers all eight formal modules; this expansion
does not add publication routes. See the coverage table below.

Release tags are `<Module>-v<Version>` at the tested SHA, with `package.tar.gz` and
`evidence.json` assets. No automatic closing keywords appear in release notes.
An existing tag must resolve to the same SHA; existing release evidence and archive
bytes must match. Missing/changed assets fail rather than being overwritten.
Do not retarget tags or edit release assets after approval. Repository admins can
still alter GitHub tags/assets unless repository release immutability/rules are
configured separately; hash checks detect mismatches on rerun.

Only the actual upload step receives the environment secret. CI, staging, tests,
release creation, Gallery verification and issue completion receive no API key.
Upload preflight rejects existing/superseded versions and fails closed on lookup
errors. It calls Publish-Module, not an unofficial Gallery upload endpoint.

After actual upload success a fresh job queries and downloads the **exact** version
from PSGallery, retries visibility up to six times, checks all payload hashes, and
runs manifest/import/export and installed regression checks. Only Gallery-generated
PSGetModuleInfo.xml is excluded from the comparison. A different visible package,
missing version, download error, hash change, or failed regression blocks completion.
The `gallery-verification` artifact and run log contain verification evidence.

## CI coverage for all modules

The user subsequently requested CI for all modules. Master, automation branches
and unknown feature branches now select all eight modules (22 OS/module jobs).
Module development branches and PR targets select their own module. Existing
7zip-Archive runtime suites remain Windows-only; all other entries run pwsh on
Windows, Linux and macOS. The release workflow's publication choices remain five.

| Module | CI checks |
| --- | --- |
| Bookmarks | Existing source Pester suites |
| 7zip-Archive | Existing source Pester suites, Windows |
| Currency-Conv | Existing source Pester suites |
| Base64String | Existing source Pester suites |
| Pipe | Manifest validation and source Pester suites when available |
| FolderEncoder | Parse source scripts/manifests, validate manifest, import, require exported commands; run source Pester suites when added |
| Shell-Functions | Parse source scripts/manifests, validate manifest, import, require exported commands; run source Pester suites when added |
| Uninstall | Parse/import standalone Uninstall.psm1, verify exported Uninstall-Application command and SoftwareName/Application parameter contract; run Uninstall*.Tests.ps1 when added |

The three new modules currently have no functional Pester suites. Their checks
produce NUnit-compatible structure reports on success and failure. Uninstall's
smoke checks never invoke its command, access HKLM, start msiexec, or uninstall
software. This checks its loadable public API, not Windows uninstall behavior.

Local real-source checks: Uninstall passes on macOS pwsh 7.7.0; FolderEncoder fails
because Functions.ps1 is missing; Shell-Functions fails because its manifest imports
an empty module with no exported commands. These are pre-existing module defects,
not successful test runs or allow-failure exceptions. They will block aggregate CI
until repaired through the module development branches. No module implementation
or manifest was modified as part of this expansion. The three development branch
source trees still match this worktree's source at inspection.

EXportGithub, Git-Functions and shared infrastructure are the other three inventory
components, not formal modules. They do not get invented module entries. All-module
CI still runs on their branches through the default routing. Gallery automation
and issue-completion mappings are unchanged.

## Trusted issue completion

`complete-issues` alone has `issues: write`. It requires successful actual upload
and successful verification outputs in this same workflow. No merge, PR event,
release event, dry-run, failure, cancellation or skipped job closes issues. It runs
trusted master automation only and executes no package code. Its JSON mapping is
`scripts/gallery/issue-map.json`, deliberately empty until a release is reviewed.
No dispatch input accepts issue numbers. Example **schema only**, not active data:

```json
[
  {
    "repository": "stadub/PowershellScripts",
    "module": "Base64String",
    "version": "REVIEWED_NEW_VERSION",
    "sourceSha": "REVIEWED_FULL_RELEASE_SHA",
    "issues": [22]
  }
]
```

Review this exact mapping on master **before** publishing. Do not map #29 unless
its broader rollout work is also complete. The issue comment records the versioned
Gallery URL, immutable source SHA, GitHub release link and verification workflow
run/artifact. A stable per-package marker prevents duplicate bot comments; closing
an already closed issue is a no-op. If interrupted between comment and close,
retry completes the close without duplicating evidence. PR numbers are rejected.

If upload succeeded but verification/closure failed, use GitHub's **re-run failed
jobs** to retry downstream work without uploading again. Re-running all jobs will
reject an existing Gallery version and cannot falsely report another actual upload.
Do not bypass that guard or close manually without verifying deployment evidence.

## Owner rollout and remaining blockers

1. Integrate automation into master and port read-only CI automation to maintained
   module branches. Run hosted CI and a dry-run release candidate before enabling
   required status checks. No hosted Actions runs/workflows existed at inspection.
2. For #22, the reviewed fix is commit
   `5fe9e2344afacccd4cebe02f178d6eb8cd162d2f`, merged by PR #28 into
   `base64tring/develop` at `4d2e1c86e8083202f74b9b31c48447c0cd82808e`.
   Do not redo it. Selectively port reviewed files/tests to
   `base64String/release/latest`, choose an unused version, update release notes,
   and regenerate/review out/ with matching implementation and manifest bytes.
   That branch was still `052b501de2762e10dd23267cce31c3bc84cf2d8c` on inspection.
   It does not contain the fix; current stale packages should fail the new gates.
3. Review and commit the exact issue mapping on master after the candidate SHA
   exists. Run dry-run with that SHA. Review source and installed NUnit artifacts,
   including both Windows runtimes. Then optionally create the GitHub release with
   `create_release=true,dry_run=true` and review its snapshot/assets.
4. Preserve `powershell-gallery` environment's custom deployment branch policy:
   **master only**, branch type, no tag wildcard. Live inspection on 2026-11-11 found
   one such policy, no reviewer rule, admin bypass enabled, and zero secrets.
   Do not treat master-only as independent reviewer approval. The owner should add
   required reviewers, prevent self-review and restrict admin bypass as available.
   This repository is public, so GitHub documents required-reviewer support here.
   On private repos, plan restrictions can make reviewers/wait timers unavailable
   (Free/Pro/Team support them only on public repos). A sole owner cannot provide
   an independent approval with self-review disabled; arrange a second trusted
   reviewer or document that organizational limitation before deployment.
5. The owner must create **environment** secret `PSGALLERY_API_KEY` using GitHub's
   settings UI or secure secret input; never print/paste it into code, logs, chat,
   issue comments or command arguments. Use a scoped Gallery key with appropriate
   package/account rights and expiry. Nothing here creates or changes secrets.
6. Only an explicitly authorized deployment run should set `dry_run=false` on
   master. Approve its environment after reviewing run SHA, version and hashes.
   Confirm Gallery verification and mapped issue evidence afterward. This task
   authorizes implementation, not that live upload.

## Local validation

Tools: `/tmp/ps-actions-tools/powershell/pwsh` 7.7.0, Pester 4.10.1 from
`/tmp/ps-actions-tools/modules`, actionlint 1.7.12 at
`/tmp/ps-actions-tools/actionlint/actionlint`.

```sh
/tmp/ps-actions-tools/actionlint/actionlint .github/workflows/*.yml
# Run each test in a fresh PowerShell process (the tests mock commands offline).
pwsh -NoProfile -NonInteractive -File tests/Test-CiSelection.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-CiRunner.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-CiStructure.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-GalleryAutomation.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-ReleaseEvidence.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-GalleryVerification.ps1
node tests/Test-IssueCompletion.cjs
node tests/Test-WorkflowSafety.cjs
node tests/Test-ReleaseCreation.cjs
```

All these automation contract checks passed locally. A temporary fixture extracted from the already
committed fix, with its matching flat out/ copy, also passed source and installed
regressions separately: **31 + 31**, macOS pwsh 7.7.0/Pester 4.10.1. This validates
runner behavior, not an actual release branch, Gallery download, or Windows run.
Windows 5.1/pwsh and hosted cross-platform tests remain deployment gates.

Official references consulted:
- [GitHub environment protection and plan limitations](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
- [PowerShell Gallery publishing](https://learn.microsoft.com/en-us/powershell/scripting/gallery/how-to/publishing-packages/publishing-a-package)
- [Publish-Module](https://learn.microsoft.com/en-us/powershell/module/powershellget/publish-module?view=powershellget-2.x)
- [Save-Module exact-version downloads](https://learn.microsoft.com/en-us/powershell/module/powershellget/save-module?view=powershellget-2.x)
