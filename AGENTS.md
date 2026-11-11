# Project instructions

## Review module branches before choosing a worktree base

This repository is a PowerShell module monorepo with per-module development and
release branches. Do not assume `master` contains every module fix or that release
branches contain only generated files.

Before starting module work:

1. Check the working tree and live remote branch tips. Refresh remote refs when
   needed before comparing them.
2. Compare the module's source, manifests, tests, and release `out/` directory with
   `master`. Commit ancestry alone is insufficient: packaged files can contain
   functional changes absent from source.
3. Review relevant GitHub issues, pull requests, and visible coding-agent tasks to
   avoid duplicating work. Check existing Orca worktrees and agents as well.
4. Choose the base using the module-specific guidance below, after verifying it
   still applies. Use the Orca CLI skill for Orca-managed worktrees.
5. Keep release artifacts out of source merges unless the task explicitly calls
   for them. Recover individual fixes selectively rather than merging an entire
   old release branch.

## Branch map and review baseline

Reviewed on 2026-11-11. Live remote tips matched the local remote-tracking refs;
`master` was `b3968f6`. These are historical findings, not substitutes for checking
the current remote state.

| Module | Remote branches | Findings relative to the reviewed master |
| --- | --- | --- |
| 7Zip | `7Zip/develop`, `7Zip/release/1.0`, `7-Zip/release/1.1` | Development recreated from release 1.1 plus these instructions. Release 1.1 module source matches the reviewed master; release 1.0 is older. |
| Bookmarks | `Bookmarks/develop`, `Bookmarks/release/v2.1`, `Bookmarks/release/latest` | Development source matches master at 2.2.0. Release latest adds packaged output with different shared helpers. Version 2.1 is an older merged baseline. |
| Currency-Conv | `Currency-Conv/develop`, `Currency-Conv/release/1.0`, `Currency-Conv/release/1.5` | Development recreated from release 1.5 plus these instructions. Release 1.5 module source matches the reviewed master; version 1.0 predates caching changes. |
| Pipe | `Pipe/develop`, `Pipe/release/latest` | Development source matches master; documentation differs. Release output contains functional packaging and alias changes absent from source. |
| Base64String | `base64tring/develop`, `base64String/release/latest` | Both contain version 1.2.0 decoder changes absent from master's 1.1.0. Their module source files match each other. Preserve the actual remote spelling `base64tring`. |

## Code and packaging concerns to verify

### Pipe

- `Shared-Functions/Pipe/Pipe.psd1` references scripts beside the manifest, while
  source scripts live under `Functions/`. Verify source imports and packaged
  imports separately.
- `Pipe/release/latest` flattens the scripts into `out/`, redirects `wtype` to
  `Limit-Type`, and adds `filter-type` and `where-type` aliases absent from source.
- Release `out/Limit-Type.ps1` still executes a stray `Where-Type` example. Do not
  copy that defect into the reconciled source or package.

### Base64String

- Commit `1f3e1fb` adds a decoder padding fallback missing from master. Review its
  behavior and tests alongside encoding issue #22; do not assume the fallback is
  a complete padding solution.
- That commit also adds an unrelated 344-line `PSM-Release.ps1`, subsequently
  deleted by `b057dda`. Recover module changes selectively.
- Test padded and unpadded input, URL-safe input, invalid input, encoding options,
  and compatibility with existing UTF-16 behavior when changing the decoder.

### Bookmarks

- Release `out/Shared-Functions.ps1` differs from source: update notifications use
  console output rather than pipeline output, and a profile-folder parameter is
  removed. Review those differences before regenerating or copying helpers.
- Source and release manifests contain a trailing space in
  `'Update-PSBookmark '`. Verify exported commands and aliases against the module
  implementation, including save/restore behavior.

### Shared packaging and installation

- No reviewed current branch tip contains `PSM-Release.ps1`; it exists in history.
  Establish a reproducible packaging process before relying on regenerated output.
- `install.ps1` downloads `master`, bypassing release-branch `out/` packages. Check
  the installed layout and imports when changing installation or packaging.
- Validate source and packaged manifests, file references, exported commands,
  aliases, and import-time side effects.
- PowerShell was unavailable locally during this review. Findings above are from
  static inspection; do not describe them as runtime-tested.

## Suggested worktrees

Follow the per-module development workflow: branch feature and issue work from the
module's development branch, and target that same branch for its pull request.
Being behind `master` does not make a module development branch the wrong base.
Bring in unrelated master changes only when needed and reviewed separately.

