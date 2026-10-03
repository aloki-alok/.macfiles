// Minimal black Firefox setup for this profile.

// Load userChrome.css and userContent.css.
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Compact browser chrome and dark built-in pages.
user_pref("browser.uidensity", 1);
user_pref("browser.compactmode.show", true);
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("browser.theme.content-theme", 0);
user_pref("browser.theme.toolbar-theme", 0);

// Anthropic fonts as defaults, a bit larger. Minimum size also lifts sites that hard-code tiny px text.
user_pref("font.name.sans-serif.x-western", "Anthropic Sans Web");
user_pref("font.name.serif.x-western", "Anthropic Sans Web");
user_pref("font.name.monospace.x-western", "AnthropicMonoWeb Nerd Font");
user_pref("font.size.variable.x-western", 18);
user_pref("font.size.monospace.x-western", 15);
user_pref("font.minimum-size.x-western", 13);

// Force every page to black with white text (Settings > Colors > Override: Always).
// The .dark variants apply while Firefox is in dark mode, so set both.
user_pref("browser.display.document_color_use", 2);
user_pref("browser.display.background_color", "#000000");
user_pref("browser.display.background_color.dark", "#000000");
user_pref("browser.display.foreground_color", "#FFFFFF");
user_pref("browser.display.foreground_color.dark", "#FFFFFF");
user_pref("browser.anchor_color", "#D0D0D0");
user_pref("browser.anchor_color.dark", "#D0D0D0");
user_pref("browser.visited_color", "#9A9A9A");
user_pref("browser.visited_color.dark", "#9A9A9A");
// Puts a black plate behind text that sits on images, so it stays readable.
user_pref("browser.display.permit_backplate", true);

// Keep new tabs blank and remove background content.
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "chrome://browser/content/blanktab.html");
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Avoid background prediction and unused AI features.
user_pref("network.prefetch-next", false);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);
user_pref("network.http.speculative-parallel-limit", 0);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.ml.chat.page", false);
user_pref("browser.ml.chat.sidebar", false);
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);

// Let Firefox unload inactive tabs sooner when macOS reports memory pressure.
// Process isolation stays at Mozilla's defaults for security and responsiveness.
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.tabs.min_inactive_duration_before_unload", 300000);
