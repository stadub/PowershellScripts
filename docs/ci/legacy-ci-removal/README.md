# Azure Pipelines and AppVeyor removal

On 2026-11-12 the owner explicitly requested removal of Azure DevOps and AppVeyor
from `stadub/PowershellScripts`, including their stale test results. Scope is this
repository only. The owner has no Azure DevOps or AppVeyor account access.

## Live GitHub changes

The owner completed GitHub's required authentication directly. The Azure Pipelines
installation **1179244** and AppVeyor installation **1178482** each used **Only
select repositories**, with exactly one selected repository:
`stadub/PowershellScripts`. GitHub requires at least one selected repository, so
removing the final selection could not be saved. Each single-repository installation
was therefore uninstalled. Both confirmation dialogs explicitly identified **1
repository**. No installation covering other repositories was removed or modified.

Afterward, the repository's Installed GitHub Apps page no longer listed either
Azure Pipelines/Microsoft or AppVeyor. Codecov, GitHub Learning Lab and Vercel
remained. The two remaining repository webhooks (Read the Docs and CodeFactor)
were unchanged. No Azure/AppVeyor required contexts existed to remove. GitHub
Actions, component PR states and Gallery environment/secret settings were unchanged.

GitHub documents repository selection and uninstall behavior in
[reviewing and modifying installed GitHub Apps](https://docs.github.com/en/apps/using-github-apps/reviewing-and-modifying-installed-github-apps).

## Repository files

Removed these four Azure pipeline definitions:

- `azure-pipelines.yml`
- `7Zip/azure-pipelines.yml`
- `Bookmarks/azure-pipelines.yml`
- `Currency-Conv/azure-pipelines.yml`

Removed Azure status badges from the source READMEs for 7Zip, Bookmarks,
Currency-Conv, FolderEncoder, Base64String and Pipe. Removed both Azure and AppVeyor
badges from `Bookmarks/out/README.md`; no packaged executable/module bytes changed.
AppVeyor YAML had already been removed by the separately approved PR #33.

Historical audit files and terminal demo recordings retain service names as
historical evidence. Packaging tests retain dummy Azure YAML fixtures to verify
that CI files cannot enter a Gallery package. These are not active integrations.
No fake replacement success badge was added. File changes are on the automation
branch in PR #31, pending integration; master and other worktrees were not edited.

## External definitions remain inaccessible

Public reads verified that Azure definition IDs **3 Bookmarks**, **4 7Zip**,
**5 Currency-Conv** and **6 SharedFunctions** belong exactly to this repository.
All four reported `queueStatus: enabled` with CI/PR triggers before disconnection.
The Azure browser was signed out; the owner confirmed no access. Their definitions,
service connections and build histories could not be disabled or deleted inside
Azure DevOps. The GitHub installation/access used by that integration is removed.
Microsoft documents that [disabled processing prevents new runs and triggers](https://learn.microsoft.com/en-us/azure/devops/pipelines/customize-pipeline#pipeline-settings),
which is distinct from the GitHub disconnection performed here.

AppVeyor public metadata still lists four projects for this repository:

| ID | Name | Slug |
| --- | --- | --- |
| 584025 | Bookmarks | powershellscripts |
| 607276 | 7Zip | powershellscripts-yvvt0 |
| 607412 | Currency-Conv | powershellscripts-7m2fk |
| 610315 | SharedFunctions | powershellscripts-v9ncj |

AppVeyor was signed out; its GitHub login requested an OAuth grant, which was
cancelled. No new grant was approved and no integration was reinstalled. Public
metadata cannot prove that internal schedules/manual builds are disabled. Those
projects remain inaccessible to this task. No external project history was deleted.

## Historical result removal limitation

GitHub's supported [Checks API](https://docs.github.com/en/rest/checks) and
[commit status API](https://docs.github.com/en/rest/commits/statuses) provide no
repository operation to delete individual external check runs/suites or commit
statuses. Uninstalling an app revokes its access but does not delete the results
already attached to older commits. Therefore those historical Azure/AppVeyor
results were **not deleted**. No statuses were rewritten to success, and no
GitHub Actions runs, logs, artifacts or reports were deleted. There were no tracked
NUnit/TRX/test-result files in this checkout to remove.

A normal cleanup commit provides a new PR head; verify it has no newly posted
Azure/AppVeyor checks or statuses. Other PRs with unchanged old head SHAs can still
show their historical external results. Do not rewrite those branches solely to
hide history. Check the actual replacement Actions results independently: six
component repairs remain unmerged and maintained-baseline CI still reports their
failures. Removal of obsolete services does not resolve those source defects.

See [sanitized scope and settings evidence](audit.json). The earlier
[AppVeyor audit](../appveyor-cutover/README.md) predates this explicitly authorized
live GitHub removal; its historical snapshots are preserved.
