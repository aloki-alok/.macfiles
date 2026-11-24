import test from "node:test";
import assert from "node:assert/strict";
import { clearTerminal } from "../mods/kage-bar/clear-terminal.mjs";

test("clear refuses missing or finished terminal processes", async () => {
  const unexpected = () => assert.fail("No terminal output should be written");
  await assert.rejects(() => clearTerminal(null, unexpected), /live terminal/);
  await assert.rejects(() => clearTerminal({ pid: 123, state: "finished" }, unexpected), /live terminal/);
});

test("clear targets the terminal's machine and reports output failures", async () => {
  const target = { pid: 123, state: "live", address: "server/t1" };
  const exec = async (_command, args, options) => {
    assert.equal(options.on, "server");
    assert.equal(args.at(-1), "123");
    return { code: 1, stderr: "Permission denied" };
  };
  await assert.rejects(() => clearTerminal(target, exec), /Permission denied/);
});
