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

| Module | Draft PR / target | Pester cases | Hosted source checks |
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
roundtrip. This draft needs component review before any production-use decision.

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
passed all 22 module/OS jobs, planning and aggregate status. Hosted validation of
the updated explicit source-selection workflow is recorded below after completion.

Component PRs remain draft; passing CI is not merge approval. Until their reviewed
changes land on the maintained development branches, aggregate monitoring correctly
continues to report those unfixed baselines. Review/approve the component PRs first,
then rerun aggregate CI against the resulting maintained tips. No module behavior
fixes were added to automation PR #31, and no source snapshot was substituted with
a passing unreviewed branch in its maintained-baseline matrix.

The already approved AppVeyor removal from master was synced into the automation
branch; this task did not edit master. Legacy external AppVeyor/Azure service
statuses are distinct from GitHub Actions and may still require owner-side cutover
access. This work neither re-enables old YAML nor hides such statuses.

No release out/ package, Gallery routing, environment restriction, secret or issue
completion was changed by these source repairs. Base64String 1.3.0 release evidence
and the exact publish-gated #22 mapping remain unchanged. Nothing was published.

See [machine-readable PR/source/job evidence](ci-build-repairs.json).
