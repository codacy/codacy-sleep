# Codacy Sleep Tool

Docker engine for a Codacy tool that only sleeps.

This repository is an example of a tool and has the instructions to develop and
test a [Codacy Tool](#what-is-a-codacy-tool).

## What is Codacy

[Codacy](https://www.codacy.com/) is an Automated Code Review Tool that monitors
your technical debt, helps you improve your code quality, teaches best practices
to your developers, and helps you save time in Code Reviews.

### Among Codacy’s features

* Identify new Static Analysis issues
* Commit and Pull Request Analysis with GitHub, BitBucket/Stash, GitLab (and
  also direct git repositories)
* Auto-comments on Commits and Pull Requests
* Integrations with Slack, HipChat, Jira, YouTrack
* Track issues in Code Style, Security, Error Proneness, Performance, Unused
  Code and other categories

Codacy also helps keep track of Code Coverage, Code Duplication, and Code
Complexity.

Codacy supports PHP, Python, Ruby, Java, JavaScript, and Scala, among others.

### Free for Open Source

Codacy is free for Open Source projects.

## Agent Playbook: Updating This Repository End-to-End

This section is written for an AI coding agent (or a human) that has been asked to "update" this repo. Read it before touching anything — `codacy-sleep` is **not** a real linter/tool wrapper like most other `codacy-*` engine repos, and treating it as one will lead you to invent work that doesn't exist.

### 1. What this repository actually is

There is no wrapped tool, no analyzer, and no source code here at all — no Scala, no `src/`, no `codacy-engine-scala-seed`. The entire "engine" is a Dockerfile:

```dockerfile
FROM alpine:3.14.2
COPY docs/ /docs/
RUN adduser -u 2004 -D docker
RUN chown -R docker:docker /docs
ENTRYPOINT ["/bin/sleep", "infinity"]
```

The container's only behavior is to run `sleep infinity` and never exit. It exists so Codacy's own platform/infra can be tested against a Codacy-engine-shaped Docker image that never produces results and never terminates on its own — useful for exercising timeout handling, retries, resource limits, and orchestration logic without depending on a real analyzer's behavior.

`docs/patterns.json` and `docs/description/description.json` do exist (this repo does follow the standard Codacy engine docs layout), but they are minimal stand-ins: a single fake pattern called `sleep` (category `ErrorProne`, level `Info`) with the title "Sleep" and description "This tool sleeps forever" (`docs/tool-description.md`). There is no real rule set to keep in sync with an upstream project, because there is no upstream project.

### 2. What "updating" this repo has meant in practice

Git history confirms there is no real bump history to speak of. The only non-trivial content change ever made is a single base-image bump:

- `31ca8cf` — `bump: Update base image CY-5141` — bumped `Dockerfile`'s `FROM alpine:3.13.2` to `FROM alpine:3.14.2`. That is the entire "version" surface of this repo.
- `87b3e29` — pinned third-party GitHub Actions in `.github/workflows/*.yml` to commit SHAs (security hardening, not a version bump of anything this repo wraps).

There is no wrapped-tool version to bump, no `docs/patterns.json` generator to re-run, and no plugin/pattern parity to validate against an upstream release. If an automation is asked to "bump codacy-sleep to the latest version," the honest interpretation is: bump the `alpine` base image tag in `Dockerfile` to the latest stable Alpine release, and possibly refresh pinned GitHub Action SHAs in `.github/workflows/*.yml` if newer tagged releases exist. There is nothing else to change.

### 3. Step-by-step procedure (if genuinely asked to update this repo)

1. Check the current Alpine version pinned in `Dockerfile` (`FROM alpine:X.Y.Z`) against the latest stable Alpine release, and bump it if newer.
2. Do not touch `docs/patterns.json`, `docs/description/description.json`, or `docs/tool-description.md` — they are fixed placeholders describing the fake "sleep" pattern, not generated artifacts tied to a real tool version.
3. Build the image locally to confirm it still builds and runs (`docker build -t codacy-sleep -f Dockerfile .`) — there is no unit-test suite or compiler to run since there is no application code.
4. Commit, push, open a PR.
5. **Poll CI until it's green.** CI is CircleCI (`.circleci/config.yml`), using the `codacy/base` and `codacy/plugins-test` orbs: it checks out, builds and saves the Docker image, runs `codacy_plugins_test/run` against it (which, for this repo, just confirms the container starts and the fixed `sleep` pattern round-trips), and on `master` publishes and tags the image. After pushing, use `gh pr checks <pr-url>` and keep re-polling until every check finishes. If a check fails, pull its real log, fix the actual cause, push again, and re-poll — do not treat a local `docker build` success as sufficient.

### 4. If asked to bump "the tool version"

There is no tool version to bump beyond the Alpine base image. An automation encountering a task like "bump codacy-sleep to latest" should either (a) treat it as a base-image bump per the procedure above, or (b) flag back to the requester that this repo has no wrapped tool and ask what specifically should change, rather than fabricating a version bump against a nonexistent dependency.

### 5. Definition of done

- If a base image bump was made, `Dockerfile`'s `FROM` line reflects the new Alpine tag, and nothing else was changed.
- The image builds locally.
- **After pushing and opening/updating the PR, every CircleCI check on it is green.**
