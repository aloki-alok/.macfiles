import test from "node:test";
import assert from "node:assert/strict";
import { saveLook, lookWriter, activeTheme } from "../mods/kage-appearance/look.mjs";

test("appearance opens with the actual light or dark theme", () => {
  const themes = { theme_light: "kage-day", theme_dark: "stack-night" };
  assert.equal(activeTheme({ ...themes, dark: false }), "kage-day");
  assert.equal(activeTheme({ ...themes, dark: true }), "stack-night");
});

test("saving appearance preserves privacy and concurrent settings changes", async () => {
  let raw = JSON.stringify({ telemetry: false, sounds: { enabled: false }, font_size: 17 });
  let attempts = 0;
  const io = {
    read: async () => raw,
    write: async (next, expected) => {
      attempts++;
      if (attempts === 1) {
        raw = JSON.stringify({ ...JSON.parse(raw), copy_on_select: false });
        throw new Error("Stale snapshot");
      }
      assert.equal(expected, raw);
      raw = next;
    },
  };
  await saveLook(io, { font: "Hack", font_size: 18, telemetry: true });
  const saved = JSON.parse(raw);
  assert.equal(saved.font_size, 18);
  assert.equal(saved.font, "Hack");
  assert.equal(saved.telemetry, false);
  assert.equal(saved.copy_on_select, false);
  assert.deepEqual(saved.sounds, { enabled: false });
  assert.equal(attempts, 2);
});

test("invalid settings and out-of-range sizes never overwrite the file", async () => {
  let writes = 0;
  const write = async () => { writes++; };
  await assert.rejects(saveLook({ read: async () => "{broken", write }, { font_size: 18 }));
  await assert.rejects(saveLook({ read: async () => "[]", write }, { font_size: 18 }));
  for (const font_size of [NaN, Infinity, 0, 49, "18"]) {
    await assert.rejects(saveLook({ read: async () => "{}", write }, { font_size }));
  }
  assert.equal(writes, 0);
});

test("a persistent write failure is reported after three attempts", async () => {
  let writes = 0;
  await assert.rejects(saveLook({
    read: async () => "{}",
    write: async () => { writes++; throw new Error("Read-only file"); },
  }, { font_size: 16.5 }), /Read-only file/);
  assert.equal(writes, 3);
});

test("rapid live choices save in order without dropping another setting", async () => {
  let raw = "{}";
  let release;
  const gate = new Promise(resolve => { release = resolve; });
  const save = lookWriter({
    read: async () => raw,
    write: async (next, expected) => {
      if (JSON.parse(next).font === "First") await gate;
      if (expected !== raw) throw new Error("Stale snapshot");
      raw = next;
    },
  });
  const first = save({ font: "First", font_size: 17 });
  const second = save({ font: "Second", theme: "kage-night" });
  await new Promise(resolve => setImmediate(resolve));
  release();
  await Promise.all([first, second]);
  assert.deepEqual(JSON.parse(raw), { font: "Second", font_size: 17, theme: "kage-night" });
});

test("a later saved size does not hide an unsaved font, and retry clears it", async () => {
  let raw = JSON.stringify({ font: "Old", font_size: 17 });
  const save = lookWriter({
    read: async () => raw,
    write: async next => {
      if (JSON.parse(next).font === "Chosen") throw new Error("Disk unavailable");
      raw = next;
    },
  });
  await assert.rejects(save({ font: "Chosen" }), /Disk unavailable/);
  await save({ font_size: 18 });
  assert.deepEqual(save.state().unsaved, { font: "Chosen" });
  assert.match(save.state().error, /Disk unavailable/);
  assert.equal(JSON.parse(raw).font_size, 18);
  await save({ font: "Recovered" });
  assert.deepEqual(save.state().unsaved, {});
  assert.equal(save.state().error, null);
});

test("returning to an earlier font keeps the final failed choice visible", async () => {
  let raw = "{}";
  let first = true;
  let release;
  const gate = new Promise(resolve => { release = resolve; });
  const save = lookWriter({
    read: async () => raw,
    write: async next => {
      if (first) { first = false; await gate; }
      else if (JSON.parse(next).font === "A") throw new Error("Final write failed");
      raw = next;
    },
  });
  const jobs = [save({ font: "A" }), save({ font: "B" }), save({ font: "A" })];
  release();
  const results = await Promise.allSettled(jobs);
  assert.equal(results[2].status, "rejected");
  assert.equal(JSON.parse(raw).font, "B");
  assert.deepEqual(save.state().unsaved, { font: "A" });
  assert.match(save.state().error, /Final write failed/);
});
