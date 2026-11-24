import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, props, run, home, theme } from "herdr";

export default class PaneHeader extends View {
  button(pane, icon, command, args, title) {
    const t = theme();
    return div().id(`${pane}-${icon}`).p(4).rounded(4).text_color(t.muted).cursor_pointer()
      .hover(s => s.bg(t.hover).text_color(t.foreground)).tooltip(title)
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => { cx.stop_propagation(); run(command, { pane, ...args }); })
      .child(svg(`mods/pane/${icon}.svg`).size(14));
  }

  render() {
    const t = theme();
    const p = panes().find(p => p.pane === props()?.pane);
    if (!p) return div();
    const g = p.program;
    const cwd = p.cwd?.replace(home(), "~") ?? "";
    const status = p.status === "blocked" ? "Needs you" : p.status === "done" ? "Finished" : p.status === "working" ? "Working" : "";
    return h_flex().size_full().px(10).gap(9).items_center().bg(t.surface)
      .on_click(() => run("pane.focus", { pane: p.pane }))
      .when(Boolean(g?.icon), el => el.child(g.tint ? svg(g.icon).size(14).text_color(t.muted) : image(g.icon).size(14)))
      .child(div().min_w(0).max_w(450).truncate().text_size(12).font_medium().text_color(t.foreground).child(p.title || g?.name || "Terminal"))
      .child(div().flex_1().min_w(0).truncate().text_size(11).text_color(t.dim).child(p.branch ? `${cwd} · ${p.branch}` : cwd))
      .when(Boolean(status), el => el.child(div().flex_none().text_size(11).text_color(t[p.status]).child(status)))
      .child(this.button(p.pane, "split-right", "pane.split", { direction: "right" }, "Split right · Cmd+D"))
      .child(this.button(p.pane, "split-down", "pane.split", { direction: "down" }, "Split down · Cmd+Shift+D"))
      .child(this.button(p.pane, p.zoomed ? "unzoom" : "zoom", "pane.zoom", {}, "Zoom pane · Cmd+Shift+Enter"))
      .child(this.button(p.pane, "close", "pane.close", {}, "Close pane · Cmd+W"));
  }
}
