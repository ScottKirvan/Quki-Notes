# QuKi-Notes [![starline](https://starlines.qoo.monster/assets/ScottKirvan/QuKi-Notes)](https://github.com/qoomon/starline)
<div align="center">

  <img src="assets/media/logo.jpg" alt="logo" width="200" height="auto" />
    <h1><a href="https://github.com/ScottKirvan/QuKi-Notes">ScottKirvan/QuKi-Notes</a></h1>
  <h3>A quick, streamlined, cross-platform note taking app</h3>
  
  
<!-- Badges -->
<p>
  <a href="https://github.com/ScottKirvan/QuKi-Notes/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/ScottKirvan/QuKi-Notes" alt="contributors" />
  </a>
  <a href="">
    <img src="https://img.shields.io/github/last-commit/ScottKirvan/QuKi-Notes" alt="last update" />
  </a>
  <a href="https://github.com/ScottKirvan/QuKi-Notes/network/members">
    <img src="https://img.shields.io/github/forks/ScottKirvan/QuKi-Notes" alt="forks" />
  </a>
  <a href="https://github.com/ScottKirvan/QuKi-Notes/stargazers">
    <img src="https://img.shields.io/github/stars/ScottKirvan/QuKi-Notes" alt="stars" />
  </a>
  <a href="https://github.com/ScottKirvan/QuKi-Notes/issues/">
    <img src="https://img.shields.io/github/issues/ScottKirvan/QuKi-Notes" alt="open issues" />
  </a>
  <a href="https://github.com/ScottKirvan/QuKi-Notes/blob/main/LICENSE.md">
    <img src="https://img.shields.io/github/license/ScottKirvan/QuKi-Notes.svg" alt="license" />
  </a>
  <a href="https://discord.gg/gQH4mXWQRT">
    <!--<img src="https://img.shields.io/discord/704680098577514527?style=flat-square&label=%F0%9F%92%AC%20discord&color=00ACD7">-->
    <img src="https://img.shields.io/discord/1052011377415438346?style=flat-square&label=discord&color=00ACD7">
  </a>
</p>
   
<h4>
    <a href="https://github.com/ScottKirvan/QuKi-Notes/blob/main/README.md">Documentation</a>
  <span> · </span>
    <a href="https://github.com/ScottKirvan/QuKi-Notes/issues/new?template=bug_report.md">Report Bug</a>
  <span> · </span>
    <a href="https://github.com/ScottKirvan/QuKi-Notes/issues/new?template=feature_request.md">Request Feature</a>
  </h4>
</div>

**QuKi-Notes** is a rapid note-capture application inspired by iOS Drafts, designed for quick, frictionless writing with powerful GitHub integration and cross-device syncing. The app opens immediately to a blank note—no setup, no friction. Write fast, sync seamlessly, and extend with workflows.

Branches
--------
`main` is the [deployed](https://ScottKirvan.github.io/QuKi-Notes/) branch.  The repo doesn't currently contain any other historic or dev branches.

Repo Layout
-----------
```
QuKi-Notes/
├───lib/                        # Dart application source code
│   ├───core/                   # Database, GitHub client, sync, settings
│   ├───features/               # Editor, documents, workflows, onboarding
│   └───shared/                 # Shared models and widgets
├───android/                    # Android platform code
├───windows/                    # Windows platform code
├───ios/                        # iOS platform code (not actively built)
├───docs/                       # VitePress documentation source
├───.github/
│   ├───workflows/              # CI/CD: tests, builds, releases
│   ├───ISSUE_TEMPLATE/         # Bug report and feature request templates
│   └───PULL_REQUEST_TEMPLATE.md # PR template
├───assets/
│   ├───css/                    # GitHub Pages styling
│   └───media/                  # Images and logos
├───notes/
│   └───dev/                    # Design docs, specifications, decisions
├───CODE_OF_CONDUCT.md
├───CONTRIBUTING.md
├───LICENSE.md
├───justfile                    # Task automation
└───README.md
```

Features
--------

- **Rapid Capture**: App opens immediately to a blank note—no friction, no setup
- **Local-First Storage**: Notes stored locally in SQLite; optional GitHub sync for cross-device access
- **GitHub Sync**: Bi-directional sync with GitHub-hosted repository; conflict resolution via user choice (no merge)
- **Workflow Integration**: Append notes to external workflows—integrate with daily logs, geotagged captures, or custom destinations
- **Cross-Platform**: Single Flutter codebase targets Android and Windows; iOS/macOS support deferred
- **GitHub OAuth**: Secure authentication via Device Flow; no URL scheme registration needed
- **Markdown Editor**: WYSIWYG interface with formatting toolbar; GitHub Flavored Markdown support
- **Image Support**: Copy/paste images directly into notes; stored separately and synced via GitHub
- **Offline-Ready**: Full local operation when GitHub is unavailable; push/pull resume when connectivity returns

Table of Contents
-----------------
- [Branches](#branches)
- [Repo Layout](#repo-layout)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contributions / Contact](#contributions--contact)

Installation
------------
**TBD** — See [Development Setup](notes/dev/dev_env_setup.md) for Flutter/Dart environment configuration.

Usage
-----
**TBD** — See [Design Spec](notes/dev/design_spec.md) and [Testing Guide](notes/dev/testing.md) for detailed documentation.

Contributions / Contact
-----------------------
- Please [file an issue](https://github.com/ScottKirvan/QuKi-Notes/issues/new), or [grab a fork](https://github.com/ScottKirvan/QuKi-Notes/fork), hack away, and submit a [pull request](https://github.com/ScottKirvan/QuKi-Notes/pulls).
- Contact me at [linkedin.com/in/scottkirvan/](https://www.linkedin.com/in/scottkirvan/)
- You can also contact me at my [discord](https://discord.gg/TSKHvVFYxB) server, I'm cptvideo.

Project Link:  [QuKi-Notes](https://github.com/ScottKirvan/QuKi-Notes)  
[CHANGELOG](notes/CHANGELOG.md)  
[TODO](notes/TODO.md)
