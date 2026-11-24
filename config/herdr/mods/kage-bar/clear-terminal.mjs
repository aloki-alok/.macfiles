const clearScreen = String.raw`
set -eu
terminal_tty=$(/bin/ps -p "$1" -o tty= | tr -d '[:space:]')
case "$terminal_tty" in
  tty*|pts/[0-9]*) ;;
  *) printf 'The terminal process has no screen.\n' >&2; exit 1 ;;
esac
test -c "/dev/$terminal_tty"
printf '\033[2J\033[3J\033[H' > "/dev/$terminal_tty"
`;

export async function clearTerminal(terminal, exec) {
  if (!terminal || terminal.state !== "live" || !Number.isSafeInteger(terminal.pid) || terminal.pid < 1) {
    throw new Error("Choose a live terminal to clear.");
  }
  const on = terminal.address.includes("/") ? terminal.address.split("/")[0] : null;
  const result = await exec("sh", ["-c", clearScreen, "herdr-clear", String(terminal.pid)], { on });
  if (result.code !== 0) throw new Error(result.stderr.trim() || "The terminal could not be cleared.");
}
