/* Incorporato dall'export HTML: nessuna libreria o richiesta di rete. */
(() => {
  "use strict";
  const source = JSON.parse(document.getElementById("glossary-data").textContent);
  const catalog = source.voci;
  const related = source.collegati;
  const overview = document.getElementById("roadmap-view");
  const index = document.getElementById("glossary-view");
  const detail = document.getElementById("reference-view");
  const search = document.getElementById("glossary-search");
  const list = document.getElementById("glossary-list");
  let overviewScroll = 0;
  let currentView = "roadmap";

  const href = code => "#ref=" + encodeURIComponent(code);
  const kind = code => {
    if (/^A\.[5-8]\.\d+$/.test(code)) return "Controllo Annex A · ISO/IEC 27001:2022";
    if (/^(?:\d+(?:\.\d+)*|4-10)$/.test(code)) return "Clausola · ISO/IEC 27001:2022";
    if (/^#\d+$/.test(code)) return "Rilievo del progetto";
    if (/^ISO-\d+$/.test(code)) return "Intervento della roadmap";
    if (/^R\d/.test(code)) return "Intervento di robustezza";
    if (/^M\d/.test(code)) return "Micro-step della roadmap di rete";
    if (/^ADR-/.test(code)) return "Decisione di progetto";
    if (/^FW-/.test(code)) return "Rilievo sul firewall";
    return "Sigla e riferimento";
  };

  function makeLink(code, title) {
    const a = document.createElement("a");
    a.href = href(code);
    a.textContent = title || code;
    return a;
  }

  function show(view) {
    if (currentView === "roadmap" && view !== "roadmap") overviewScroll = window.scrollY;
    overview.hidden = view !== "roadmap";
    index.hidden = view !== "index";
    detail.hidden = view !== "detail";
    currentView = view;
  }

  function filterIndex() {
    const query = search.value.trim().toLocaleLowerCase("it");
    list.replaceChildren();
    for (const code of Object.keys(catalog).sort((a, b) => a.localeCompare(b, "it", { numeric: true }))) {
      const item = catalog[code];
      if (query && !(code + " " + item.titolo + " " + item.spiegazione).toLocaleLowerCase("it").includes(query)) continue;
      const li = document.createElement("li");
      const link = makeLink(code, code + " · " + item.titolo);
      const label = document.createElement("small");
      label.textContent = kind(code);
      li.append(link, label);
      list.append(li);
    }
    if (!list.children.length) {
      const li = document.createElement("li");
      li.textContent = "Nessuna sigla trovata.";
      list.append(li);
    }
  }

  function showReference(code) {
    const item = catalog[code];
    if (!item) return false;
    document.getElementById("reference-kind").textContent = kind(code);
    document.getElementById("reference-title").textContent = item.titolo;
    document.getElementById("reference-code").textContent = code;
    document.getElementById("reference-description").textContent = item.spiegazione;
    const linked = document.getElementById("reference-related");
    linked.replaceChildren();
    const ids = related[code] || [];
    if (ids.length) {
      const heading = document.createElement("h2");
      heading.textContent = "Interventi collegati";
      linked.append(heading);
      const group = document.createElement("div");
      group.className = "related-links";
      for (const id of ids) {
        const a = document.createElement("a");
        a.href = "#intervento=" + encodeURIComponent(id);
        a.textContent = id + " · " + catalog[id].titolo;
        group.append(a);
      }
      linked.append(group);
    }
    const sourceNote = document.getElementById("reference-source");
    sourceNote.replaceChildren();
    if (code.startsWith("A.") || code.startsWith("ISO/IEC ") || /^(?:\d+(?:\.\d+)*|4-10)$/.test(code)) {
      sourceNote.append("Sintesi parafrasata per consultazione rapida. Riferimento: ");
      const a = document.createElement("a");
      a.href = code.includes("Amd 1:2024") ? "https://www.iso.org/standard/88435.html" : "https://www.iso.org/standard/27001";
      a.target = "_blank";
      a.rel = "noopener noreferrer";
      a.textContent = "ISO/IEC 27001:2022";
      sourceNote.append(a, ". Il testo ufficiale della norma resta la fonte per le verifiche formali.");
    } else if (code.startsWith("#") || /^R\d/.test(code) || /^M\d/.test(code) || code.startsWith("FW-") || code.startsWith("ADR-")) {
      sourceNote.textContent = "Sintesi del registro di progetto alla data dell'esportazione. Le verifiche e lo stato di chiusura restano nelle schede degli interventi.";
    } else {
      sourceNote.textContent = "Spiegazione rapida incorporata nell'export.";
    }
    show("detail");
    window.scrollTo(0, 0);
    return true;
  }

  function route() {
    const hash = location.hash;
    if (hash.startsWith("#ref=")) {
      let code;
      try { code = decodeURIComponent(hash.slice(5)); } catch { code = ""; }
      if (showReference(code)) return;
    }
    if (hash === "#glossario") {
      show("index");
      filterIndex();
      window.scrollTo(0, 0);
      return;
    }
    if (hash.startsWith("#intervento=")) {
      let id;
      try { id = decodeURIComponent(hash.slice(12)); } catch { id = ""; }
      const card = document.getElementById("intervento-" + id);
      if (card) {
        show("roadmap");
        document.querySelector("[data-filter='tutti']").click();
        card.scrollIntoView({ block: "start" });
        card.focus({ preventScroll: true });
        return;
      }
    }
    show("roadmap");
    if (hash === "#roadmap") window.scrollTo(0, overviewScroll);
  }

  document.querySelectorAll("[data-filter]").forEach(button => button.addEventListener("click", () => {
    document.querySelectorAll("[data-filter]").forEach(other => other.classList.remove("active"));
    button.classList.add("active");
    const filter = button.dataset.filter;
    document.querySelectorAll(".card").forEach(card => card.classList.toggle("hidden",
      filter === "forniture" ? card.dataset.supply === "nessuna" :
      filter === "aperti" ? card.dataset.status === "completato" || card.dataset.status === "non_applicabile" : false));
    document.querySelectorAll(".phase").forEach(phase => phase.classList.toggle("hidden", !phase.querySelector(".card:not(.hidden)")));
  }));
  search.addEventListener("input", filterIndex);
  window.addEventListener("hashchange", route);
  route();
})();
