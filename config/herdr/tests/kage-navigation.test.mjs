import test from "node:test";
import assert from "node:assert/strict";
import * as navigation from "../mods/kage-agents/navigation.mjs";

const { shortcutOrder } = navigation;

test("agent numbers follow displayed groups, pins, and folded sections", () => {
  const groups = [
    { id: "pinned", members: [{ address: "pinned" }] },
    { id: "working", members: [{ address: "work-2" }, { address: "work-1" }] },
    { id: "idle", members: [{ address: "idle" }] },
  ];
  assert.deepEqual(shortcutOrder(groups, new Set()), ["pinned", "work-2", "work-1", "idle"]);
  assert.deepEqual(shortcutOrder(groups, new Set(["working"])), ["pinned", "idle"]);
  assert.deepEqual(shortcutOrder([groups[2], groups[0], groups[1]], new Set()), ["idle", "pinned", "work-2", "work-1"]);
  assert.deepEqual(shortcutOrder([], new Set()), []);
});

test("terminal tabs keep all split panes nested and exclude tabs containing only agents", () => {
  const spaces = [
    { id: "local", name: "Work", machine: null, tabs: [
      { id: "mixed", index: 1, name: "1", named: false },
      { id: "shell", index: 2, name: "Logs", named: true },
    ] },
    { id: "remote", name: "Server", machine: "vps", tabs: [
      { id: "vps/shell", index: 1, name: "1", named: false },
    ] },
  ];
  const shell = { name: "zsh", key: "shell" };
  const panes = [
    { pane: "p2", terminal: "t2", tab: "shell", title: "/Users/test/logs", cwd: "/Users/test/logs", program: shell },
    { pane: "agent", terminal: "a1", tab: "mixed", title: "Fix login", program: { name: "Codex", agent: true } },
    { pane: "p1", terminal: "t1", tab: "mixed", title: "Build", cwd: "/Users/test/app", program: shell },
    { pane: "p3", terminal: "t3", tab: "shell", title: "Watch", cwd: "/Users/test/logs", program: shell },
    { pane: "mod", terminal: null, tab: "shell", title: "Files" },
    { pane: "rp1", terminal: "vps/t1", tab: "vps/shell", title: "zsh", cwd: "/srv/app", program: shell },
    { pane: "outside", terminal: "t9", tab: "unknown", title: "Other" },
  ];
  const entries = navigation.terminalEntries(spaces, panes, [{ address: "a1" }], { terminal: "t3" });
  assert.deepEqual(entries.map(({ id, number, name, selected, panes }) => ({ id, number, name, selected, addresses: panes.map(p => p.address) })), [
    { id: "mixed", number: "1", name: "Fix login", selected: false, addresses: ["a1", "t1"] },
    { id: "shell", number: "2", name: "Logs", selected: true, addresses: ["t2", "t3"] },
    { id: "vps/shell", number: "1", name: "zsh", selected: false, addresses: ["vps/t1"] },
  ]);
  assert.equal(entries[0].panes[1].cwd, "/Users/test/app");
  assert.equal(entries[0].panes[1].pane, "p1");
  assert.equal(entries[0].panes[1].number, 2);
  assert.equal(entries[1].panes[1].selected, true);
  assert.equal(entries[1].panes[1].name, "Watch");
  assert.equal(entries[2].space_name, "Server");
  assert.equal(entries[2].machine, "vps");
});

test("a shell moves between terminal and agent lists as its reported status changes", () => {
  const spaces = [{ name: "Work", machine: null, tabs: [{ id: "tab", index: 4, name: "4", named: false }] }];
  const pane = { pane: "pane", terminal: "t4", tab: "tab", title: "zsh", program: { name: "zsh", key: "shell" } };
  assert.deepEqual(navigation.terminalEntries(spaces, [pane], [{ address: "t4" }], null), []);
  const entries = navigation.terminalEntries(spaces, [pane], [], { terminal: "other" });
  assert.equal(entries.length, 1);
  assert.equal(entries[0].name, "zsh");
  assert.equal(entries[0].selected, false);
  assert.deepEqual(navigation.terminalEntries(spaces, [], [], null), []);
});
