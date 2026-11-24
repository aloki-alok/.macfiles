import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, spaces, terminals, focused, exec, notify, run, theme, shared, setShared, settings, layout, nextCommand, checking, openOverlay, setBadge, setWindowTitle, window as win } from "herdr";
import { clearTerminal } from "./clear-terminal.mjs";

function find(node, id) {
  if (node?.id === id) return node;
  return (node?.children ?? []).map(child => find(child, id)).find(Boolean);
}

export default class WorkspaceBar extends View {
  init(_props, cx) {
    this.width = 1200;
    this.badge = undefined;
    this.title = undefined;
    if (checking()) return;
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "terminal" || command === "agents") run("layout.switch", { name: `kage-${command}` });
        if (command === "appearance") this.appearance();
        if (command === "panels") setShared("workspace.panels", ["files", "changes"]);
        if (command === "files" || command === "changes") this.panel(command);
        if (command === "clear-terminal") {
          const terminal = terminals().find(terminal => terminal.address === focused()?.terminal);
          try { await clearTerminal(terminal, exec); }
          catch (error) { notify({ title: "Could not clear terminal", body: error.message, level: "error" }); }
        }
      }
    });
  }

  appearance() {
    openOverlay({ mod: "kage-appearance", kind: "window", key: "appearance", width: Math.min(1040, this.width * 0.9), height: 0.85 });
  }

  panel(id) {
    const root = layout();
    const panel = find(root, "panel");
    if (!panel) return;
    if (!panel.hidden && find(root, "panel-body")?.active === id) run("layout.hide", { id: "panel" });
    else {
      run("layout.select", { stack: "panel-body", child: id });
      run("layout.show", { id: "panel" });
    }
  }

  button(id, label, command, args, selected = false) {
    const t = theme();
    return h_flex().id(id).h(28).px(10).items_center().gap(6).rounded(5)
      .bg(selected ? t.selected : t.chrome).text_size(12).text_color(selected ? t.foreground : t.muted)
      .cursor_pointer().hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click(() => run(command, args)).child(label);
  }

  render() {
    const t = theme();
    const mode = shared("layout") === "kage-agents" ? "agents" : "terminal";
    const identity = shared("kage.identity") === "stack" ? "stack" : "kage";
    const space = spaces().find(s => s.active);
    const list = agents();
    const blocked = list.filter(a => a.status === "blocked");
    const done = list.filter(a => a.status === "done");
    const working = list.filter(a => a.status === "working");
    const badge = blocked.length ? String(blocked.length) : null;
    const title = `${space?.name ?? "Workspace"} · Kage`;
    if (!checking() && this.badge !== badge) { this.badge = badge; setBadge(badge); }
    if (!checking() && this.title !== title) { this.title = title; setWindowTitle(title); }
    const light = settings().dark === false;
    const compact = this.width < 950;
    const window = win() ?? {};
    return h_flex().size_full().min_w(0).px(12).gap(14).items_center().bg(t.chrome)
      .border_b(1).border_color(t.border)
      .on_size_change((size, cx) => { if (this.width !== size.width) { this.width = size.width; cx.notify(); } })
      .when(window.platform === "macos" && window.titlebar === "none" && !window.fullscreen, el => el.pl(80))
      .child(div().flex_none().tooltip("Workspace")
        .child(identity === "stack" ? svg("mods/kage-bar/stack-mark.svg").size(28).text_color(t.foreground)
          : image(`mods/kage-bar/kage-icon-${light ? "light" : "dark"}.png`).size(28).rounded(6)))
      .child(h_flex().gap(2).p(3).rounded(7).bg(t.surface).flex_none()
        .child(this.button("mode-terminal", "Terminal", "layout.switch", { name: "kage-terminal" }, mode === "terminal"))
        .child(this.button("mode-agents", "Agents", "layout.switch", { name: "kage-agents" }, mode === "agents")))
      .child(div().flex_1())
      .when(blocked.length > 0, el => el.child(this.button("needs-you", `${blocked.length} needs you`, "agent.focus", { terminal: blocked[0].address })
        .text_color(t.blocked).tooltip("Open the first agent waiting for you")))
      .when(done.length > 0, el => el.child(this.button("agents-done", `${done.length} finished`, "agent.focus", { terminal: done[0].address })
        .text_color(t.done).tooltip("Open the first finished agent")))
      .when(!compact, el => el.child(div().flex_none().text_size(12).text_color(t.muted).child(`${working.length} working`)))
      .when(mode === "agents", el => el
        .child(this.button("files", "Files", "kage-bar.files", {}))
        .child(this.button("changes", "Changes", "kage-bar.changes", {})))
      .child(div().id("appearance").px(10).py(6).rounded(5).text_size(12).text_color(t.muted).cursor_pointer()
        .hover(s => s.bg(t.hover).text_color(t.foreground))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_click(() => this.appearance()).child("Appearance"))
      .child(this.button("workspace-settings", svg("mods/workspace-chrome/settings.svg").size(16), "app.settings", {}).tooltip("Herdr settings · Cmd+,"))
      .when(window.buttons, el => el
        .child(this.button("window-min", "−", "window.minimize", {}))
        .child(this.button("window-max", "□", "window.maximize", {}))
        .child(this.button("window-close", "×", "window.close", {})));
  }

  close() {
    setBadge(null);
    setWindowTitle(null);
  }
}
