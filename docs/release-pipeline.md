# Tested releases and protected PowerShell Gallery publication

This is automation for issue #29, not a deployment of the #22 fix. #22 stays open.
No live Gallery upload, GitHub release creation, issue completion or secret edit
was performed. The owner approved PR #31 integration into master at
912d1d9bde07b95299f46eb99add2ae58bd2a0c9; its hosted CI passed. The separately
authorized Base64String release preparation is recorded in
[the 1.3.0 snapshot report](releases/base64string-1.3.0.md).

## Ownership and integration

`ci/release-pipeline` selectively reuses the routing/runner from the read-only
`github-actions-ci` worktree and configuration/staging/preflight checks from the
read-only `psgallery-deploy` worktree. The sibling files were uncommitted and have
continued owner activity: merge this integrated implementation deliberately, not
both its workflow and the sibling `publish-gallery.yml`. Preserve the original five
routes and their ownership. The owner subsequently authorized three additional
packages; their candidates remain review-blocked as described below. Public usernames and the module-to-account
mapping live in `scripts/gallery/Get-ReleaseConfig.ps1`; API keys live in separate
protected environment secrets. The selected key alone is passed to the upload
process as `PSGALLERY_API_KEY`. Do not merge a duplicate sibling publishing workflow.


The owner subsequently explicitly authorized removing Azure DevOps and AppVeyor.
Both GitHub app installations were removed after verifying each selected only this
repository. This branch removes the four remaining Azure YAML definitions and
obsolete Azure/AppVeyor badges; the approved AppVeyor YAML deletion is preserved.
The owner lacks external service access, so internal definitions/history remain.
GitHub provides no supported individual deletion for their historical check/status
results. See [exact removal and limitations](ci/legacy-ci-removal/README.md).
Only require `CI status` after a real hosted run succeeds on each maintained branch.

## Inputs and behavior

Run `release-gallery.yml` manually. Select a module from the dropdown and enter
its prepared stable version number. Use the per-module
[Gallery version reference plan](releases/gallery-version-reference.md); `1.3.0`
is the prepared Base64String version, not a shared default. No commit SHA is required in
the form. The workflow resolves the configured reviewed release branch once to a
full immutable SHA, records it in the run summary, and passes that exact SHA to
every checkout, test, release, publication, verification and issue-completion job.
The entered version must match both reviewed source and out/ manifests; entering a
new number does not silently rewrite an unreviewed package. Development is never
a publication fallback. The configured sources are:

| Module | Release branch | Package directory |
| --- | --- | --- |
| Bookmarks | Bookmarks/release/latest | Bookmarks/out |
| 7zip-Archive | 7-Zip/release/1.1 | 7Zip/out |
| Currency-Conv | Currency-Conv/release/1.5 | Currency-Conv/out |
| Base64String | base64String/release/latest | Shared-Functions/Base64String/out |
| Pipe | Pipe/release/latest | Shared-Functions/Pipe/out |
| FolderEncoder (review-blocked) | FolderEncoder/release/2.0.1 | FolderEncoder/out |
| Shell-Functions (review-blocked) | Shell-Functions/release/0.0.1 | Shell-Functions/out |
| MiniModules.Uninstall (review-blocked) | Uninstall/release/1.0.1 | ./out |

The three new release refs begin at their reviewed component baselines; candidate
PRs explicitly add the source preparation and generated out/. Their final integration
requires separate owner approval. See [candidate evidence and limitations](releases/new-module-packaging.md).
`Get-ReleaseConfig.ps1 -RequirePublication` rejects GitHub release creation and
upload for these candidates while review blocks are present; read-only dry-run
and candidate validation remain available after packaging lands.

These are literal Git branch names. The owner clarified that GitHub's
`/releases/latest` is a release URL alias, not a requirement to create branches
ending in latest. The 7Zip/Currency routes therefore use their verified reviewed
numbered refs. The existing Bookmarks/Pipe/Base64 branches named latest are real
branches and remain valid preparation sources. The GitHub URL alias is repository-wide;
the versioned release tag and recorded SHA identify the individual module package.

`PackagePath` follows one rule for every configured module:
**<module source directory>/out** within the reviewed release snapshot. The nested
Shared-Functions prefix remains part of Base64String's and Pipe's source layout.
Staging never falls back to source files beside out/ when a package is missing.

The historical numbered 7Zip and Currency-Conv snapshots used their module
directories directly. Their configured snapshots must instead contain reviewed
`7Zip/out` and `Currency-Conv/out` packages with matching source/manifest bytes.
Preparing those release snapshots remains a rollout prerequisite; this automation
change does not generate or commit release artifacts into development source.
No new latest branch is required solely because of GitHub's release URL alias.

