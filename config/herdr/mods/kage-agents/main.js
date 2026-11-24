
import { View, div, image, svg } from "gpui-kit";
import { v_flex, h_flex, ScrollHandle } from "gpui-base";
import { agents, terminals, panes, focused, spaces, home, run, theme, shared, setShared, setAgentOrder, openOverlay, closeOverlay, props, nextCommand, checking } from "herdr";
import { shortcutOrder, tabTitle, terminalEntries } from "./navigation.mjs";

function leadPanes(all) {
  const leads = new Map();
  for (const p of all) {
    if (!p.terminal) continue;
    const current = leads.get(p.tab);
    if (!current || (!current.program?.agent && (p.program?.agent || (!current.focused && p.focused)))) leads.set(p.tab, p);
  }
  return leads;
}

const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
const kidStatus = (k, listed) => {
  const s = listed.get(k.address) ?? k.status;
  return s === "error" ? "blocked" : s === "done" ? "idle" : s;
};
const SORTS = [
  { id: "priority", label: "Priority", icon: "clock" },
  { id: "grouped", label: "Grouped by space", icon: "layers" },
];
const sortOf = () => SORTS.find((s) => s.id === shared("agents.sort")) ?? SORTS[0];
const SECTION = { 4: "Needs you", 3: "Done", 2: "Working", 1: "Idle" };
const SECTION_STATUS = { 4: "blocked", 3: "done", 2: "working" };

