# MiniModules.Uninstall module preparation

The owner-approved MiniModules.Uninstall 1.0.1 manifest wraps the existing Uninstall.psm1 without changing its
implementation. Importing it exports Uninstall-Application and performs no
uninstall operation. Execution requires Windows registry/msiexec facilities.

The Gallery name Uninstall currently refers to an unlisted script owned by
DimaStadub, not one of the configured Stadub/MiniModules module routes. The new module uses the distinct
MiniModules.Uninstall name and the owner-selected MiniModules account; it does not
replace, relist or claim that legacy script.
No Gallery upload, relisting, ownership transfer or uninstall was performed.

The package contains only the module, manifest, this document and the existing
repository BSD-2-Clause LICENSE. It must never include unrelated monorepo files.
Tests cover safe import and the public parameter contract; actual registry lookup
and software removal remain unvalidated legacy behavior.
