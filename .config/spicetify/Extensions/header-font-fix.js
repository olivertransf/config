(function HeaderFontFix() {
  const css = `
:root {
  --font-family-header: "JetBrains Mono", monospace !important;
  --font-size-multiplier-header: 2 !important;
}
.main-entityHeader-title h1,
.main-entityHeader-title span {
  font-family: "JetBrains Mono", monospace !important;
}
`;

  function inject() {
    let style = document.getElementById("header-font-fix");
    if (!style) {
      style = document.createElement("style");
      style.id = "header-font-fix";
      document.documentElement.appendChild(style);
    }
    style.textContent = css;
  }

  inject();
  // Marketplace injects theme CSS after load; re-apply so we win.
  setTimeout(inject, 500);
  setTimeout(inject, 2000);
})();
