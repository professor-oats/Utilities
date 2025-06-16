console.log("[Brightness Cover] content.js loaded!");

let cover = null;

function applyBrightness(level) {
  if (level === null) {
    if (cover) {
      cover.remove();
      cover = null;
    }
    return;
  }

  const val = level.toFixed(1);
  const color = `rgb(${val}%, ${val}%, ${val}%)`;

  if (!cover) {
    cover = document.createElement("div");
    cover.id = "brightness-cover";
    Object.assign(cover.style, {
      position: "fixed",
      pointerEvents: "none",
      top: "0",
      left: "0",
      width: "100vw",
      height: "100vh",
      mixBlendMode: "multiply",
      zIndex: "999999",
      backgroundColor: color
    });
    document.body.appendChild(cover);
  } else {
    cover.style.backgroundColor = color;
  }
}

browser.runtime.onMessage.addListener((message) => {
  if (message.type === "update-brightness") {
    applyBrightness(message.level);
  }
});
