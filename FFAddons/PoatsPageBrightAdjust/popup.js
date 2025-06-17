document.addEventListener("DOMContentLoaded", async () => {
  const toggle = document.getElementById("toggle");
  const slider = document.getElementById("slider");
  const sliderValue = document.getElementById("sliderValue");

  const [tab] = await browser.tabs.query({ active: true, currentWindow: true });
  const hostname = new URL(tab.url).hostname;

  const ENABLE_KEY = `${hostname}_enabled`;
  const LEVEL_KEY = `${hostname}_level`;

  const stored = await browser.storage.sync.get([ENABLE_KEY, LEVEL_KEY]);
  const enabled = stored[ENABLE_KEY] ?? false;
  const level = stored[LEVEL_KEY] ?? 100;

  toggle.checked = enabled;
  slider.value = level;
  sliderValue.textContent = `${level}%`;

  /* if (enabled) {
    await updateOverlay(tab.id, level);
  } */

  toggle.addEventListener("change", async () => {
    const enabledNow = toggle.checked;
    await browser.storage.sync.set({ [ENABLE_KEY]: enabledNow });

    if (!enabledNow) {
      await updateOverlay(tab.id, null); // remove
    } else {
      const levelNow = parseInt(slider.value, 10);
      await updateOverlay(tab.id, levelNow);
    }
  });

  let debounceTimer;

  slider.addEventListener("input", () => {
    // Get the current slider value and update UI immediately:
    const levelNow = parseInt(slider.value, 10);
    sliderValue.textContent = `${levelNow}%`;

    // Cancel any pending update calls:
    clearTimeout(debounceTimer);

    // Schedule a new update to run 100ms later:
    debounceTimer = setTimeout(async () => {
      // Save value in storage:
      await browser.storage.sync.set({ [LEVEL_KEY]: levelNow });
    
      // If toggle is on, update the brightness overlay:
      if (toggle.checked) {
        await updateOverlay(tab.id, levelNow);
      }
    }, 100); // 100 ms delay after last input event before running
  });
});

async function updateOverlay(tabId, level) {
  await browser.tabs.sendMessage(tabId, {
    type: "update-brightness",
    level: level
  });
}
