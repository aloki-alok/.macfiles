```text
Herdr → coding sessions → Kage Stack playbooks and checks
Kage  → connected tasks → coding sessions
```

# Kage and Kage Stack

Kage connects tasks from Slack, WhatsApp, email, calls, meetings, the browser and jobs. Kage Stack supplies playbooks and code checks. Herdr is the terminal workspace around coding sessions.

| Tool | Daily use | Canonical guide |
|---|---|---|
| Kage | `kage status`, `kage doctor`, `kage top` | [Kage setup and commands](https://github.com/aloki-alok/kage/blob/main/CLAUDE.md) |
| Kage Stack | `ks check`, `ks doctor`, `ks tools` | [Kage Stack handbook](https://aloki-alok.github.io/kagestack/) |
| Herdr | Switch agents and inspect their terminals | [Use Herdr](herdr.md) |

Use Kage's doctor to identify a failing connection. Follow the command it prints, then check again. A healthy hub and an installed CLI can run different versions. `kage status` reports the hub.

Kage owns `~/.config/kage`, its credentials, jobs and runtime state. `.macfiles` does not copy those files or manage Kage's updater.

Kage Stack owns its checks and playbooks. The git configuration in `home.nix` points to `~/.config/kagestack/git-hooks`. The hook folder requires a separate Kage Stack installation.

The live shared agent instructions and skills are in `~/.claude`. `~/exocortex` is their backup. A fresh Mac needs that separate restoration too.

Keep detailed behavior in each tool's own guide. This handbook records where the tools fit together, so their command reference does not drift here.
