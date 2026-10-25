/* Click-to-magnify for content images and Mermaid diagrams.
 * Opens a fullscreen viewer with wheel/pinch zoom, drag to pan,
 * double-click to reset, and Esc / backdrop click to close. */
(function () {
  const MIN = 0.5;
  const MAX = 8;
  const STEP = 1.2;

  let overlay, stage, scale, x, y;
  const pointers = new Map();
  let pinch = null;

  function build() {
    overlay = document.createElement("div");
    overlay.className = "zoom-overlay";
    overlay.setAttribute("role", "dialog");
    overlay.setAttribute("aria-modal", "true");
    overlay.innerHTML =
      '<div class="zoom-toolbar">' +
      '<button type="button" data-zoom="in" title="Zoom in" aria-label="Zoom in">+</button>' +
      '<button type="button" data-zoom="out" title="Zoom out" aria-label="Zoom out">&minus;</button>' +
      '<button type="button" data-zoom="reset" title="Reset" aria-label="Reset zoom">1:1</button>' +
      '<button type="button" data-zoom="close" title="Close (Esc)" aria-label="Close">&times;</button>' +
      "</div>" +
      '<div class="zoom-stage"></div>';
    stage = overlay.querySelector(".zoom-stage");
    document.body.appendChild(overlay);

    overlay.addEventListener("click", (e) => {
      const action = e.target.closest("[data-zoom]")?.dataset.zoom;
      if (action === "in") zoomAt(STEP);
      else if (action === "out") zoomAt(1 / STEP);
      else if (action === "reset") reset();
      else if (action === "close" || e.target === overlay) close();
    });
    overlay.addEventListener("wheel", (e) => {
      e.preventDefault();
      zoomAt(e.deltaY < 0 ? STEP : 1 / STEP, e.clientX, e.clientY);
    }, { passive: false });
    overlay.addEventListener("dblclick", (e) => {
      if (!e.target.closest(".zoom-toolbar")) reset();
    });

    overlay.addEventListener("pointerdown", (e) => {
      if (e.target.closest(".zoom-toolbar") || e.target === overlay) return;
      overlay.setPointerCapture(e.pointerId);
      pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
      if (pointers.size === 2) pinch = pinchState();
    });
    overlay.addEventListener("pointermove", (e) => {
      const prev = pointers.get(e.pointerId);
      if (!prev) return;
      pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
      if (pointers.size === 2 && pinch) {
        const next = pinchState();
        zoomAt(next.dist / pinch.dist, next.cx, next.cy);
        pinch = next;
      } else if (pointers.size === 1) {
        x += e.clientX - prev.x;
        y += e.clientY - prev.y;
        apply();
      }
    });
    const release = (e) => {
      pointers.delete(e.pointerId);
      if (pointers.size < 2) pinch = null;
    };
    overlay.addEventListener("pointerup", release);
    overlay.addEventListener("pointercancel", release);

    document.addEventListener("keydown", (e) => {
      if (!overlay.classList.contains("is-open")) return;
      if (e.key === "Escape") close();
      else if (e.key === "+" || e.key === "=") zoomAt(STEP);
      else if (e.key === "-") zoomAt(1 / STEP);
      else if (e.key === "0") reset();
    });
  }

  function pinchState() {
    const [a, b] = [...pointers.values()];
    return {
      dist: Math.hypot(a.x - b.x, a.y - b.y) || 1,
      cx: (a.x + b.x) / 2,
      cy: (a.y + b.y) / 2,
    };
  }

  function apply() {
    stage.style.transform = `translate(${x}px, ${y}px) scale(${scale})`;
  }

  function reset() {
    scale = 1;
    x = 0;
    y = 0;
    apply();
  }

  // Zoom by `factor`, keeping the point (cx, cy) fixed on screen
  function zoomAt(factor, cx = innerWidth / 2, cy = innerHeight / 2) {
    const next = Math.min(MAX, Math.max(MIN, scale * factor));
    const k = next / scale;
    const ox = innerWidth / 2 + x;
    const oy = innerHeight / 2 + y;
    x += (cx - ox) * (1 - k);
    y += (cy - oy) * (1 - k);
    scale = next;
    apply();
  }

  function open(content) {
    if (!overlay) build();
    stage.replaceChildren(content);
    reset();
    overlay.classList.add("is-open");
    document.documentElement.classList.add("zoom-locked");
    overlay.querySelector('[data-zoom="close"]').focus({ preventScroll: true });
  }

  function close() {
    overlay.classList.remove("is-open");
    document.documentElement.classList.remove("zoom-locked");
    stage.replaceChildren();
  }

  function contentFor(target) {
    const diagram = target.closest(".md-typeset div.mermaid");
    if (diagram?.shadowRoot) {
      const svg = diagram.shadowRoot.querySelector("svg");
      if (!svg) return null;
      const clone = svg.cloneNode(true);
      const box = svg.getBoundingClientRect();
      clone.removeAttribute("style");
      clone.setAttribute("width", box.width);
      clone.setAttribute("height", box.height);
      // Render inside a shadow root so Mermaid's scoped styles stay isolated
      const host = document.createElement("div");
      host.className = "zoom-diagram";
      host.attachShadow({ mode: "open" }).appendChild(clone);
      return { node: host, w: box.width, h: box.height };
    }
    const img = target.closest(".md-typeset img");
    if (img && !img.closest("a, .twemoji, .emojione, .gemoji") && !img.classList.contains("no-zoom")) {
      const clone = new Image();
      clone.src = img.currentSrc || img.src;
      clone.alt = img.alt;
      return {
        node: clone,
        w: img.naturalWidth || img.width,
        h: img.naturalHeight || img.height,
      };
    }
    return null;
  }

  document.addEventListener("click", (e) => {
    if (overlay?.contains(e.target)) return;
    const content = contentFor(e.target);
    if (!content) return;
    e.preventDefault();
    // Fit to viewport, upscaling small diagrams so they're actually larger
    const fit = Math.min(
      (innerWidth * 0.9) / content.w,
      (innerHeight * 0.85) / content.h,
      content.node.tagName === "IMG" ? 1 : 3
    );
    content.node.style.width = `${content.w * fit}px`;
    content.node.style.height = `${content.h * fit}px`;
    const svg = content.node.shadowRoot?.querySelector("svg");
    if (svg) {
      svg.setAttribute("width", "100%");
      svg.setAttribute("height", "100%");
    }
    open(content.node);
  });
})();
