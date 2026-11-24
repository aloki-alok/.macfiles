import test from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";

test("clear writes screen and scrollback escapes through the terminal without sending input", async () => {
  const module = new URL("../mods/kage-bar/clear-terminal.mjs", import.meta.url).href;
  const program = `
    import { execFileSync } from "node:child_process";
    import { clearTerminal } from ${JSON.stringify(module)};
    process.stdout.write("before-clear");
    await clearTerminal({ pid: process.pid, address: "test", state: "live" }, async (command, args) => {
      return { code: 0, stdout: execFileSync(command, args, { encoding: "utf8" }), stderr: "" };
    });
    process.stdout.write("after-clear");
  `;
  const terminal = `
import os, pty, sys
pid, master = pty.fork()
if pid == 0:
    os.execv(sys.argv[1], [sys.argv[1], "--input-type=module", "-e", sys.argv[2]])
while True:
    try:
        chunk = os.read(master, 4096)
    except OSError:
        break
    if not chunk:
        break
    os.write(1, chunk)
os.close(master)
_, status = os.waitpid(pid, 0)
sys.exit(os.waitstatus_to_exitcode(status))
`;
  const result = spawnSync("python3", ["-c", terminal, process.execPath, program], { encoding: "utf8", timeout: 10000 });
  assert.equal(result.status, 0, result.stderr || result.stdout);
  assert.match(result.stdout, /before-clear\u001b\[2J\u001b\[3J\u001b\[Hafter-clear/);
});
