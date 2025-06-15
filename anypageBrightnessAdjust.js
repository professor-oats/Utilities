// JS code for making a cover div element that uses the mix-blend-mode to color blend with the other elements
// Looked for a minimalistic approach of reading docs online where usual extensions in Firefox wouldn't work
// Just feed the code with the wanted value on background-color into dev console and have the div color blend

var cover = document.createElement("div");
let css = `
    position: fixed;
    pointer-events: none;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgb(70.0%, 70.0%, 70.0%);
    mix-blend-mode: multiply;
    z-index: 1;
`
cover.setAttribute("style", css);
document.body.appendChild(cover);

// For follow up adjustments, simply set another value to the background-color attribute:
// cover.style.backgroundColor = "rgb(65.0%, 65.0%, 65.0%)";

// And there you go. A custom minimal xgamma for your Web Browser without any extensions harvesting your user data
// Basically you can build any visual theme and functions you'd like.
// MDN Web Docs
// https://developer.mozilla.org/en-US/docs/Web/CSS/mix-blend-mode
