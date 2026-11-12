# Three additional Gallery package candidates

The owner authorized release preparation for all eight formal modules and explicitly
selected MiniModules for both Shell-Functions and the new MiniModules.Uninstall
name. This is preparation only: no Gallery upload, GitHub release, tag, merge,
secret change or environment change is authorized here.

| CI component | Gallery package | Version | Account | Prepared package path |
| --- | --- | --- | --- | --- |
| FolderEncoder | FolderEncoder | 2.0.1 | Stadub | FolderEncoder/out |
| Shell-Functions | Shell-Functions | 0.0.1 | MiniModules | Shell-Functions/out |
| Uninstall | MiniModules.Uninstall | 1.0.1 | MiniModules | ./out |

All three publication entries are explicitly review-blocked. `RequirePublication`
rejects GitHub release creation and actual upload before secrets are supplied.
Read-only generation, staging and candidate validation use the public config.
The existing five package/account mappings, dry-run default, master-only secret
boundary and exact verified-publish issue-completion gates remain in effect.
The issue map gains no entries; #22 and #29 remain open.

## Gallery audit and identity

On 2026-11-12 the official package API and Gallery pages showed:

- [FolderEncoder 2.0.0](https://www.powershellgallery.com/packages/FolderEncoder/2.0.0)
  is owned by Stadub; 2.0.1 is not present in the exact-name version feed.
- No exact Shell-Functions or Shell-Function release was found, and neither appears
  on the [Stadub](https://www.powershellgallery.com/profiles/Stadub) or
  [MiniModules](https://www.powershellgallery.com/profiles/MiniModules) profiles.
  MiniModules is an explicit owner choice for this new package, not inferred from
  its manifest Author field.
- [Uninstall 1.0](https://www.powershellgallery.com/packages/Uninstall/1.0) is an
  **unlisted script**, owned by DimaStadub. It is left untouched. The owner chose
  the distinct module name MiniModules.Uninstall under MiniModules. No exact
  MiniModules.Uninstall API entry was found; this does not reserve the name or
  prove API-key rights for first publication.

See `new-module-gallery-audit.json` for sanitized exact-name API observations.
Authors are attribution; Gallery Owners determine existing package control.
The owner must ensure the existing account keys include these package scopes and
first-publication rights. Only key names/update timestamps were read; no real key
was entered, read or changed. The environment still allows only branch master,
has no required-reviewer rule and permits administrator bypass. Independent
reviewer protection must be configured separately where supported; a sole owner
cannot independently approve their own run with self-review disabled.

## Source and package changes

FolderEncoder 2.0.1 builds on reviewed develop commit
`9b339c1d02e67e601b253da97d770c43242953ca`. It preserves its existing MIT LicenseUri;
repository BSD text is deliberately not injected. The version bump, LF policy
and release notes do not change the legacy encoder implementation. The already
approved obsolete Azure/AppVeyor badges are removed from the packaged README.

Shell-Functions 0.0.1 builds on
`5cd269b6602e973af70387ce04eaf26b82e04b89`. Its canonical manifest is now
Shell-Functions.psd1, matching the package name. Shell-Function.psd1 remains as
source compatibility metadata. Both declare the same exports and required
publication metadata. A local copy of the existing repository BSD-2-Clause license
is packaged. Runtime implementation remains unchanged.

MiniModules.Uninstall 1.0.1 builds on
`cb191cc44ec85174187958b994065f6452ae046f`. Its new manifest points to the unchanged
Uninstall.psm1; the staged directory/manifest name is MiniModules.Uninstall while
CI remains Uninstall. Explicit runtime-file selection limits the root package to
MiniModules.Uninstall.psd1, Uninstall.psm1, Uninstall.md and LICENSE. Existing runtime
CRLF bytes are preserved explicitly; unrelated repository scripts are excluded.

All generated output belongs only in the release candidate PRs. Component source
PRs contain metadata/tests/docs and no out/ artifacts. Release candidates explicitly
include their unmerged component-source preparation so review does not assume it
already landed. No whole unrelated module branch is merged into another component.

## Validation and limits

Local PowerShell 7.7.0 / Pester 4.10.1 checks passed separately against source and
installed output: FolderEncoder 3 + 3, Shell-Functions 6 + 6, Uninstall 3 + 3.
Manifest/import/export checks also passed. Generation/staging are deterministic,
source/runtime hashes match, and root packaging excludes unrelated modules.
All ten PowerShell offline contract scripts, three Node security/release contract
suites and actionlint 1.7.12 passed locally. Generated copies retain baseline source
whitespace; no runtime bytes were rewritten to silence Git whitespace warnings.

These are packaging/API checks, not proof of all product behavior. FolderEncoder
checks do not encode files, fetch external tools, or exercise archive roundtrips.
Uninstall checks never read real HKLM entries, invoke msiexec or remove software.
Its existing Windows registry/uninstall implementation is unchanged and remains
unvalidated. Shell link-provider tests mock New-Item; they create no real links.
Windows PowerShell 5.1 and hosted pwsh on Windows/Linux/macOS remain explicit
candidate gates; local macOS results alone do not satisfy them.

## Review and rollout

Exact source/candidate SHAs and per-file SHA-256 hashes are in
[new-module-candidates.json](new-module-candidates.json).

| Package | Component source PR | Release candidate PR | Candidate commit |
| --- | --- | --- | --- |
| FolderEncoder | [#46](https://github.com/stadub/PowershellScripts/pull/46) | [#49](https://github.com/stadub/PowershellScripts/pull/49) | `afb5b7ef10cd53c388d4c6a6b6f6f8d5fb7652d6` |
| Shell-Functions | [#47](https://github.com/stadub/PowershellScripts/pull/47) | [#50](https://github.com/stadub/PowershellScripts/pull/50) | `5b83779c7c62cca738dc99770ce3724ed4e7fb85` |
| MiniModules.Uninstall | [#48](https://github.com/stadub/PowershellScripts/pull/48) | [#51](https://github.com/stadub/PowershellScripts/pull/51) | `a351e867d6fdb14a9650fc1d4f12f67e2dcfdf4c` |

The separate additional-gallery-candidates.yml workflow pins automation to
42814913be33a4662a57dbf011333b96c5fa294f and each candidate to the full commit
above, then calls the existing read-only four-runtime validator. Artifact names
include the package identity to avoid collisions between the three calls. Versioned release base refs begin at the reviewed
develop baselines; candidate PRs add the prepared source and generated out/.
Until those candidates are integrated, their base refs intentionally have no
matching committed package and production staging fails closed.

Review source PRs and release candidate PRs separately, then approve their merge
and the automation PR explicitly. New publication review blocks remain until that
approval is recorded in a reviewed config change. No tag or GitHub release is
created by candidate QA. Once approved packages and automation are integrated,
run master with the selected module/version and dry_run=true/create_release=false,
inspect exact SHA/hashes and all runtime reports, then separately authorize an
actual deployment. Only an actual successful upload followed by exact Gallery
package/version/hash and installed-test verification can trigger mapped issue
completion. These three candidates have no completion mapping.