The user confirmed that the missing development branches were deleted and
authorized recreating them. `Currency-Conv/develop` starts from
`Currency-Conv/release/1.5` (`372e316`); `7Zip/develop` starts from
`7-Zip/release/1.1` (`6f8e8f6`). Both include these instructions. These are new
development branches, not recovered copies of an unknown deleted tip.

Use `/develop` branches for module changes and issue PRs. Use `/release/` branches
for reviewed release snapshots/package output and Gallery publishing. Do not use
a release branch as the default feature base just because development is missing.
If a development branch is missing again, inspect history and release/source
differences, propose a documented recreation base, and recreate it when authorized.
Keep older numbered releases as historical baselines. Release-only package output
still requires review before source changes are ported.

Recheck branch state before using the listed starting points. These instructions
do not automatically authorize creating worktrees or launching agents.

| Worktree | Suggested starting point | Scope |
| --- | --- | --- |
| `base64-reconcile` | `origin/base64tring/develop` | Build on existing 1.2.0 changes; address padding, encoding (#22), and tests. |
| `pipe-reconcile` | `origin/Pipe/develop` | Bring reviewed release-only fixes into source; repair imports and aliases. |
| `bookmarks-review` | `origin/Bookmarks/develop` | Reconcile packaged helpers; check exports and session behavior. |
| `7zip-maintenance` | `origin/7Zip/develop` | Address installed-runtime discovery (#23), Linux support (#25), and help metadata (#26). |
| `currency-maintenance` | `origin/Currency-Conv/develop` | Repair cache expiration (#17). |
| `module-packaging` | `origin/master` | Restore reproducible packaging and validate source/package imports and installer behavior. |

Use separate worktrees tracking `Bookmarks/release/latest`, `Pipe/release/latest`,
and `base64String/release/latest` when package comparison or validation requires
them. Retain the numbered release branches for maintenance and historical comparison.

Slow import/update-check issues #24 and #27 span module helper copies. Coordinate
that work across Bookmarks, 7Zip, Currency-Conv, and packaging so source and release
helpers do not diverge further. Coordinate packaging changes with module work;
these scopes can overlap. The current #24/#27 issue branch starts from
`Bookmarks/develop`: implement the Bookmarks change there, then port reviewed
changes separately to the 7Zip and Currency maintenance branches. Do not merge an
entire module branch into another module branch to share a helper fix.

## Existing issue worktrees

| Branch | Starting ref and intended PR target | Issues |
| --- | --- | --- |
| `fix/base64-encoding` | `base64tring/develop` | #22 |
| `fix/update-check-startup` | `Bookmarks/develop` | #24, #27 |
| `fix/currency-cache-expiry` | `Currency-Conv/develop` | #17 |
| `fix/7zip-runtime-help` | `7Zip/develop` | #23, #25, #26 |

Use the table's intended target explicitly when creating a PR; a Git upstream or
Orca's historical creation-base metadata does not set a GitHub PR base. These
worktrees were initially created from master and corrected before implementation.

## GitHub Actions migration and Gallery publishing

The user requested separate worktrees for CI migration and publishing:

- `ci/github-actions` in `github-actions-ci`: `.github/workflows/ci.yml`, module
  routing and Pester runners, removal of legacy CI configs, and rollout notes in
  `docs/github-actions-ci.md`. It targets master as repository-wide automation;
  its workflow/scripts must also be ported to maintained module branches.
- `ci/psgallery-publish` in `psgallery-deploy`: manual release workflow, package
  staging/publishing helpers, offline tests, and setup in
  `docs/powershell-gallery.md`. It checks out the module's release package branch
  explicitly; publishing sources are not module development/PR targets.

Keep these changes in their separate worktrees. Do not extend the superseded
Azure filter edits in issue worktrees. CI is read-only and receives no Gallery
secret. Publishing defaults to dry-run and only the actual publish job receives
`PSGALLERY_API_KEY` from the `powershell-gallery` GitHub environment. That
environment has been created with deployments restricted to master; the API-key
secret still needs to be configured by the owner. Never put that key in files or
chat. Do not publish packages while implementing or testing this automation.

Local validation used portable PowerShell 7.7.0 and actionlint 1.7.12. Module
routing, offline publishing checks, workflow lint, and staging/manifest validation
of all five configured release packages passed. This does not mean the legacy
functional Pester suites or hosted GitHub Actions runs have passed.
