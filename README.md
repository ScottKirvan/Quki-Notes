	1`q# QuKi-Notes [![starline](https://starlines.qoo.monster/assets/ScottKirvan/QuKi-Notes)](https://github.com/qoomon/starline)
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

**QuKi-Notes** is a personal capture-and-dispatch app: write ephemeral notes (**QuKis**) frictionlessly on whichever device is at hand, then **toss** them to a destination via a transport plugin. No folders. No tags. No vault. Just capture and move on.

> [!NOTE]
> **Status: Phase 0 scaffold — Phase 1 in progress.**
> I'm a Sr. software engineer, UX designer, and product manager — this project will *not* be ai-slop. All design docs and Claude directives are included in the repo. Start with the [manifesto](notes/dev/manifesto.md), then the [design spec](notes/dev/design_spec.md) for the full roadmap.

## Quick Start (dev)

- Environment setup: [notes/dev/dev_env_setup.md](notes/dev/dev_env_setup.md)
- Claude context: [CLAUDE.md](CLAUDE.md)

## Design Docs

- [Design spec](notes/dev/design_spec.md)
- [Decisions (ADR log)](notes/dev/decisions.md)
- [Open questions](notes/dev/open_questions.md)
## Features (MVP — v1.0)

- **Rapid Capture**: App opens immediately to a blank QuKi — no friction, no setup, no "title field"
- **Local-First Storage**: All QuKis stored locally in SQLite. Single-device by default; sync is an opt-in plugin (v1.1+).
- **QuKi-Toss (Transport Plugins)**: User-initiated dispatch — copy to clipboard, push to a share sheet, append to a GitHub file, or whatever a plugin implements. Dart-only.
- **Ephemeral by Framing**: Newest-first stream surfaces what's current; older QuKis age off-screen but stay searchable. Nothing auto-deletes.
- **Cross-Platform**: Single Flutter codebase actively targeting Android, Windows, and Linux. iOS/iPadOS/macOS supported by the codebase; CI builds deferred.
- **Markdown Editor**: WYSIWYG interface with formatting toolbar; GFM under the hood.
- **Image Support**: Copy/paste images directly into QuKis; stored separately on disk and referenced from markdown.
- **No Telemetry**: No analytics, no crash reporting, no tracking.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Contributions / Contact](#contributions--contact)

## Installation

**TBD** 
## Usage
**TBD** - [www.scottkirvan.com/QuKi-Notes](https://www.scottkirvan.com/QuKi-Notes) will eventually host the full user docs.

## Contributions / Contact
- Please [file an issue](https://github.com/ScottKirvan/QuKi-Notes/issues/new), or [grab a fork](https://github.com/ScottKirvan/QuKi-Notes/fork), hack away, and submit a [pull request](https://github.com/ScottKirvan/QuKi-Notes/pulls).
- Contact me at [linkedin.com/in/scottkirvan/](https://www.linkedin.com/in/scottkirvan/)
- You can also contact me at my [discord](https://discord.gg/TSKHvVFYxB) server, I'm cptvideo.

Project Link: [QuKi-Notes](https://github.com/ScottKirvan/QuKi-Notes)
[CHANGELOG](CHANGELOG.md)
