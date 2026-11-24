import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, settings, layout, run, props, closeOverlay } from "herdr";

const FONTS = [
  { name: "JetBrains Mono", family: "JetBrainsMono Nerd Font Mono", mood: "Open letters and clear punctuation for code." },
  { name: "Maple Mono", family: "Maple Mono NF", mood: "Round and soft, with a little bounce." },
  { name: "Departure Mono", family: "DepartureMono Nerd Font Mono", mood: "Pixel arcade with sharp square shapes." },
  { name: "Cascadia Mono", family: "Cascadia Mono NF", mood: "Wide, friendly curves with a sturdy rhythm." },
  { name: "Geist Mono", family: "Geist Mono", mood: "Clean, quiet letters with generous breathing room." },
  { name: "Commit Mono", family: "CommitMono Nerd Font Mono", mood: "Even spacing and simple geometric shapes." },
  { name: "Monaspace Krypton", family: "Monaspace Krypton NF", mood: "Angular letters from a sci-fi control room." },
  { name: "0xProto", family: "0xProto Nerd Font Mono", mood: "Geometric, open shapes and a slashed zero." },
  { name: "Hack", family: "Hack Nerd Font Mono", mood: "Classic terminal lettering, clear at small sizes." },
  { name: "Victor Mono", family: "VictorMono Nerd Font Mono", mood: "Tall, airy letters with a light touch." },
  { name: "Recursive Casual", family: "Rec Mono Casual", mood: "Playful shapes without the cursive slant." },
  { name: "Recursive Linear", family: "Rec Mono Linear", mood: "Straight strokes and a compact, orderly feel." },
  { name: "IBM Plex Mono", family: "IBM Plex Mono", mood: "A typewriter with a technical streak." },
  { name: "Anthrosevka", family: "Anthrosevka Mono", mood: "Tall, narrow letters with lots of room for code." },
];

export default class FontWardrobe extends View {
  init() {
    this.size = Number(settings().font_size ?? 16.5);
  }

  choose(font) {
    run("layout.set", { layout: { ...layout(), font: font.family, font_size: this.size } });
    closeOverlay(props().overlay);
  }

  card(font, current, t) {
    const selected = current === font.family;
    return v_flex().id(`font-${font.name}`).flex_1().min_w(0).p(14).gap(7)
      .rounded(12).border_1().border_color(selected ? t.accent : t.border)
      .bg(t.background).cursor_pointer().hover((s) => s.border_color(t.accent))
      .on_click(() => this.choose(font))
      .child(h_flex().items_center().justify_between().gap(12)
        .child(div().text_size(14).font_semibold().text_color(t.foreground).child(font.name))
        .child(div().text_size(11).text_color(selected ? t.accent : t.dim).child(selected ? "On your terminal" : "Try this")))
      .child(div().text_size(11.5).text_color(t.muted).child(font.mood))
      .child(v_flex().gap(3).pt(5).font_family(font.family).font_normal().text_size(this.size)
        .child(div().text_color(t.foreground).child("hello, Ryu."))
        .child(div().text_color(t.accent).child('let mood = "cozy";'))
        .child(div().text_color(t.ansi6).child("0O 1Il {[]} ~/cat")));
  }

  render(cx) {
    const t = theme();
    const current = String(settings().font ?? settings().font_family ?? "DepartureMono Nerd Font Mono");
    const rows = Array.from({ length: Math.ceil(FONTS.length / 2) }, (_, row) => row * 2).map(i => h_flex().gap(12).items_stretch()
      .children(FONTS.slice(i, i + 2).map(font => this.card(font, current, t))));
    return v_flex().size_full().min_h(0).p(22).gap(14).bg(t.popover)
      .child(h_flex().items_center().gap(10)
        .child(svg("mods/kawaii-bar/cat.svg").size(24).text_color(t.accent))
        .child(v_flex().flex_1().gap(3)
          .child(div().text_size(21).font_semibold().text_color(t.foreground).child("Font wardrobe"))
          .child(div().text_size(12).text_color(t.muted).child("Same pink theme. Click a card to wear it in your terminal.")))
        .child(div().id("font-close").px(10).py(6).rounded(7).cursor_pointer()
          .text_size(12).text_color(t.muted).hover(s => s.bg(t.hover))
          .on_click(() => closeOverlay(props().overlay)).child("Close")))
      .child(h_flex().items_center().gap(8)
        .child(div().text_size(12).text_color(t.muted).child("Try a size"))
        .children([14, 16.5, 18].map(size => div().id(`font-size-${size}`)
          .px(10).py(5).rounded(7).border_1().border_color(this.size === size ? t.accent : t.border)
          .text_size(12).text_color(this.size === size ? t.accent : t.muted).cursor_pointer()
          .on_click((_e, cx) => { this.size = size; cx.notify(); }).child(String(size)))))
      .child(v_flex().id("font-options").flex_1().min_h(0).overflow_y_scrollbar().gap(12).children(rows))
      .child(div().text_size(11.5).text_color(t.dim).child("Open Fonts in the top bar to compare again. Everything stays local."));
  }
}
