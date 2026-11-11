# AppVeyor integration cutover

Scope: `stadub/PowershellScripts`, branch `ci/remove-appveyor-checks`, intended PR
target **master**. Audit date: 2026-11-11. Repository infrastructure only.
Instructions were read from `/Users/dimastadub/orca/PowershellScripts/AGENTS.md`
because this checkout has no AGENTS.md.

## Before state and removal plan

`before.json` is the sanitized live GitHub snapshot saved before any settings
mutation. Hook URLs retain only their host; hook configuration, credentials,
secrets, and AppVeyor build environments are excluded.
`appveyor-public-projects.json` records selected public project metadata.

The authenticated GitHub user is `stadub`, with repository admin permission.
All 21 live branches are unprotected. GraphQL returns no branch protection
patterns (including patterns for nonexistent branches), and the repository ruleset
list, including parents, is empty. Master protection returns 404 "Branch not
protected"; effective master rules are empty. There are **no existing required
AppVeyor contexts to remove**. Do not create or delete a protection object to
address a historical red status.

The reported contexts are statuses on the head commit of merged PR #28,
`5fe9e2344afacccd4cebe02f178d6eb8cd162d2f`:

| Context | State / description | AppVeyor evidence |
| --- | --- | --- |
| `continuous-integration/appveyor/branch` | failure / AppVeyor build failed | SharedFunctions, project 610315, `powershellscripts-v9ncj`, build 55069580 |
| `continuous-integration/appveyor/pr` | error / AppVeyor build cancelled | Currency-Conv, project 607412, `powershellscripts-7m2fk`, build 55069584 |

PR #28 targeted `base64tring/develop` and is already merged. The audit found no
open PRs. Its four check runs belong to Azure Pipelines, not AppVeyor. Master has
no statuses; its aggregate API state of `pending` does not establish a required
check. Historical results must remain truthful; never post synthetic successes.

The four repository webhooks are Travis (83155980), Read the Docs (104335530),
Codecov (128538950), and CodeFactor (128539623). None is AppVeyor. Preserve all
four, even if an unrelated hook currently reports an error. No GitHub Actions
workflows are registered yet.

Authorized, narrow implementation plan:

1. Remove only the two exact AppVeyor contexts from any live required-check list
   if found; preserve strictness, check app associations, other checks, review
   rules, bypass actors, and all other protection settings. The saved audit
   found none, so this step is a no-op.
2. Remove/deactivate only an AppVeyor repository webhook if present. None exists,
   so this step is a no-op. Never remove another service's webhook.
3. Disable automatic push/PR triggering on AppVeyor projects whose repository is
   exactly `stadub/PowershellScripts`, or remove only this repository from an
   AppVeyor installation's selected repositories if accessible. Never uninstall
   an account-wide app or revoke shared OAuth access. Save sanitized project
   trigger settings before changing them. Public project metadata is evidence
   of repository association, not authenticated write access.
4. Re-read protections, rulesets, hooks, workflows, and Gallery environment policy
   after the audit/any permitted mutations; compare unrelated settings and record
   limitations. Require replacement Actions checks only after real hosted jobs
   exist and have been verified on the intended branches.

## Access boundary and external completion

GitHub's `/user/installations` returns 403: this credential is not a GitHub App
user access token. `/repos/stadub/PowershellScripts/installation` returns 401
(requires app authentication). These responses do not prove the absence of an
AppVeyor installation. Neither API is a way to revoke per-repository OAuth access
using the present credential.

The AppVeyor browser session redirects `/projects` to `/login`. Neither
`APPVEYOR_TOKEN` nor `APPVEYOR_API_TOKEN` is available in the process environment
(only presence was checked). Public project reads do not authorize writes.
Therefore AppVeyor-side triggering cannot currently be disabled with available
authenticated access. No login credentials or API tokens were requested or saved.

An AppVeyor account administrator must inspect all projects associated with this
repository, including SharedFunctions and Currency-Conv above and the README
references `powershellscripts` and `powershellscripts-yvvt0`. Disable repository
push and pull-request triggers (and schedules, if any) for **only these repository
projects**. Preserve unrelated repositories and record the resulting project
settings. The public metadata for the two status-linked projects has
`skipBranchesWithoutAppveyorYml: false`; YAML deletion alone cannot establish
that future builds stop. Public metadata does not expose the complete trigger
configuration, so it cannot verify that the integration has been removed.

## Coordination with the replacement and publication

- `github-actions-ci` / `ci/github-actions` owns legacy YAML deletion, badge
  updates, workflow implementation, and `docs/github-actions-ci.md`. Its changes
  were uncommitted when inspected; this branch does not duplicate them. It
  proposes the stable job name `CI status`. Hosted rollout is still pending and
  known module baseline failures remain. Do not require this name until its real
  GitHub Actions check context and app identity have been verified. Port reviewed
  automation to maintained module branches separately; do not merge unfinished
  component branches to perform the cutover.
- `psgallery-deploy` / `ci/psgallery-publish` owns Gallery publishing. The existing
  `powershell-gallery` environment has a custom branch policy allowing `master`
  only (policy 66315664). Preserve it and all publication safeguards.
- `release-pipeline` / `ci/release-pipeline` coordinates build/test/release and
  deployment under issue #29. Its issue checklist requires verified publication
  before closing functional issue #22. Neither issue is changed here.

Sibling worktrees were inspected read-only. No workflow, source, package, or
release artifact is changed by this cutover documentation branch. No packages
were published and no statuses were posted.

## Verified outcome

`after.json` repeats the live GitHub audit; `validation.json` records comparison
results. Every captured query result is identical before and after, including
the four hooks, empty protection patterns/rulesets, empty workflow list, and
Gallery master-only branch policy. JSON parsing, explicit assertions for absent
AppVeyor requirements/hooks, and `git diff --check` passed. No runtime module
tests are applicable to this documentation-only change.

Exact live setting/integration changes: **none**. The GitHub required-check
cleanup is already satisfied by the existing empty protection configuration;
no CI requirement was disabled. Future PRs under the audited rules do not require
either AppVeyor context. This is a configuration verification, not an observed
future PR run or proof that external AppVeyor triggering has stopped. Historical
and new externally posted failure statuses may still appear.

The external integration removal is **incomplete due to unavailable AppVeyor
authenticated access**. No repository selection, installation, project trigger,
or OAuth grant was modified. The account administrator step above remains
necessary; rerun the GitHub audit and inspect actual AppVeyor project trigger
settings after it is completed.

The existing release coordinator was notified through Orca orchestration
(`msg_5e1a0754bea3`) with the access limitation, preservation of Gallery policy,
and the dependency on verified hosted `CI status` runs. The existing Actions
implementation and rollout documentation were read and respected; no new worker
was launched. This branch is a local, reviewable audit/cutover record targeting
master; it has not been pushed and no PR has been created.
