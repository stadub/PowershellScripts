# Aggregate build failures and component repairs

Recorded 2026-11-12. [The original aggregate run](https://github.com/stadub/PowershellScripts/actions/runs/43087475163)
passed its automation planning/contracts and Uninstall checks, but failed 19 of
22 module/OS jobs. The aggregate branch still carried historical master copies,
while maintained module source and existing focused fixes lived elsewhere.
No failure was changed into a skip or allow-failure result.

| Module | Original failure |
| --- | --- |
| Base64String | Old 1.1 source/contradictory legacy test: 1 failed assertion per OS; corrected development/release snapshots already pass 34 cases |
| Bookmarks | 8 persistence assertions per OS and a trailing-space manifest export |
| Currency-Conv | 3 stale cache/API assertions per OS |
| 7zip-Archive | 6 legacy runtime-discovery assertions on Windows |
| Pipe | Manifest references scripts missing beside the source manifest |
| FolderEncoder | Manifest references deleted Functions.ps1 and exports the wrong command name |
| Shell-Functions | Manifest loads no implementation and exports no commands |
| Uninstall | No failure; syntax/import/public-parameter checks pass |

## Source selection correction

Repository-wide automation must not assume master has every module fix. CI now
resolves the eight maintained development refs to immutable SHAs for unchanged
modules. Component/release runs test the actual workflow source snapshot. Any
module runtime source/manifests/tests changed by a proposal are also tested from
that proposal's commit; cross-component changes expand coverage rather than being
ignored. Documentation-only changes and out/ copies do not replace source baselines.

For PRs, change detection uses the merge base with the PR target. For feature/CI
pushes, it uses the merge base with master, so earlier unmerged source changes stay
covered across later commits. A direct master push compares against the previous
push tip. NUL-separated Git paths handle whitespace in source filenames. Missing
or malformed maintained SHAs fail planning; there is no stale-root fallback.

Every matrix entry contains source ref, mode and exact SHA. Each job checks out
that source separately, uses the current automation runner, and publishes a
source-identity.json with its NUnit reports. This explicitly describes what was
tested; it does not claim the historical source copies on master are repaired.
Source selection has offline contracts for changed-source coverage, component and
release snapshots, all eight maintained baselines, immutable refs and single output.

## Reviewable component fixes

Existing focused owner commits were reused in new module-targeted branches. Original
owner checkouts and branches were preserved. All component hosted matrices pass:
three OS jobs each, except the established Windows-only 7zip-Archive route.

| Module | Merged PR / target | Pester cases | Hosted source checks |
| --- | --- | ---: | --- |
| Bookmarks | [40](https://github.com/stadub/PowershellScripts/pull/40) → Bookmarks/develop | 26 | [passed](https://github.com/stadub/PowershellScripts/actions/runs/43114997026) |
| Pipe | [41](https://github.com/stadub/PowershellScripts/pull/41) → Pipe/develop | 8 | [passed](https://github.com/stadub/PowershellScripts/actions/runs/43115004981) |
| Currency-Conv | [42](https://github.com/stadub/PowershellScripts/pull/42) → Currency-Conv/develop | 15 | [passed](https://github.com/stadub/PowershellScripts/actions/runs/43115009752) |
| 7zip-Archive | [43](https://github.com/stadub/PowershellScripts/pull/43) → 7Zip/develop | 19 | [passed](https://github.com/stadub/PowershellScripts/actions/runs/43115017582) |
| FolderEncoder | [44](https://github.com/stadub/PowershellScripts/pull/44) → FolderEncoder/develop | 3 | [passed](https://github.com/stadub/PowershellScripts/actions/runs/43115021526) |
| Shell-Functions | [45](https://github.com/stadub/PowershellScripts/pull/45) → Shell-Functions/develop | 6 | [passed](https://github.com/stadub/PowershellScripts/actions/runs/43115030061) |

Bookmarks preserves **both** 8eb0476 update-check throttling and b4a0e6f persistence/
export repairs (14 + 12 tests). Pipe reuses 2431e39, Currency 53ca85d and 7Zip cdb6c2e.
No whole component branch was merged to distribute common helpers.

FolderEncoder restores its historical Functions.ps1 byte-for-byte from before
4a336c7 and exports the documented Invoke-FolderEncode. Its three cases cover
manifest/import/export/parameter contracts and import-time filesystem safety.
They do **not** execute or validate the legacy encoder, downloads or archive
roundtrip. This import repair does not establish production encoder correctness.

Shell wires the existing implementation into its manifest, preserves the protected
fl alias, omits the dangling pb alias and scopes aliases to the module. It fixes
Split-String's method-property typo and the undefined link enum/provider item types.
Six cases cover actual text filters and mocked provider argument routing, not
Windows batch helpers, interactive prompts or real link creation.

## Combined validation and rollout

A separate **review-only** snapshot on ci/module-fixes-preview combines the exact
candidate source files with automation. It does not promote source into master,
module development branches or ci/release-pipeline. Its source ledger is
`docs/ci-module-preview.json` on that branch. The initial combined run
[43117606572](https://github.com/stadub/PowershellScripts/actions/runs/43117606572)
passed all 22 module/OS jobs, planning and aggregate status.

The final source-selection run [43120956188](https://github.com/stadub/PowershellScripts/actions/runs/43120956188)
at `9f6273bf9198dec336f56fe565665a37f7c84758` also passed all 24 jobs. Downloaded
artifacts independently confirm 22 source identities and 28 NUnit reports:
295 Pester assertions plus 24 structural assertions, zero failures and zero skips.
The seven changed modules use that exact review snapshot; Uninstall uses its pinned
development SHA. The file ledger links the snapshot's module files to their
component candidates. See [verified report hashes and source identities](ci-matrix-verified.json).

The owner explicitly approved merging PRs #40–45 on 2026-11-12. Each exact reviewed
head and base SHA, active source checks, required-check configuration and
mergeability was rechecked immediately before its normal merge commit. No rule
bypass was used. The retired AppVeyor failures were historical, non-required
contexts; their GitHub integration was already removed.

All six repairs are now on their respective module development branches. See
[merge and maintained-source identities](ci-component-merges.json). Fresh
[aggregate checks on PR #31](https://github.com/stadub/PowershellScripts/pull/31/checks)
resolve these maintained tips to immutable SHAs. No module behavior fixes were
added to automation PR #31, and no passing feature branch substitutes for a
maintained baseline. Master and release branches were not merged or edited.

Specifically, [the maintained-baseline run at automation commit 06ee2de](https://github.com/stadub/PowershellScripts/actions/runs/43120912939)
passed planning, Base64String and Uninstall (six module/OS jobs). Its historical
16 module/OS failures correspond to the six component repairs, which were then
unmerged. That failed run is preserved; it does not describe the newly integrated
development tips. The successful preview remains evidence for the proposed files,
while the fresh aggregate run tests the maintained branches after integration.

The already approved AppVeyor removal from master was synced into the automation
branch; this task did not edit master. Legacy external AppVeyor/Azure service
statuses are distinct from GitHub Actions. The owner subsequently authorized
[repository-side service removal](ci/legacy-ci-removal/README.md): both single-repo
GitHub app installations are removed, with YAML/badge cleanup in this branch.
Historical results remain because GitHub has no supported deletion operation;
external definitions/history remain inaccessible. No results were masked as success.

No release out/ package, Gallery routing, environment restriction, secret or issue
completion was changed by these source repairs. Base64String 1.3.0 release evidence
and the exact publish-gated #22 mapping remain unchanged. Nothing was published.

See [machine-readable PR/source/job evidence](ci-build-repairs.json).
