
import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, run, theme, home, openOverlay, layout, window as win } from "herdr";

function palette() {
  const t = theme();
  return { tray: t.surface, tab: t.selected, tabEdge: t.accent,
    hover: t.hover, edge: t.border, chip: t.raised, text: t.foreground, dim: t.muted };
}

function folder(cwd) {
  if (!cwd) return "";
  const h = home();
  return cwd === h ? "~" : cwd.startsWith(h + "/") ? "~" + cwd.slice(h.length) : cwd;
}

function lead(all, id) {
  const mine = all.filter((p) => p.tab === id);
  return mine.find((p) => p.focused) ?? mine.find((p) => p.program?.agent) ?? mine[0];
}

function tile(t, p) {
  const C = palette();
  const g = p?.program;
  const dot = p?.status && p.status !== "idle" ? t[p.status] : null;
  return div()
    .relative()
    .flex_none()
    .w(26)
    .h(26)
    .rounded(7)
    .border_1()
    .border_color(t.border)
    .bg(g?.tile ?? C.chip)
    .flex()
    .items_center()
    .justify_center()
    .when(Boolean(g?.icon), (el) =>
      el.child(g.tint ? svg(g.icon).size(15).text_color(g.color ?? C.text) : image(g.icon).w(15).h(15)),
    )
    .when(Boolean(dot), (el) =>
      el.child(div().absolute().top(-4).right(-4).w(11).h(11).rounded_full().border_2().border_color(C.tray).bg(dot)),
    );
}

function own(el) {
  return el.on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_mouse_down("right", (_e, cx) => cx.stop_propagation());
}

function windowButton(id, icon, command) {
  const C = palette();
  return own(
    div()
      .id(id)
      .flex_none()
      .w(24)
      .h(24)
      .rounded_full()
      .flex()
      .items_center()
      .justify_center()
      .bg(C.chip)
      .text_color(C.dim)
      .cursor_pointer()
      .hover((s) => s.bg(C.edge).text_color(C.text))
      .on_click(() => run(command))
      .child(svg(`mods/kawaii-bar/${icon}.svg`).size(14)),
  );
}

function iconButton(id, icon, onClick) {
  const C = palette();
  return own(div())
    .id(id)
    .flex_none()
    .p(7)
    .rounded(8)
    .text_color(C.dim)
    .cursor_pointer()
    .hover((s) => s.bg(C.chip).text_color(C.text))
    .on_click(onClick)
    .child(svg(`mods/kawaii-bar/${icon}.svg`).size(17));
}

export default class TerminalsBar extends View {
  tab(c, t, C, space, all) {
    const p = lead(all, c.id);
    const where = folder(p?.cwd);
    return own(h_flex()).id(`tm-${c.id}`).flex_shrink(1).w(260).min_w(0).h_full().pl(5).pr(12).gap(9)
      .items_center().rounded(13).border_1().cursor_pointer().text_size(13)
      .when(c.active, el => el.bg(C.tab).border_color(C.tabEdge))
      .when(!c.active, el => el.border_color("#00000000").hover(s => s.bg(C.hover)))
      .on_click(() => run("tab.select", { id: c.id }))
      .on_mouse_down("right", () => openOverlay({
        mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } },
      }))
      .child(tile(t, p))
      .child(h_flex().min_w(0).gap(6).truncate()
        .child(div().flex_none().text_color(c.active ? C.text : t.muted).child(c.name))
        .when(Boolean(where), el => el.child(div().truncate().text_color(C.dim).child(where))));
  }

  spaceButton(t, C, space) {
    return own(h_flex()).id("tm-space").flex_none().h(30).pl(10).pr(12).gap(8).items_center().rounded_full()
      .bg(C.chip).cursor_pointer().text_size(13).text_color(C.dim).hover(s => s.text_color(C.text))
      .on_click(() => openOverlay({ mod: "picker", kind: "popup", at: "top", offset: 40, width: 640, height: 0.8 }))
      .child(svg("mods/kawaii-bar/cat.svg").size(20).text_color(t.accent))
      .child(div().max_w(160).truncate().text_color(C.text).child(space.name));
  }

  fontButton(t) {
    return own(div()).id("kawaii-fonts").px(10).py(6).rounded_full().text_size(12).text_color(t.accent)
      .cursor_pointer().hover(s => s.bg(t.raised))
      .on_click(() => openOverlay({ mod: "kawaii-fonts", kind: "dialog", width: 1120, height: 0.9 }))
      .child("Fonts");
  }

  themeButton(t) {
    return own(h_flex()).id("kawaii-theme").flex_none().gap(7).items_center().px(10).py(6).rounded_full()
      .text_size(12).text_color(t.accent).cursor_pointer().hover(s => s.bg(t.raised))
      .on_click(() => run("layout.set", { layout: { ...layout(), theme: t.background === "#221c2b" ? "strawberry-milk" : "sakura-night" } }))
      .child(svg("mods/kawaii-bar/cat.svg").size(18)).child("catnap");
  }

  windowButtons(w) {
    return h_flex().flex_none().pl(6).pr(4).gap(8)
      .child(windowButton("tm-min", "win-min", "window.minimize"))
      .child(windowButton("tm-max", w.maximized ? "win-restore" : "win-max", "window.maximize"))
      .child(windowButton("tm-close", "win-close", "window.close"));
  }

  render() {
    const t = theme();
    const C = palette();
    const space = spaces().find(p => p.active);
    if (!space) return div();
    const all = panes();
    const w = win() ?? {};
    return h_flex().size_full().gap(8).items_center()
      .when(w.platform === "macos" && w.titlebar === "none" && !w.fullscreen, el => el.pl(72))
      .child(this.spaceButton(t, C, space))
      .child(h_flex().flex_shrink(1).min_w(0).h(36).p(3).gap(3).rounded(16).bg(C.tray)
        .children(space.tabs.map(c => this.tab(c, t, C, space, all))))
      .child(div().flex_1())
      .child(this.fontButton(t))
      .child(this.themeButton(t))
      .child(iconButton("tm-keys", "command", () => run("app.palette")))
      .child(iconButton("tm-new", "plus", () => run("tab.new", { space: space.id })))
      .when(Boolean(w.buttons), el => el.child(this.windowButtons(w)));
  }
}
