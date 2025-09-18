const domainSettings = {};
const lastAppliedBrightness = {};

browser.storage.sync.get(null).then(items => {
  for (const [key, value] of Object.entries(items)) {
    domainSettings[key] = value;
  }
});

// Keep storage in sync
browser.storage.onChanged.addListener((changes, area) => {
  if (area === "sync") {
    for (const [key, { newValue }] of Object.entries(changes)) {
      domainSettings[key] = newValue;
    }
  }
});

browser.tabs.onActivated.addListener(async ({ tabId }) => {
  try {
    const tab = await browser.tabs.get(tabId);
    if (!tab.url.startsWith("http")) return;

    const hostname = new URL(tab.url).hostname;
    const enabled = domainSettings[`${hostname}_enabled`];
    const level = enabled ? domainSettings[`${hostname}_level`] : null;

    // Only send message if level changed for this tab
    if (lastAppliedBrightness[tabId] !== level) {
      lastAppliedBrightness[tabId] = level;
      browser.tabs.sendMessage(tabId, {
        type: "update-brightness",
        level: level
      });
    }
  } catch (err) {
    console.warn("Brightness update skipped:", err);
  }
});
