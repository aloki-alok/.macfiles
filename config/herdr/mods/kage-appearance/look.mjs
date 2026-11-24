export const LIMITS = {
  font_size: [8, 48, 0.5],
  font_weight: [100, 900, 100],
  terminal_line_height: [0.8, 2, 0.05],
  terminal_cell_width: [0.8, 2, 0.05],
  terminal_scroll_speed: [0.1, 5, 0.1],
  zoom: [0.5, 3, 0.1],
};

const LOOK_KEYS = [...Object.keys(LIMITS), "font", "ui_font", "font_ligatures", "theme"];

export function activeTheme(settings) {
  return String((settings.dark ? settings.theme_dark : settings.theme_light) ?? settings.theme ?? "kage-night");
}

export function lookWriter(io) {
  let previous = Promise.resolve();
  let pending = 0;
  const unsaved = {};
  const failures = {};
  const revisions = {};
  let revision = 0;
  const save = patch => {
    const current = ++revision;
    for (const key of Object.keys(patch)) revisions[key] = current;
    Object.assign(unsaved, patch);
    pending++;
    const saving = previous.catch(() => {}).then(async () => {
      try {
        await saveLook(io, patch);
        for (const [key, value] of Object.entries(patch)) {
          if (revisions[key] === current) { delete unsaved[key]; delete failures[key]; delete revisions[key]; }
        }
      } catch (error) {
        for (const [key, value] of Object.entries(patch)) {
          if (revisions[key] === current) failures[key] = String(error?.message ?? error);
        }
        throw error;
      } finally {
        pending--;
      }
    });
    previous = saving;
    return saving;
  };
  save.state = () => ({ pending, unsaved: { ...unsaved }, error: Object.values(failures)[0] ?? null });
  return save;
}

export async function saveLook(io, look) {
  const patch = Object.fromEntries(LOOK_KEYS.filter(key => key in look).map(key => [key, look[key]]));
  for (const [key, [min, max]] of Object.entries(LIMITS)) {
    if (key in patch && (!Number.isFinite(patch[key]) || patch[key] < min || patch[key] > max)) {
      throw new Error(`${key} must be between ${min} and ${max}`);
    }
  }
  let failure;
  for (let attempt = 0; attempt < 3; attempt++) {
    const raw = await io.read();
    const person = JSON.parse(raw ?? "{}");
    if (!person || typeof person !== "object" || Array.isArray(person)) throw new Error("Settings must be an object");
    const next = JSON.stringify({ ...person, ...patch }, null, 2) + "\n";
    try {
      await io.write(next, raw);
      return;
    } catch (error) {
      failure = error;
    }
  }
  throw failure;
}
