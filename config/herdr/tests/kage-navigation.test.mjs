import test from "node:test";
import assert from "node:assert/strict";
import { shortcutOrder } from "../mods/kage-agents/navigation.mjs";

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
