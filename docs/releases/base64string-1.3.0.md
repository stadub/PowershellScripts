# Base64String 1.3.0 prepared release snapshot

Prepared on 2026-11-11. This is a tested Git release snapshot, **not a Gallery
deployment**. Issues #22 and #29 remain open. No versioned GitHub release was created.

- Release branch: `base64String/release/latest`
- Exact tested release commit: `6d30dbc22de8bfb8bccda5cd3880ffb9a6655f5f`
- Package path: `Shared-Functions/Base64String/out`
- Gallery account: `MiniModules`; required environment secret: `PSGALLERY_API_KEY_MINIMODULES`
- [Payload SHA256 evidence](base64string-1.3.0-evidence.json)
- [Downloaded-artifact verification](base64string-1.3.0-validation.json)
- [Successful exact-commit hosted run](https://github.com/stadub/PowershellScripts/actions/runs/43086442317)

## Review and integration

[PR #30](https://github.com/stadub/PowershellScripts/pull/30) selectively ported the
reviewed encoding/pipeline fix from PR #28, bumped the source/package version and
release notes, and populated out/. Its initial tests exposed a .NET Framework
padding difference: Windows PowerShell 5.1 accepted malformed `Zm8==`.

[PR #32](https://github.com/stadub/PowershellScripts/pull/32) added an explicit
padding-shape guard through `base64tring/develop` (merge
`51b283c5da01fd5a962bbd9194a07a8bf24b5ce4`). It preserves all 31 original regressions
and adds three malformed-padding cases. The source-only validation passed all
four runtimes before the guard/tests were selectively ported into the release.

The owner explicitly confirmed WTFPL. Source LICENSE, packaged LICENSE and both
manifest URLs now agree; the repository-wide BSD-2-Clause license is unchanged.
Existing license edits were preserved. Commit a3b8551 has an inaccurate padding-port
message: it recorded those license edits; 564a30c contains the actual guard port
and regenerated package. The history was not rewritten. Generation prefers the
module-local license, and staging never overwrites a package license with the root
fallback. Source/generated/staged WTFPL SHA256:
`6fcb3400cc6126e54b9c5be59bb396fd2ce4cd6d075ec559f0aa4171372307be`.

Comparing the first passing release artifacts caught Windows CRLF conversion.
[PR #34](https://github.com/stadub/PowershellScripts/pull/34) added a Base64String-local
.gitattributes policy for LF text and binary images. The final exact release tip
was tested again after integration; all four artifacts now contain identical
payload bytes, not merely equivalent normalized text.

## Final verification

Pester is pinned to 4.10.1. Every job passed 34 source and 34 installed-package
regressions, manifest/import/export checks and independent regeneration/hash
comparison. Downloaded artifacts were checked against the payload hashes computed
from a fresh Git archive of the exact release commit. All six payload files agree
across platforms; all eight NUnit reports have 34 tests and zero failures.

| Runtime | Source / installed tests | Package and test artifact |
| --- | --- | --- |
| Windows PowerShell 5.1 | 34 / 34 | [artifact](https://github.com/stadub/PowershellScripts/actions/runs/43086442317/artifacts/13887505451) |
| Windows pwsh | 34 / 34 | [artifact](https://github.com/stadub/PowershellScripts/actions/runs/43086442317/artifacts/13886971654) |
| Linux pwsh | 34 / 34 | [artifact](https://github.com/stadub/PowershellScripts/actions/runs/43086442317/artifacts/13885953800) |
| macOS pwsh | 34 / 34 | [artifact](https://github.com/stadub/PowershellScripts/actions/runs/43086442317/artifacts/13886117879) |

## Remaining rollout gates

The production manual workflow is not on master yet (contents lookup returned 404).
Automation [PR #31](https://github.com/stadub/PowershellScripts/pull/31) remains a draft;
its offline automation checks pass. The six component baseline repairs were merged
into their module development branches after explicit owner approval; see
[integration evidence](../ci-component-merges.json). Verify fresh maintained-source
CI before choosing required contexts. Integrate reviewed automation separately.
The owner's concurrent AppVeyor removal was
merged into master through PR #33; this task did not change master or sibling worktrees.

After production workflow integration, run `release-gallery.yml` from master with:

- module: `Base64String`
- version: `1.3.0`
- source_sha: `6d30dbc22de8bfb8bccda5cd3880ffb9a6655f5f`
- create_release: `false`
- dry_run: `true`

This full production dry-run is still pending; the successful runs above are its
credential-free source/package validation, not a simulated successful upload.
Both Gallery account secret names were present at the 2026-11-12 metadata check;
their opaque values, account rights and expiry remain unverified. Preserve the
environment's master-only branch policy and establish independent reviewer protection.
Any actual publish remains
separately authorized and must verify exact Gallery package/version/content before
issue completion. The trusted mapping in PR #31 targets only #22 for this version
and SHA; #29 is deliberately excluded. A GitHub release, dry-run or merge never
completes either issue.
