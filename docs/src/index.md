# The daily setup

My macOS configuration with Nix, Home Manager and nix-darwin. This handbook covers installation, the daily workspace, updates and recovery.

Maintained by [Alok Ranjan](https://alokranjan.me/). I build voice AI infrastructure at OmniDimension and tools including [Kage](https://github.com/aloki-alok/kage). This is the setup behind that work.

## Start here

1. [Set up a Mac](setup.md) for the installation steps and machine-specific prerequisites.
2. [Find the owner of a setting](structure.md) before changing a tool, app or preference.
3. [Build and apply a change](changes.md), then verify the affected workflow.

## Work in this setup

| I need to | Read |
|---|---|
| Find the file that controls an app | [Who owns each setting](structure.md) |
| Rebuild the setup on another Mac | [Set up a Mac](setup.md) |
| Add a tool or apply an update | [Change and update the setup](changes.md) |
| Switch agents, layouts, fonts or themes | [Use Herdr](herdr.md) |
| Work in the terminal | [Use the shell and tmux](terminal.md) |
| Check the agent hub or coding rules | [Kage and Kage Stack](agents.md) |
| Undo a broken change | [Recover a working setup](recovery.md) |
| Pick the next improvement | [Ideas worth trying](ideas.md) |

## What is reproducible

`flake.lock` pins the Nix inputs. The configuration records which apps and tools belong on the Mac. Homebrew apps, Herdr releases and shell plugins have separate update lifecycles.

Private overrides, credentials, sessions and app data stay outside this public repo. [Recovery](recovery.md) explains what a generation rollback restores and where a separate backup is needed.
