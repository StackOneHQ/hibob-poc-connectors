# Visier Connectors

## Description

This repository contains a collection of connectors for Visier.

## Building Connectors

For comprehensive guides on building and converting connectors, see:

- **[Building Falcon Connectors](src/configs/README.md)** - Complete guide to YAML structure, authentication, operations, and step functions

## How to Contribute

1. Fork this repository.
2. Clone your fork to your local machine.
3. Create a new branch for your changes.

### Development Husbandry

- Development branches should be branched from `develop`. The `main` branch is reserved for production-ready code.
- Feature branches should follow this format:  
  `eng-[ticket]/[short-description]`  
  _Example:_ `eng-1234/provider-define-location-endpoint`
- Commits should follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format:  
  _Examples:_
  - `feat: add new feature`
  - `fix: resolve edge case in provider logic`
  - `chore: update dependencies`

## Git Hook System

This repository uses a lightweight Git hook system to enforce code quality and automate certain tasks during development.

### Hooks Overview

- **pre-commit**  
  Runs `npm run lint` before each commit. If linting fails, it attempts to auto-fix issues and re-stage only the originally staged files.  
  The hook prevents commits unless code passes lint.

- **post-merge**  
  After pulling or merging branches, this hook checks for newer versions of `@stackone/connect-sdk`.  
  If a newer version is available, it will install the update automatically and stage any resulting changes to `package.json` or `package-lock.json`.

### Hook Installation

Git hooks are stored in the `.githooks/` directory and are automatically installed into `.git/hooks/` after running `npm install`.

#### No Manual Setup Needed

On `npm install`, a setup script will:

- Compare files in `.githooks/` with your local `.git/hooks/`
- Copy over only changed or missing hooks
- Make them executable

To reinstall hooks manually at any time:

```bash
npm run setup:hooks
```

The script is safe to run anytime — it only updates what’s changed.
