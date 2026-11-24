import { View, div, svg, image } from "gpui-kit";
import { h_flex, v_flex, Input, InputState } from "gpui-base";
import { theme, themes, fonts, settings, shared, setShared, appHome, readTextFile, writeTextFile, props, closeOverlay, nextCommand, checking } from "herdr";
import { LIMITS, lookWriter, activeTheme } from "./look.mjs";

const PALETTES = [
  { name: "Kage", dark: "kage-night", light: "kage-day", description: "Warm ink. The shadow mark." },
  { name: "Kage Stack", dark: "stack-night", light: "stack-day", description: "Black and white. Pixel lettering." },
  { name: "Sakura", dark: "sakura-night", light: "strawberry-milk", description: "Your original soft pink palette." },
];

const PRESETS = [
  { id: "comfort", name: "Comfort", font: "Anthrosevka Mono", font_size: 17, terminal_line_height: 1.1 },
  { id: "compact", name: "Compact", font: "Hack Nerd Font Mono", font_size: 15, terminal_line_height: 1 },
  { id: "pixel", name: "Pixel", font: "DepartureMono Nerd Font Mono", font_size: 16, terminal_line_height: 1.1 },
];

export default class Appearance extends View {
  init(_props, cx) {
    const s = settings();
    this.draft = {
      font: String(s.font_family ?? s.font ?? "Hack Nerd Font Mono"),
      ui_font: String(s.ui_font_family ?? s.ui_font ?? "Geist"),
      font_size: Number(s.font_size ?? 16.5),
      font_weight: Number(s.font_weight ?? 400),
      terminal_line_height: Number(s.terminal_line_height ?? 1),
      terminal_cell_width: Number(s.terminal_cell_width ?? 1),
      terminal_scroll_speed: Number(s.terminal_scroll_speed ?? 1),
      zoom: Number(s.zoom ?? 1),
      font_ligatures: Boolean(s.font_ligatures),
      theme: activeTheme(s),
    };
    this.identity = shared("kage.identity") === "stack" ? "stack" : "kage";
    this.width = 1100;
    this.filter = "";
    this.all = false;
    this.target = "font";
    this.limit = 40;
    this.pending = 0;
    this.error = null;
    this.message = "Changes apply immediately.";
    const file = `${appHome()}/settings.json`;
    this.save = lookWriter({ read: () => readTextFile(file), write: (next, expected) => writeTextFile(file, next, expected) });
    this.search = InputState.new({ placeholder: "Search installed fonts" });
    this.search.on("change", (_e, cx) => {
      this.filter = this.search.value();
      this.limit = 40;
      cx.notify();
    });
    if (checking()) return;
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "size-up") this.step("font_size", 1, cx);
        if (command === "size-down") this.step("font_size", -1, cx);
        if (command === "roomy") this.edit("terminal_line_height", 1.15, cx);
        const preset = PRESETS.find(p => p.id === command);
        if (preset) this.preset(preset, cx);
        if (PALETTES.some(p => p.light === command || p.dark === command)) this.edit("theme", command, cx);
      }
    });
  }

  preset(preset, cx) {
    const { font, font_size, terminal_line_height } = preset;
    if (!fonts().includes(font)) { this.message = `${font} is not installed.`; cx.notify(); return; }
    const patch = { font, font_size, terminal_line_height, font_weight: 400, terminal_cell_width: 1 };
    Object.assign(this.draft, patch);
    this.persist(patch, cx);
  }

  requestClose(cx) {
    if (this.pending) { this.closeWhenSaved = true; this.message = "Finishing your changes…"; cx.notify(); }
    else closeOverlay(props().overlay);
  }

  edit(key, value, cx) {
    this.draft[key] = value;
    this.persist({ [key]: value }, cx);
  }

  step(key, direction, cx) {
    const [min, max, step] = LIMITS[key];
    this.edit(key, Math.round(Math.min(max, Math.max(min, this.draft[key] + direction * step)) * 100) / 100, cx);
  }

  persist(patch, cx) {
    this.pending++;
    this.message = "Saving…";
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        await this.save(patch);
      } catch {}
      const state = this.save.state();
      this.pending = state.pending;
      this.error = state.error ? `Some appearance changes are not saved. ${state.error}` : null;
      this.message = this.pending ? "Saving…" : this.error ?? "Saved to Terminal and Agents.";
      if (!this.pending && !this.error && this.closeWhenSaved) { closeOverlay(props().overlay); return; }
      cx.notify();
    });
  }

  button(id, label, action, selected = false) {
    const t = theme();
    return div().id(id).px(10).py(6).rounded(6).border_1()
      .border_color(selected ? t.accent : t.border).bg(selected ? t.selected : t.surface)
      .text_size(12).text_color(selected ? t.foreground : t.muted).cursor_pointer()
      .hover(s => s.bg(t.hover).text_color(t.foreground)).on_click(action).child(label);
  }

  stepper(key, label, suffix = "") {
    const t = theme();
    const [min, max] = LIMITS[key];
    return h_flex().items_center().gap(8)
      .child(div().flex_1().text_size(12).text_color(t.muted).child(label))
      .child(this.button(`${key}-less`, "−", (_e, cx) => this.step(key, -1, cx)))
      .child(div().w(50).text_center().text_size(12).text_color(t.foreground).child(`${this.draft[key]}${suffix}`))
      .child(this.button(`${key}-more`, "+", (_e, cx) => this.step(key, 1, cx)))
      .tooltip(`${min} to ${max}`);
  }

  palette(p) {
    const t = theme();
    const available = themes();
    return v_flex().gap(7).py(7)
      .child(h_flex().items_center().justify_between()
        .child(div().font_family(p.name === "Kage" ? "Geist Pixel Square" : "DepartureMono Nerd Font Mono")
          .text_size(16).text_color(t.foreground).child(p.name)))
      .child(h_flex().gap(8).children([p.dark, p.light].map(name => {
        const colors = available.find(x => x.name === name)?.colors ?? t;
        const selected = this.draft.theme === name;
        return v_flex().id(`theme-${name}`).flex_1().min_w(0).p(10).gap(4).rounded(7).border_1()
          .border_color(selected ? t.accent : t.border).bg(colors.background).cursor_pointer()
          .on_click((_e, cx) => this.edit("theme", name, cx))
          .child(div().text_size(13).font_semibold().text_color(colors.foreground).child(name === p.dark ? "Night" : "Day"))
          .child(div().font_family(this.draft.font).text_size(12).text_color(colors.accent ?? colors.foreground).child("Aa 01 {}"))
          .child(div().text_size(10).text_color(colors.muted ?? colors.foreground).child(selected ? "Selected" : "Use theme"));
      })));
  }

  fontCard(family, sample) {
    const t = theme();
    const selected = this.draft[this.target] === family;
    return v_flex().id(`family-${family}`).flex_1().min_w(0).p(14).gap(10).rounded(8).border_1()
      .border_color(selected ? t.accent : t.border).bg(selected ? sample.selected : sample.background)
      .cursor_pointer().hover(s => s.border_color(t.accent))
      .on_click((_e, cx) => this.edit(this.target, family, cx))
      .child(h_flex().gap(8).items_center()
        .child(div().flex_1().min_w(0).truncate().text_size(12).font_medium().text_color(sample.muted).child(family))
        .when(selected, el => el.child(div().text_size(11).text_color(sample.accent).child("Selected"))))
      .child(v_flex().font_family(family).font_weight(this.draft.font_weight).text_size(this.draft.font_size).line_height(this.draft.terminal_line_height).gap(4)
        .child(div().text_color(sample.foreground).child("kage covers for me"))
        .child(div().text_color(sample.ansi6 ?? t.ansi6).child("0O 1Il {} [] => ~/")));
  }

  render(cx) {
    const t = theme();
    const sample = { ...t, ...(themes().find(p => p.name === this.draft.theme)?.colors ?? {}) };
    const compact = this.width < 900;
    const query = this.filter.trim().toLowerCase();
    const families = fonts().filter(f => (this.all || this.target === "ui_font" || /mono|\bcode\b|hack|iosevka|monaspace|menlo|consolas|cascadia|departure/i.test(f))
      && f.toLowerCase().includes(query)).sort((a, b) => a.localeCompare(b));
    const shown = families.slice(0, this.limit);
    const columns = compact ? 1 : 2;
    const rows = Array.from({ length: Math.ceil(shown.length / columns) }, (_, i) =>
      h_flex().gap(10).items_stretch().children(shown.slice(i * columns, (i + 1) * columns).map(f => this.fontCard(f, sample))));
    return v_flex().size_full().min_h(0).bg(t.popover).p(20).gap(16)
      .on_size_change((size, cx) => { if (this.width !== size.width) { this.width = size.width; cx.notify(); } })
      .child(h_flex().items_center().gap(12)
        .child(image(`mods/kage-bar/kage-icon-${this.draft.theme.endsWith("day") || this.draft.theme === "strawberry-milk" ? "light" : "dark"}.png`).size(38).rounded(8))
        .child(v_flex().flex_1().gap(3)
          .child(div().text_size(22).font_medium().text_color(t.foreground).child("Appearance"))
          .child(div().text_size(12).text_color(t.muted).child("Fonts, colors and spacing. Changes apply immediately.")))
        .child(this.button("appearance-close", "Close", (_e, cx) => this.requestClose(cx))))
      .child(h_flex().flex_1().min_h(0).gap(20).items_stretch()
        .child(v_flex().id("appearance-controls").w(compact ? 250 : 290).flex_none().min_h(0).overflow_y_scrollbar().gap(12).pr(4)
          .child(div().text_size(13).font_semibold().text_color(t.foreground).child("Workspace mark"))
          .child(h_flex().gap(8).children([["kage", "Shadow"], ["stack", "Stack"]].map(([key, name]) =>
            this.button(`identity-${key}`, name, (_e, cx) => { this.identity = key; setShared("kage.identity", key); cx.notify(); }, this.identity === key))))
          .child(div().pt(5).text_size(13).font_semibold().text_color(t.foreground).child("Palette"))
          .children(PALETTES.map(p => this.palette(p)))
          .child(div().pt(8).text_size(13).font_semibold().text_color(t.foreground).child("Type and spacing"))
          .child(this.stepper("font_size", "Terminal size", "px"))
          .child(h_flex().gap(4).children([12, 14, 16, 16.5, 18, 20, 24].map(n => this.button(`size-${n}`, String(n), (_e, cx) => this.edit("font_size", n, cx), this.draft.font_size === n))))
          .child(this.stepper("font_weight", "Weight"))
          .child(this.stepper("terminal_line_height", "Line height", "×"))
          .child(this.stepper("terminal_cell_width", "Cell width", "×"))
          .child(this.stepper("terminal_scroll_speed", "Scroll speed", "×"))
          .child(this.stepper("zoom", "Whole app", "×"))
          .child(this.button("ligatures", `Ligatures ${this.draft.font_ligatures ? "on" : "off"}`, (_e, cx) => this.edit("font_ligatures", !this.draft.font_ligatures, cx), this.draft.font_ligatures))
          .child(div().text_size(11).text_color(t.dim).child("Cell width, ligatures, scrolling and zoom show in the live terminal. Available weights depend on the font.")))
        .child(v_flex().flex_1().min_w(0).min_h(0).gap(12)
          .child(h_flex().gap(6).items_center()
            .child(div().text_size(12).text_color(t.muted).child("Presets"))
            .children(PRESETS.filter(p => fonts().includes(p.font)).map(p => this.button(`preset-${p.id}`, p.name, (_e, cx) => this.preset(p, cx)))))
          .child(h_flex().gap(6).items_center()
            .child(this.button("target-terminal", "Terminal font", (_e, cx) => { this.target = "font"; cx.notify(); }, this.target === "font"))
            .child(this.button("target-interface", "Interface font", (_e, cx) => { this.target = "ui_font"; cx.notify(); }, this.target === "ui_font"))
            .child(div().flex_1())
            .child(this.button("font-scope", this.all ? "All installed" : "Code fonts", (_e, cx) => { this.all = !this.all; cx.notify(); })))
          .child(Input.new(this.search).h(34).px(10).rounded(6).border_1().border_color(t.border).bg(t.background).text_size(13).text_color(t.foreground))
          .child(v_flex().p(16).gap(7).rounded(8).border_1().border_color(t.border).bg(sample.background)
            .child(div().text_size(11).text_color(sample.muted).child(`${this.draft.font} · ${this.draft.font_size}px · ${this.draft.terminal_line_height}× rows`))
            .child(div().font_family(this.draft.font).font_weight(this.draft.font_weight).text_size(this.draft.font_size).line_height(this.draft.terminal_line_height).text_color(sample.foreground).child('const kage = "at work";'))
            .child(div().font_family(this.draft.ui_font).text_size(13).text_color(sample.muted).child(`Interface: ${this.draft.ui_font}`)))
          .child(v_flex().id("appearance-fonts").flex_1().min_h(0).overflow_y_scrollbar().gap(10)
            .children(rows)
            .when(families.length === 0, el => el.child(div().p(20).text_color(t.muted).child("No installed font matches. Try another name or All installed.")))
            .when(families.length > shown.length, el => el.child(this.button("more-fonts", `Show more (${shown.length} of ${families.length})`, (_e, cx) => { this.limit += 40; cx.notify(); }))))))
      .child(h_flex().gap(12).items_center()
        .child(div().flex_1().min_w(0).text_size(12).text_color(t.muted).child(this.message))
        .when(Boolean(this.error), el => el.child(this.button("appearance-retry", "Retry", (_e, cx) => this.persist(this.save.state().unsaved, cx)))));
  }
}
