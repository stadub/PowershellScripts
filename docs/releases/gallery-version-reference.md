# Gallery version references and next release plan

Checked 2026-11-12 against the official exact-name Gallery API, package pages and
six downloaded latest-listed nupkgs. The owner directs that **only 7Zip receives a
new major version**. These numbers are per-package references, not a shared
version input or a claim that every snapshot is already prepared.

| Package | Latest listed | Highest registered stable | Next reference | Change | Readiness |
| --- | --- | --- | --- | --- | --- |
| Bookmarks | 3.0.1 | 3.0.1 | 3.0.2 | Patch | Blocked: reconcile the actual 3.0.1 implementation first |
| 7zip-Archive | 1.1.0 | 1.1.0 | 2.0.0 | **Major** | Reference only; reviewed source must be packaged/versioned |
| Currency-Conv | 1.0.2 | **1.5.0, unlisted** | 1.5.1 | Patch above the reserved 1.5.0 | Reference only; reviewed source/package validation required |
| Base64String | 1.2.0 | 1.2.0 | **1.3.0** | Minor, already approved | Preserve prepared snapshot 6d30dbc22de8bfb8bccda5cd3880ffb9a6655f5f |
| Pipe | 1.0.0 | 1.0.0 | 1.0.1 | Patch | Reference only; regenerate matching output from reviewed fixes |
| FolderEncoder | 2.0.0 | 2.0.0 | **2.0.1** | Patch | Preserve validated candidate in PR49 |
| Shell-Functions | None | None | **0.0.1** | First package | Preserve owner-approved MiniModules candidate in PR50 |
| MiniModules.Uninstall | None | None | **1.0.1** | First package under a distinct name | Preserve owner-approved MiniModules candidate in PR51 |

Source/release SHAs, observed manifest versions, official feed/package links,
reserved unlisted versions, nupkg SHA-256 and runtime-file hashes are recorded in
[version-reference.json](../../scripts/gallery/version-reference.json). API entry
IsLatestVersion identifies the latest listed release; registered but unlisted
stable versions are also considered before choosing a new number. The Gallery
feeds mark their unlisted entries with the 1900 publication sentinel.

## Why Bookmarks cannot simply become 3.0.2

The failed manual run selected Bookmarks with the Base64String example number
1.3.0. Its configured release SHA 209e4fe899ed3ec00ae1c1b528eb5afa87aef090 and
maintained development SHA 5d63a44e4135c5bc3f46f1b7e6cbd928476a2004 both still
declare 2.2.0. Gallery already contains 3.0.1, published on 2025-05-19.

The downloaded 3.0.1 reference has twelve runtime files: manifest/module, aliases
and nine cmdlet files under cmdlets/. Its release notes describe a restructure,
multiplatform work and removal of the update checker. Repository 2.2.0 instead
uses Functions.ps1 and Shared-Functions.ps1. The 3.0.1 module explicitly imports
and exports Import-PSBookmarks and Save-PSBookmarks in addition to its other
commands; its manifest exposes only six functions and does not declare RootModule.
Those exact published packaging/API differences also need review rather than
assuming the published package is automatically correct.

A read-only scan of reachable manifest-changing commits found no Bookmarks 3.x
manifest, and no reachable cmdlets/ source history was found. The Gallery package
is therefore a hashed reference payload, not an invented Git source SHA or an
unreviewed source replacement. Reconcile that implementation with reviewed
persistence/update-check repairs through the component workflow before preparing
3.0.2. Trusted configuration now blocks Bookmarks publication and GitHub release
creation until this is reviewed; it never relabels the 2.2 monolith.

## Why 7Zip is the sole major bump

The reference is [7zip-Archive 1.1.0](https://www.powershellgallery.com/packages/7zip-Archive/1.1.0),
so the owner-directed next major is **2.0.0**, not 1.2.0 or a shared 1.3.0.
Reviewed develop SHA b846f1b01fad8e193cb9e92abdc75a0338c6c823 contains these
compatibility changes relative to that published payload and release source:

- Missing runtimes no longer trigger an automatic download of bundled 7za920.
  Users must install a current native 7-Zip executable themselves.
- SEVENZIP_PATH explicitly selects a full executable path and invalid overrides
  fail rather than silently selecting another runtime. Otherwise discovery uses
  PATH and Windows installation locations.
- Linux/macOS discovery targets native 7zz/7z/7za commands instead of assuming a
  p7zip wrapper. Initialization no longer creates runtime directories/downloads.
- Native argument quoting is corrected, and invalid HelpInfoURI metadata is
  removed because no updatable-help endpoint is published.

These changes are explicit release-review items. This audit does not modify the
source version, create a 2.0 release ref, merge source, or claim a prepared 2.0.0
package. The configured historical 1.1 source still has no committed 7Zip/out.
The existing source CI and nineteen Windows tests are evidence for source repairs;
final 2.0.0 source and installed-package validation remains required.

## Other package decisions

Currency-Conv 1.5.0 remains registered even though unlisted; it cannot be uploaded
again. The current source/release manifests declare that reserved version and the
configured release ref has no Currency-Conv/out. Use 1.5.1 as the reference patch
after selectively porting the reviewed cache fix and validating source/output.
Do not choose 1.0.3 merely because 1.0.2 is the latest listed package.

Pipe keeps major 1; its source/import/alias corrections are a 1.0.1 patch plan,
not a new major. The old release output must first be reconciled with reviewed
source and regenerated. Base64String 1.3.0 remains exactly as owner-approved;
its issue22 mapping and immutable SHA are unchanged.

Downloaded FolderEncoder 2.0.0 differs from reviewed development only in the
corrected manifest export (EncodeFolder -> Invoke-FolderEncode) and a source BOM.
The encoder implementation is otherwise unchanged, supporting the existing
2.0.1 patch candidate. Existing smoke-test limitations still apply; no encoding
roundtrip was run. New Shell/Uninstall names have no preceding package version;
the existing owner-approved candidate numbers are retained without inventing a
Gallery predecessor or taking ownership of the legacy Uninstall script.

## How automation uses the references

Get-ReleaseConfig.ps1 exposes latest listed, highest registered, planned version
and status. The manual workflow records them beside its immutable source SHA and
checks Test-ReleaseVersionReference.ps1 before staging. It rejects known registered
versions including unlisted 1.5.0, treats zero fourth-segment versions as the same
version, and permits only the reviewed per-module major number. Mismatch errors
identify the selected module, configured branch, prepared version and references.
Entering a number still does not rewrite any manifest or package.

The references are dated and must be refreshed before actual rollout. They add
no network dependency to offline tests and do not replace live upload preflight,
exact downloaded-package verification, reviewed source/out matching or the
protected environment. No tag, release, upload, issue closure, secret or setting
was changed during this audit. All existing PRs remain open.

Official references: [Gallery publishing/version guidance](https://learn.microsoft.com/en-us/powershell/gallery/concepts/publishing-guidelines),
[Bookmarks 3.0.1](https://www.powershellgallery.com/packages/Bookmarks/3.0.1),
[Currency-Conv 1.0.2](https://www.powershellgallery.com/packages/Currency-Conv/1.0.2),
and each exact-name API feed recorded in the JSON evidence.