### Gallery accounts and credential setup

Live public package pages checked on 2026-11-11 list these **Owners**, rather than
relying on the module manifest's Author field:

| Module | Gallery owner / configured deployment account | Environment secret |
| --- | --- | --- |
| [Bookmarks](https://www.powershellgallery.com/packages/Bookmarks/3.0.1) | Stadub | PSGALLERY_API_KEY_STADUB |
| [7zip-Archive](https://www.powershellgallery.com/packages/7zip-Archive/1.1.0) | Stadub | PSGALLERY_API_KEY_STADUB |
| [Currency-Conv](https://www.powershellgallery.com/packages/Currency-Conv/1.0.2) | Stadub | PSGALLERY_API_KEY_STADUB |
| [Base64String](https://www.powershellgallery.com/packages/Base64String/1.2.0) | MiniModules | PSGALLERY_API_KEY_MINIMODULES |
| [Pipe](https://www.powershellgallery.com/packages/Pipe/1.0.0) | MiniModules | PSGALLERY_API_KEY_MINIMODULES |
| [FolderEncoder](https://www.powershellgallery.com/packages/FolderEncoder/2.0.0) | Stadub | PSGALLERY_API_KEY_STADUB |
| Shell-Functions (new; owner-selected account) | MiniModules | PSGALLERY_API_KEY_MINIMODULES |
| MiniModules.Uninstall (new; owner-selected account) | MiniModules | PSGALLERY_API_KEY_MINIMODULES |

Usernames are public configuration, not secrets. Each module names its
`GalleryAccount`; the account-to-secret-name table in the same script supplies
`GallerySecret`. Neither account nor secret name is a dispatch input. A trusted,
credential-free step resolves the module's account and secret name, and the upload
step uses `secrets[steps.account.outputs.secret]`. It receives only that key as
`PSGALLERY_API_KEY` and the configured username as `PSGALLERY_ACCOUNT`. The helper
rejects an absent/mismatched username or absent key; there is no generic-key or
other-account fallback. Reviewable job summaries record account/secret **names**,
never values. Dry-runs and non-upload steps never receive either API key.

The owner opens repository Settings -> Environments -> powershell-gallery ->
Environment secrets -> Add environment secret and creates both named secrets,
using a Gallery key generated while signed into the corresponding account. Scope
the Stadub key to its four mapped packages and the MiniModules key to its four
mapped packages, including first-publication rights for the two approved new names,
with suitable push/update permissions and expiry. Do not replace one account's key
when deploying another module. The previous generic `PSGALLERY_API_KEY` environment
secret is not read by this workflow and need not be configured.

Preserve master-only deployment restrictions and configure independent reviewers
as described below. Metadata inspection on 2026-11-12 found both named secrets
present (updated 2026-11-11); no secret value was accessed or changed by this task.
Presence does not verify a key's validity. Public owner lookup confirms the
mapping, not the identity or permissions of a secret's opaque API key. Gallery
itself authenticates that key at upload. Publish-Module authenticates through the
API key; a username or manifest Author field cannot switch accounts.
See [Microsoft's ownership rules](https://learn.microsoft.com/en-us/powershell/gallery/how-to/publishing-packages/managing-package-owners?view=powershellget-3.x)
and [scoped API key setup](https://learn.microsoft.com/en-us/powershell/gallery/how-to/managing-profile/creating-apikeys?view=powershellget-3.x).

### Set or rotate the keys from your terminal

`scripts/gallery/Set-GalleryApiKey.ps1` creates or updates the correct environment
secret for a selected module, using the same trusted account mapping as deployment.
Authenticate GitHub CLI to github.com with an account allowed to manage this
repository's environment secrets, then run:

```powershell
gh auth login --hostname github.com
# Preview the exact target: no GitHub request, prompt or secret update.
./scripts/gallery/Set-GalleryApiKey.ps1 -Module Base64String -WhatIf
# gh prompts for the MiniModules Gallery API key with input hidden.
./scripts/gallery/Set-GalleryApiKey.ps1 -Module Base64String
# gh prompts for the Stadub Gallery API key with input hidden.
./scripts/gallery/Set-GalleryApiKey.ps1 -Module Bookmarks
```

The MiniModules key is shared by Base64String/Pipe/Shell-Functions/MiniModules.Uninstall;
the Stadub key is shared by Bookmarks/7zip-Archive/Currency-Conv/FolderEncoder. Rotating one updates that account's credential
for all its mapped modules. The GitHub login and Gallery account are separate
identities: enter the Gallery account's publishing key, not a GitHub token.
`-Repository owner/repo` can explicitly select another repository; the default is
`stadub/PowershellScripts`. Secret names and the environment cannot be overridden.

The helper checks that the environment already exists and permits only master,
then invokes `gh secret set` with `--env powershell-gallery` and the mapped name.
It does not create environments or alter reviewer/branch protection. GitHub CLI
owns the hidden prompt (or stdin) and local encryption; the key is never a script
parameter, command argument, environment variable, file or printed output.
Afterward the helper reads only secret metadata (name/update time). GitHub does
not return secret values, so this cannot verify Gallery key identity/permissions.
A failed metadata check after a successful update is reported distinctly.
No workflow is dispatched, release created, package published or issue completed.

See [the official gh secret set manual](https://cli.github.com/manual/gh_secret_set).
No real secret was set while implementing or testing this helper; its tests use a
fixture command and the real helper was invoked only with `-WhatIf`.

After integration into master and preparation of a tested release snapshot, open
Actions -> Tested release and protected Gallery deployment -> Run workflow. Select
master, module and prepared version number. Start with dry_run=true and
create_release=false. Inspect the resulting package/tests, optionally create the
GitHub release with create_release=true while retaining dry_run=true, and only
when actual deployment is authorized choose dry_run=false and approve its protected
environment. Configuring a secret does not itself trigger a deployment.

The manual form appears only after the workflow is integrated into the default
branch (`master`). A branch-only workflow does not expose the Run workflow form.
See [GitHub's manual workflow documentation](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow).
The form contains:

- **Module to release**: Bookmarks, 7zip-Archive, Currency-Conv, Base64String, Pipe,
  FolderEncoder, Shell-Functions or MiniModules.Uninstall.
- **Version already prepared for this module**: match that module’s committed
  source/out manifests and the [version reference plan](releases/gallery-version-reference.md).
- **Also create the GitHub release during a dry-run**: unchecked by default.
- **Validate only; uncheck to publish to PowerShell Gallery**: checked by default.

`dry_run=true` (default) prevents Gallery publication and issue completion.
`create_release=false` (default) also prevents GitHub release creation. A release-only
run explicitly sets `create_release=true`, retaining `dry_run=true`. Any mutation
requires dispatch from master. Setting `dry_run=false` creates/verifies the tested
GitHub release first, then requests the protected environment before upload.
Concurrency serializes each module, and never cancels an active publish.

Staging copies only allowed flat package files plus LICENSE from the immutable
snapshot. The workflow independently regenerates output with New-ReleaseOutput.ps1
and checks its staged hashes against the committed package. It does not recover
historical PSM-Release.ps1 or silently replace stale committed output. Every staged script,
module and manifest must match the corresponding source bytes (flattened names
must be unique). Source/package divergence blocks release. Reconcile known Pipe
and Bookmarks helper/manifest differences in their component release reviews.

The same staged artifact is tested on Windows PowerShell 5.1 and pwsh on Windows,
Linux and macOS (7zip-Archive runtime suites remain Windows-only). Tests use pinned
Pester 4.10.1. Source suites run separately against an installed copy, imported by
absolute manifest path; suite files never enter the publish payload. Pipe runs its source Pester suites when present, with manifest checks on older
snapshots without suites. CI covers all eight formal modules. The three newly authorized publication
candidates retain explicit mutation blocks until review. See the coverage table below.

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

## Gallery version references

`scripts/gallery/version-reference.json` records the observed latest listed and
highest registered stable versions (including unlisted packages), downloaded
reference archive/runtime hashes, source/release SHAs and the next version plan.
`Get-ReleaseConfig.ps1` exposes LatestGalleryVersion, HighestRegisteredVersion,
PlannedVersion, VersionChange and VersionPlanStatus. The release workflow checks
these references before staging and records them in the run summary. Only 7Zip
has a planned major bump. Zero fourth-segment versions cannot bypass registered
version checks. This is a dated reviewed reference, not a live query or a package
builder; refresh it against Gallery before rollout. Actual upload still performs
its existing credential-scoped live Gallery preflight.

Bookmarks publication/release creation is additionally blocked pending
reconciliation with the downloaded 3.0.1 implementation; do not relabel the stale
2.2.0 source. See [exact version decisions and blockers](releases/gallery-version-reference.md).

## Populate a missing or stale out/ package

`New-ReleaseOutput.ps1` builds the eight configured packages from source; it does
not publish, change versions, recover release-only fixes or overwrite old output.
Prepare the module's reviewed release branch first. For Base64String, selectively
port the already-reviewed #22 fix and regression suite from development, choose an
unused version and update source manifest/release notes. For 7Zip/Currency-Conv,
prepare their configured reviewed numbered release sources first.
Do not generate a package from old master source and call it the fixed release.

Run the helper from this automation checkout with a separate reviewed release
checkout as input. This example uses Base64String; version 1.3.0 is illustrative
and must be checked against Gallery before choosing it:

```powershell
$releaseRoot = '/path/to/reviewed-release-checkout'
$version = '1.3.0' # Must match that checkout's updated source manifest.
$candidate = Join-Path ([IO.Path]::GetTempPath()) "base64-candidate-$([guid]::NewGuid())"
$stage = Join-Path ([IO.Path]::GetTempPath()) "base64-stage-$([guid]::NewGuid())"
./scripts/gallery/New-ReleaseOutput.ps1 -Module Base64String -SourceRoot $releaseRoot -OutputRoot $candidate -ExpectedVersion $version
./scripts/gallery/Build-GalleryPackage.ps1 -Module Base64String -SourceRoot $candidate -OutputRoot $stage -ExpectedVersion $version
./scripts/gallery/Assert-SourcePackage.ps1 -Module Base64String -SourceRoot $releaseRoot -PackageRoot $stage
./scripts/gallery/Test-ReleasePackage.ps1 -Module Base64String -SourceRoot $releaseRoot -PackageRoot $stage -ExpectedVersion $version
```

The generated folder is `$candidate/Shared-Functions/Base64String/out`. Compare it
with the release checkout's existing out/ folder. Review every source/manifest,
README, icon and license change; replace that checkout's entire old out/ with the
generated folder after review (do not overlay and retain obsolete files). Stage
and commit the reviewed source/version/tests and out/ changes on the configured
release branch. Push the reviewed commit, then select its module and version in a
manual dry-run. Confirm the automatically resolved SHA in the run summary matches
the reviewed commit; later jobs reuse that immutable value.
Windows tests remain hosted workflow gates, even when local checks succeed.

The helper flattens runtime scripts into the established flat package layout,
requires unique filenames, preserves source/manifest bytes, includes README,
primary icon and explicit module LICENSE (repository LICENSE only as a fallback),
and excludes tests, CI files, old out/ and
source assets other than the primary icon. Missing dependencies and ambiguous
filenames fail validation before a destination package is created. If the source
requires a different runtime layout, reconcile that layout in a separate reviewed
source/packaging change; the generator does not rewrite manifests or script paths.

The release workflow still requires a committed, reviewable out/ package. It also
regenerates output independently from the same immutable source and verifies that
the staged files match the committed package's hashes. This catches stale or extra
package files and produces reproducible file contents, without making development
source a fallback deployment input. Use a new output root for each generation;
existing directories are never deleted or overwritten by the helper.

## CI coverage for all modules

The user subsequently requested CI for all modules. Master, automation branches
and unknown feature branches now select all eight modules (22 OS/module jobs).
Module development branches and PR targets select their own module; changed source
in another component adds its coverage. Repository-wide runs pin maintained
development commits for unchanged modules and test changed modules at the proposal
SHA. Every job records its source identity; see [build repairs and source selection](ci-build-repairs.md). Existing
7zip-Archive runtime suites remain Windows-only; all other entries run pwsh on
Windows, Linux and macOS. The release workflow lists eight packages; the three new routes are review-blocked.

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

FolderEncoder and Shell-Functions import defects were repaired through their
component development PRs #44/#45 and now have 3 and 6 focused source tests.
The new Uninstall packaging candidate adds 3 safe manifest/import/parameter tests.
These run separately against source and installed output. The import/structure
checks also produce NUnit-compatible reports. No test invokes real uninstall,
encoding, downloads or archive roundtrips; those legacy behaviors remain outside
this packaging validation. See [component merge evidence](ci-component-merges.json)
and [the new package candidates](releases/new-module-packaging.md).

EXportGithub, Git-Functions and shared infrastructure are the other three inventory
components, not formal modules. They do not get invented module entries. All-module
CI still runs on their branches through the default routing. Issue-completion mappings remain unchanged; only the exact Base64String 1.3.0
release SHA can complete #22 after actual verified publication.

## Trusted issue completion

`complete-issues` alone has `issues: write`. It requires successful actual upload
and successful verification outputs in this same workflow. No merge, PR event,
release event, dry-run, failure, cancellation or skipped job closes issues. It runs
trusted master automation only and executes no package code. Its JSON mapping is
`scripts/gallery/issue-map.json`. The prepared Base64String 1.3.0 entry maps only
its exact tested release SHA to #22; #29 remains outside automatic completion.
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

Review the committed exact mapping on master **before** publishing. Do not map #29 unless
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

1. PR #31 is integrated into master, and the read-only CI automation was ported to
   maintained module branches. Run hosted CI and a full production dry-run before enabling required status
   checks. The prepared Base64String snapshot now has passing hosted validation;
   the production manual workflow is now integrated in master via PR #31.
2. For #22, the reviewed fix is commit
   `5fe9e2344afacccd4cebe02f178d6eb8cd162d2f`, merged by PR #28 into
   `base64tring/develop` at `4d2e1c86e8083202f74b9b31c48447c0cd82808e`.
   Do not redo it. Selectively port reviewed files/tests to
   `base64String/release/latest`, choose an unused version, update release notes,
   and regenerate/review out/ with matching implementation and manifest bytes.
   This preparation is now complete for 1.3.0: PR #30 integrated the reviewed source,
   version, owner-confirmed WTFPL license and regenerated out/; PR #32 added the
   Windows/.NET Framework padding follow-up through development; PR #34 fixed
   checkout line endings. The prepared release tip is
   `6d30dbc22de8bfb8bccda5cd3880ffb9a6655f5f`.
   See [exact snapshot evidence](releases/base64string-1.3.0.md).
3. The exact issue mapping from PR #31 is integrated into master. Run a
   Base64String 1.3.0 dry-run and verify the resolved SHA matches the prepared
   snapshot above. Review source and installed NUnit artifacts,
   including both Windows runtimes. Then optionally create the GitHub release with
   `create_release=true,dry_run=true` and review its snapshot/assets.
4. Preserve `powershell-gallery` environment's custom deployment branch policy:
   **master only**, branch type, no tag wildcard. Live inspection on 2026-11-12 found
   one such policy, no reviewer rule and admin bypass enabled.
   Do not treat master-only as independent reviewer approval. The owner should add
   required reviewers, prevent self-review and restrict admin bypass as available.
   This repository is public, so GitHub documents required-reviewer support here.
   On private repos, plan restrictions can make reviewers/wait timers unavailable
   (Free/Pro/Team support them only on public repos). A sole owner cannot provide
   an independent approval with self-review disabled; arrange a second trusted
   reviewer or document that organizational limitation before deployment.
5. Both **environment** secret names `PSGALLERY_API_KEY_STADUB` and
   `PSGALLERY_API_KEY_MINIMODULES` are present as of 2026-11-12. The owner must verify
   their account, package scope and expiry; rotate through settings or the helper if needed.
   Never print/paste their values into code, logs, chat, issue comments or command
   arguments. Use each account's scoped Gallery key with appropriate package rights
   and expiry. Nothing here creates or changes secrets.
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
pwsh -NoProfile -NonInteractive -File tests/Test-CiSources.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-CiRunner.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-CiStructure.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-GalleryAutomation.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-ReleaseSelection.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-ReleaseVersionReferences.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-GalleryKeySetup.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-ReleaseOutput.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-ReleaseEvidence.ps1
pwsh -NoProfile -NonInteractive -File tests/Test-GalleryVerification.ps1
node tests/Test-IssueCompletion.cjs
node tests/Test-WorkflowSafety.cjs
node tests/Test-ReleaseCreation.cjs
```

All these automation contract checks passed locally. A temporary fixture extracted from the already
committed fix, packaged by New-ReleaseOutput.ps1 and staged by Build-GalleryPackage.ps1,
also passed source and installed regressions separately: **31 + 31**, macOS pwsh 7.7.0/Pester 4.10.1. This validates
runner behavior, not an actual release branch, Gallery download, or Windows run.
Windows 5.1/pwsh and hosted cross-platform tests remain deployment gates.

Official references consulted:
- [GitHub environment protection and plan limitations](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
- [PowerShell Gallery publishing](https://learn.microsoft.com/en-us/powershell/scripting/gallery/how-to/publishing-packages/publishing-a-package)
- [Publish-Module](https://learn.microsoft.com/en-us/powershell/module/powershellget/publish-module?view=powershellget-2.x)
- [Save-Module exact-version downloads](https://learn.microsoft.com/en-us/powershell/module/powershellget/save-module?view=powershellget-2.x)