function duration(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "<1m";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

export default class Agents extends View {
  init(_props, cx) {
    if (props()?.sortMenu) return;
    this.folded = new Set();
    this.shortcutOrder = [];
    this.shortcutNumbers = new Map();
    this.scroll = ScrollHandle.new();
    try { this.changed = JSON.parse(localStorage.getItem("changed") ?? "{}"); } catch { this.changed = {}; }
    if (!this.changed || typeof this.changed !== "object" || Array.isArray(this.changed)) this.changed = {};
    try { this.pendingPins = JSON.parse(localStorage.getItem("pins") ?? "[]"); } catch { this.pendingPins = []; }
    if (!Array.isArray(this.pendingPins)) this.pendingPins = [];
    if (!this.pendingPins.length) localStorage.removeItem("pins");
    this.migratingPins = new Set();
    cx.timer.every(30000, (cx) => cx.notify());
    if (checking()) return;
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        const match = /^select-([1-9])$/.exec(command);
        const terminal = match ? this.shortcutOrder[Number(match[1]) - 1] : null;
        if (terminal) run("agent.focus", { terminal });
      }
    });
  }

  track(list, now) {
    let dirty = false;
    for (const a of list) {
      const s = a.status === "done" ? "idle" : a.status;
      if (this.changed[a.address]?.s === s) continue;
      this.changed[a.address] = { s, at: now };
      dirty = true;
    }
    if (!dirty) return;
    const listed = new Set(list.map((a) => a.address));
    for (const [k, c] of Object.entries(this.changed)) if (!listed.has(k) && now - c.at > 30 * 86400000) delete this.changed[k];
    localStorage.setItem("changed", JSON.stringify(this.changed));
  }

  migratePins(all) {
    const listed = new Map(all.filter((t) => t.state === "live").map((t) => [t.address, t]));
    const pending = this.pendingPins.filter((address) => {
      const terminal = listed.get(address);
      if (!terminal) return true;
      if (terminal.labels?.["herdr.pinned"]) return false;
      if (!this.migratingPins.has(address)) {
        this.migratingPins.add(address);
        run("terminal.pin", { terminal: address, pinned: true });
      }
      return true;
    });
    if (pending.length === this.pendingPins.length) return;
    this.pendingPins = pending;
    if (pending.length) localStorage.setItem("pins", JSON.stringify(pending));
    else localStorage.removeItem("pins");
  }

  since(a) {
    return this.changed[a.address]?.at ?? 0;
  }

  rank(a) {
    return RANK[a.status] ?? 0;
  }

  sortMenu(t) {
    const on = sortOf().id;
    return v_flex()
      .w_full()
      .p(5)
      .bg(t.popover)
      .text_size(12.8)
      .child(div().px(8).pt(4).pb(6).text_size(11).text_color(t.dim).child("Sort agents"))
      .children(SORTS.map((s) => h_flex()
        .id(`sort-${s.id}`)
        .h(31)
        .px(8)
        .gap(9)
        .rounded(7)
        .items_center()
        .text_color(t.foreground)
        .hover((el) => el.bg(t.hover))
        .on_click(() => {
          setShared("agents.sort", s.id);
          closeOverlay(props().overlay);
        })
        .child(svg(`mods/workspace-chrome/${s.icon}.svg`).size(14).flex_none().text_color(t.muted))
        .child(div().flex_1().child(s.label))
        .when(s.id === on, (el) => el.child(svg("mods/workspace-chrome/check.svg").size(14).flex_none().text_color(t.foreground)))));
  }

  peek(addr) {
    run("terminal.peek", { terminal: addr });
  }

  tree(all, addr, lead = []) {
    const kids = all.filter((k) => k.parent === addr && k.state === "live");
    return kids.flatMap((k, i) => {
      const last = i === kids.length - 1;
      return [
        { t: k, lines: [...lead, last ? "└" : "├"] },
        ...this.tree(all, k.address, [...lead, last ? "" : "│"]),
      ];
    });
  }

  subRow(t, s, shown, compact) {
    const k = s.t;
    const st = kidStatus(k, this.listed);
    const pic = icon(k.program, 14, t.foreground);
    const on = k.address === shown;
    return h_flex()
      .id(`sub-${k.address}`)
      .pl(39)
      .pr(8)
      .rounded(8)
      .h(26)
      .flex_none()
      .gap(0)
      .items_center()
      .text_size(12.5)
      .when(on, (el) => el.bg(t.raised))
      .hover((s) => s.bg(t.hover))
      .on_click(() => (this.listed.has(k.address) ? run("pane.focus", { terminal: k.address }) : this.peek(k.address)))
      .children(s.lines.map(l => div().self_start().mt(-4).w(9).h(17).mr(4).flex_none()
        .when(Boolean(l), el => el.border_l(1.5).border_color(t.input))
        .when(l === "└" || l === "├", el => el.border_b(1.5).rounded_bl(6))))
      .when(Boolean(pic), el => el.child(div().mr(8).child(pic)))
      .child(div().flex_1().truncate().text_color(on ? t.foreground : t.muted).child(k.name || k.template || k.program?.name || k.address))
      .child(this.status(t, { status: st }, compact));
  }

  status(t, a, compact = false) {
    const color = t[a.status] ?? t.dim;
    if (a.status === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color(t.working).spin(900);
    if (a.status === "blocked" && compact) return div().size(14).flex_none().rounded(4).bg(t.blocked + "26").text_size(10.5).font_bold().text_color(t.blocked).flex().items_center().justify_center().child("!");
    if (a.status === "blocked") return div().flex_none().px(6).h(18).rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).flex().items_center().child("Needs you");
    if (a.status === "idle") return div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim);
    return div().size(7).mx(3).flex_none().rounded(4).bg(a.status === "done" ? color : t.dim + "00");
  }

  agentState() {
    const sort = sortOf();
    let list = agents();
    this.listed = new Map(list.map(a => [a.address, a.status]));
    const all = terminals();
    this.migratePins(all);
    const now = Date.now();
    this.track(list, now);
    const nested = new Set(list.flatMap(a => this.tree(all, a.address).map(s => s.t.address)));
    list = list.filter(a => a.pinned || !nested.has(a.address));
    const byPriority = sort.id === "priority";
    const urgency = new Map(list.map(a => [a.address, Math.max(this.rank(a), ...this.tree(all, a.address).map(s => RANK[kidStatus(s.t, this.listed)] ?? 0))]));
    if (byPriority) list = [...list].sort((x, y) => urgency.get(y.address) - urgency.get(x.address) || this.since(y) - this.since(x) || y.seq - x.seq);
    const pinned = list.filter(a => a.pinned);
    const rest = list.filter(a => !a.pinned);
    list = [...pinned, ...rest];
    return { sort, list, all, now, byPriority, urgency, pinned, rest, shown: focused()?.agent, ...this.titleDetails(list) };
  }

  titleDetails(list) {
    const tabCounts = new Map();
    for (const a of list) tabCounts.set(a.tab, (tabCounts.get(a.tab) ?? 0) + 1);
    const leads = leadPanes(panes());
    const allSpaces = spaces();
    const tabs = new Map(allSpaces.flatMap(s => s.tabs).map(tab => [tab.id, tab]));
    const labels = new Map(list.map(a => {
      const tab = tabs.get(a.tab);
      const many = tabCounts.get(a.tab) > 1;
      return [a.address, tab ? tabTitle(many ? { ...tab, named: false } : tab, many ? a : leads.get(a.tab)) : (a.title || a.program?.name || "")];
    }));
    const detail = new Map(list.map(a => [a.address, /^\d+$/.test(labels.get(a.address)) ? null : labels.get(a.address)]));
    const seen = {};
    for (const a of list) { const key = `${a.space_name}\u0000${detail.get(a.address) ?? ""}`; seen[key] = (seen[key] ?? 0) + 1; }
    for (const a of list) {
      if (detail.get(a.address) == null && seen[`${a.space_name}\u0000`] > 1) detail.set(a.address, labels.get(a.address));
    }
    return { labels, detail, spaceCount: allSpaces.length };
  }

  agentGroups(state) {
    const { pinned, rest, byPriority, urgency } = state;
    const groups = pinned.length ? [{ id: "pinned", label: "Pinned", status: null, members: pinned }] : [];
    for (const a of rest) {
      const rank = urgency.get(a.address) || RANK.idle;
      const id = byPriority ? `sec-${rank}` : `sp-${a.space}`;
      if (groups.at(-1)?.id === id) groups.at(-1).members.push(a);
      else groups.push({ id, label: byPriority ? SECTION[rank] : a.space_name || "", status: byPriority ? SECTION_STATUS[rank] : null, members: [a] });
    }
    return groups;
  }

  foldButton(t, a, subs) {
    const statuses = subs.map(s => kidStatus(s.t, this.listed));
    const top = statuses.reduce((m, s) => ((RANK[s] ?? 0) > (RANK[m] ?? 0) ? s : m), null);
    const open = !this.folded.has(a.address);
    return div().id(`fold-${a.address}`).h(18).px(3).gap(3).flex().items_center().rounded(4).text_size(11)
      .text_color(open ? t.dim : (t[top] ?? t.dim)).cursor_pointer()
      .hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        open ? this.folded.add(a.address) : this.folded.delete(a.address);
        cx.notify();
      })
      .child(svg(`mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`).size(11).flex_none())
      .when(!open, el => el.child(String(subs.length)));
  }

  pinButton(t, a) {
    return div().id(`pin-${a.address}`).flex_none().p(2).rounded(4).text_color(t.dim).cursor_pointer()
      .hover(s => s.bg(t.hover).text_color(t.foreground)).tooltip(a.pinned ? "Unpin" : "Pin to the top")
      .on_click((_e, cx) => {
        cx.stop_propagation();
        run("terminal.pin", { terminal: a.address, pinned: !a.pinned });
        this.hovered = null;
        cx.notify();
      })
      .child(svg(`mods/workspace-chrome/${a.pinned ? "pin-off" : "pin"}.svg`).size(13));
  }

  agentRow(t, a, subs, state) {
    const pic = icon(a.program, 16, t.foreground);
    const more = state.detail.get(a.address);
    const machine = a.address.includes("/") ? a.address.split("/")[0] : null;
    const when = this.since(a);
    const idle = a.status === "idle" && !a.focused;
    const full = (state.byPriority || a.pinned) && state.spaceCount > 1;
    const label = state.labels.get(a.address);
    const name = full ? a.space_name || label : more ?? (/^\d+$/.test(label) ? a.program?.name || label : label);
    return h_flex().id(`ag-${a.address}`).px(8).h(30).flex_none().rounded(8).items_center().gap(9)
      .when(a.focused, el => el.bg(t.selected)).cursor_pointer().hover(s => s.bg(t.hover))
      .on_hover((on, cx) => {
        if (on) this.hovered = a.address;
        else if (this.hovered === a.address) this.hovered = null;
        cx.notify();
      })
      .on_click(() => run("pane.focus", { pane: a.pane }))
      .child(div().w(21).flex_none().text_center().text_size(11).font_medium()
        .text_color(a.focused ? t.foreground : t.muted)
        .tooltip(`Cmd+${this.shortcutNumbers.get(a.address) ?? ""}`)
        .child((this.shortcutNumbers.get(a.address) ?? 10) <= 9 ? String(this.shortcutNumbers.get(a.address)) : ""))
      .when(Boolean(pic), el => el.child(div().id(`agent-fold-${a.address}`)
        .when(subs.length > 0, el => el.on_click((_e, cx) => {
          cx.stop_propagation();
          this.folded.has(a.address) ? this.folded.delete(a.address) : this.folded.add(a.address);
          cx.notify();
        })).child(pic)))
      .child(h_flex().flex_1().min_w(0).gap(5).items_center()
        .child(div().min_w(0).max_w(full && more ? 120 : 200).truncate().text_color(idle ? t.muted : t.foreground).child(name))
        .when(full && Boolean(more), el => el.child(div().flex_1().min_w(0).truncate().text_color(t.dim).child(`\u00b7 ${more}`))))
      .when(Boolean(machine), el => el.child(div().text_size(10).text_color(t.dim).child(machine)))
      .when(subs.length > 0, el => el.child(this.foldButton(t, a, subs)))
      .when(this.hovered === a.address, el => el.child(this.pinButton(t, a)))
      .when(this.hovered !== a.address && Boolean(when), el => el.child(div().flex_none().text_size(11).text_color(t.dim).child(duration(state.now - when))))
      .child(this.status(t, a, state.byPriority && !a.pinned));
  }

  groupHeader(t, group, byPriority) {
    const open = !this.folded.has(group.id);
    const top = group.members.reduce((m, a) => ((RANK[a.status] ?? 0) > (RANK[m] ?? 0) ? a.status : m), null);
    return h_flex().id(group.id).px(8).pt(8).h(30).flex_none().gap(6).items_center().text_size(11).font_medium()
      .cursor_pointer().hover(s => s.text_color(t.foreground))
      .on_click((_e, cx) => {
        open ? this.folded.add(group.id) : this.folded.delete(group.id);
        cx.notify();
      })
      .child(div().truncate().text_color(t[group.status] ?? t.dim).child(group.label))
      .when(byPriority || !open, el => el.child(div().text_color(t.dim).child(String(group.members.length))))
      .child(div().flex_1())
      .when(!open, el => el
        .when(!byPriority && top && top !== "idle", el => el.child(this.status(t, { status: top }, true)))
        .child(svg("mods/workspace-chrome/chevron-right.svg").size(11).flex_none().text_color(t.dim)));
  }

  agentRows(t, state) {
    const groups = this.agentGroups(state);
    this.shortcutOrder = shortcutOrder(groups, this.folded);
    this.shortcutNumbers = new Map(this.shortcutOrder.map((address, index) => [address, index + 1]));
    setAgentOrder(this.shortcutOrder);
    const withKids = a => {
      const subs = this.tree(state.all, a.address);
      const row = this.agentRow(t, a, subs, state);
      return this.folded.has(a.address) ? [row] : [row, ...subs.map(s => this.subRow(t, s, state.shown, state.byPriority))];
    };
    return groups.flatMap(group => [this.groupHeader(t, group, state.byPriority), ...(this.folded.has(group.id) ? [] : group.members.flatMap(withKids))]);
  }

  heading(t, sort) {
    return h_flex().px(16).h(41).pt(14).pb(5).flex_none().items_center().justify_between()
      .child(div().text_size(11.5).font_medium().text_color(t.dim).child("Agents"))
      .child(div().text_size(10.5).text_color(t.muted).child("⌘1–9"))
      .child(div().id("ag-sort").text_size(11).text_color(t.dim).hover(s => s.text_color(t.foreground))
        .on_click(() => openOverlay({ mod: "kage-agents", kind: "popup", width: 200, height: 140, props: { sortMenu: true } }))
        .tooltip(`Sort agents: ${sort.label}`).child(svg(`mods/workspace-chrome/${sort.icon}.svg`).size(14)));
  }

  terminalRow(t, entry, tab, nested) {
    const cwd = entry.cwd ?? "";
    const folder = !tab.machine && (cwd === home() || cwd.startsWith(`${home()}/`)) ? `~${cwd.slice(home().length)}` : cwd;
    const context = [tab.space_name, tab.machine, folder].filter(Boolean).join(" · ");
    return h_flex().id(nested ? `terminal-${entry.address}` : `terminal-tab-${tab.id}`).px(8).h(nested ? 42 : 48).flex_none().rounded(8).items_center().gap(9)
      .when(entry.selected, el => el.bg(t.selected)).cursor_pointer().hover(s => s.bg(t.hover))
      .tooltip(`Tab ${tab.number}${nested ? ` · Pane ${entry.number}` : ""} · ${entry.name}\n${context}`)
      .on_click(() => nested ? run("pane.focus", { pane: entry.pane }) : run("tab.select", { id: tab.id }))
      .child(div().w(21).flex_none().text_center().text_size(11).font_medium()
        .text_color(entry.selected ? t.foreground : t.muted).child(nested ? "" : tab.number))
      .when(nested, el => el.child(div().w(8).h(32).flex_none().border_l(1).border_color(t.border)))
      .child(icon(entry.program, nested ? 13 : 16, t.muted) ?? div().w(16).child(">_"))
      .child(v_flex().flex_1().min_w(0).gap(3)
        .child(div().truncate().text_size(nested ? 12 : 13).text_color(t.foreground).child(nested ? `Pane ${entry.number} · ${entry.name}` : entry.name))
        .child(div().truncate().text_size(11).text_color(t.dim).child(context)))
      .when(!nested && tab.pane_count > 1, el => el.child(div().flex_none().text_size(10.5).text_color(t.muted).child(`${tab.pane_count} panes`)));
  }

  terminalRows(t, entries) {
    if (!entries.length) return { rows: [], selected: -1 };
    const rows = [
      h_flex().id("terminals-heading").px(8).pt(8).h(32).flex_none().gap(6).items_center().text_size(11).text_color(t.dim)
        .child(div().truncate().child("Terminals"))
        .child(div().child(String(entries.length))),
    ];
    let selected = -1;
    for (const tab of entries) {
      const lead = tab.panes.find(pane => pane.selected) ?? tab.panes[0];
      if (tab.selected) selected = rows.length;
      rows.push(this.terminalRow(t, { ...lead, name: tab.name, selected: tab.selected }, tab, false));
      if (tab.pane_count > 1) {
        for (const pane of tab.panes) {
          if (pane.selected) selected = rows.length;
          rows.push(this.terminalRow(t, pane, tab, true));
        }
      }
    }
    return { rows, selected };
  }

  render() {
    const t = theme();
    if (props()?.sortMenu) return this.sortMenu(t);
    const state = this.agentState();
    const rows = this.agentRows(t, state);
    const entries = terminalEntries(spaces(), panes(), agents(), focused());
    const terminalList = this.terminalRows(t, entries);
    const reveal = terminalList.selected < 0 ? null : `${focused()?.terminal}:${rows.length + terminalList.selected}`;
    if (reveal && reveal !== this.revealedTerminal) this.scroll.scroll_to_item(rows.length + terminalList.selected);
    this.revealedTerminal = reveal;
    return v_flex().size_full().min_h(0).bg(t.chrome).border_t(1).border_color(t.border).text_size(13)
      .child(this.heading(t, state.sort))
      .when(state.list.length === 0, el => el.child(div().px(12).text_size(12).text_color(t.dim)
        .child("No agent status yet. Agents show up here when they report their status. Older versions and agents inside tmux may not.")))
      .child(v_flex().id("ag-list").flex_1().min_h(0).px(8).overflow_y_scrollbar().track_scroll(this.scroll).mode("always")
        .children([...rows, ...terminalList.rows]));
  }
}
