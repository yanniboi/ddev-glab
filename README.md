# ddev-glab <!-- omit in toc -->

A [DDEV](https://ddev.com) add-on that installs the [GitLab CLI (`glab`)](https://gitlab.com/gitlab-org/cli)
in the web container and exposes it as `ddev glab`.

This used to ship as part of [ddev-claude-code](https://github.com/FreelyGive/ddev-claude-code)
(removed in [#13](https://github.com/FreelyGive/ddev-claude-code/pull/13)); install
this add-on alongside it if you want Claude Code (or anything else in the
container) to interact with GitLab.

## Installation

```shell
ddev add-on get yanniboi/ddev-glab
ddev restart
```

## Usage

```shell
ddev glab auth login
ddev glab mr list
```

`glab` is also available on the `PATH` inside the web container (`ddev ssh`,
`ddev exec`, Claude Code, etc.).

## Configuration

`GLAB_CONFIG_DIR` points at `.ddev/glab/`, so authentication and settings persist
across restarts and rebuilds. The directory is git-ignored because it contains
access tokens.

To authenticate non-interactively, set `GITLAB_TOKEN` (and `GITLAB_HOST` for
self-managed instances) in `.ddev/.env.web` (keep that file out of git) or globally:

```shell
ddev config global --web-environment-add="GITLAB_TOKEN=glpat-..."
ddev restart
```

## Updating glab

The latest `glab` release is installed when the web image is built. To pick up a
newer release, rebuild the image:

```shell
ddev restart --no-cache   # DDEV >= v1.25.0
```
