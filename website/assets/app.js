/* floatfin — website behavior
   Fetch the latest successful "Build Live ISOs" workflow artifact from the
   GitHub Actions API and power the download card with it, plus recent commits.
   No secrets, no frameworks; all text goes in via textContent.

   If the repository is private the unauthenticated API won't answer — the
   page then gracefully falls back to linking the CI runs page, or to an
   optional hand-maintained latest-iso.json placed next to this page:
     { "name": "...", "url": "...", "size": 123456, "built": "2026-09-21T00:00:00Z", "expires": "2026-09-28T00:00:00Z" }
   */

(function () {
  "use strict";

  var REPO = "floatingskies/floatfin";
  var API = "https://api.github.com/repos/" + REPO;
  var ISO_WORKFLOW = "build-iso.yml";

  function $id(id) { return document.getElementById(id); }
  function $(sel) { return document.querySelector(sel); }

  function fetchJSON(url) {
    return fetch(url, { headers: { Accept: "application/vnd.github+json" } }).then(function (res) {
      if (!res.ok) {
        var err = new Error("HTTP " + res.status);
        err.status = res.status;
        return err;
      }
      return res.json();
    });
  }

  function fmtBytes(n) {
    if (n == null) return "";
    var u = ["B", "KB", "MB", "GB"];
    var i = 0;
    while (n >= 1024 && i < u.length - 1) { n /= 1024; i++; }
    return (i === 0 ? n : n.toFixed(1)) + " " + u[i];
  }

  function fmtDate(iso) {
    if (!iso) return "";
    var d = new Date(iso);
    if (isNaN(d)) return "";
    return d.toLocaleString(undefined, { year: "numeric", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" });
  }

  function fmtLifetime(iso) {
    if (!iso) return "";
    var d = new Date(iso);
    var days = Math.ceil((d - Date.now()) / 86400000);
    if (days < 1) return "expiring today";
    return "expires in " + days + " day" + (days === 1 ? "" : "s");
  }

  /* --- Download card ---------------------------------------------------- */

  function render(card, title, meta, downloadData) {
    var titleEl = $id("iso-title");
    var metaEl = $id("iso-meta");
    var dl = $id("iso-download");
    var runs = $id("iso-runs");

    card.classList.remove("error");
    titleEl.textContent = title;
    if (meta) {
      metaEl.textContent = meta;
      metaEl.removeAttribute("hidden");
    } else {
      metaEl.setAttribute("hidden", "");
    }
    if (downloadData && downloadData.href) {
      dl.href = downloadData.href;
      dl.removeAttribute("hidden");
    } else {
      dl.removeAttribute("href");
      dl.setAttribute("hidden", "");
    }
    if (downloadData && downloadData.runsHref) {
      runs.href = downloadData.runsHref;
      runs.removeAttribute("hidden");
    } else {
      runs.setAttribute("hidden", "");
    }
  }

  function renderError(message, runsHref) {
    var card = $id("iso-card");
    card.classList.add("error");
    render(card, message, null, { runsHref: runsHref });
  }

  // Optional hand-maintained override beats the live query when it exists.
  function tryOverride() {
    return fetch("latest-iso.json", { cache: "no-store" }).then(function (res) {
      if (!res.ok) { throw new Error("no override"); }
      return res.json();
    }).then(function (data) {
      if (!data || !data.url) { throw new Error("empty override"); }
      var card = $id("iso-card");
      render(
        card,
        data.name || "Floatfin live ISO",
        (data.built ? "built " + fmtDate(data.built) + " · " : "") + fmtBytes(data.size) + (data.expires ? " · " + fmtLifetime(data.expires) : ""),
        { href: data.url, runsHref: API + "/actions/workflows/" + ISO_WORKFLOW + "/runs" }
      );
      return true;
    }).catch(function () { return false; });
  }

  function liveFetch() {
    return fetchJSON(API + "/actions/workflows/" + ISO_WORKFLOW + "/runs?status=success&per_page=1&exclude_pull_requests=true")
      .then(function (runData) {
        if (runData instanceof Error) { throw runData; }
        if (!runData.total_count || !runData.workflow_runs || !runData.workflow_runs.length) {
          throw new Error("no successful runs yet");
        }
        var run = runData.workflow_runs[0];
        return fetchJSON(API + "/actions/runs/" + run.id + "/artifacts?per_page=10").then(function (artData) {
          if (artData instanceof Error) { throw artData; }
          var arts = (artData.artifacts || []).filter(function (a) { return !a.expired && !a.deleted; })
            .sort(function (a, b) { return new Date(b.created_at) - new Date(a.created_at); });
          if (!arts.length) { throw new Error("no unexpired artifacts"); }
          var card = $id("iso-card");
          render(
            card,
            "Latest build: " + arts[0].name,
            "run #" + run.run_number + " · built " + fmtDate(arts[0].created_at) + " · " + fmtBytes(arts[0].size_in_bytes) + " · " + fmtLifetime(arts[0].expires_at),
            { href: arts[0].archive_download_url, runsHref: run.html_url }
          );
          return true;
        });
      })
      .catch(function (err) {
        if (err && err.status === 403) {
          renderError("The GitHub API rate limit is exhausted right now — try again later, or check the CI runs directly.", API + "/actions/workflows/" + ISO_WORKFLOW + "/runs");
        } else if (err && err.status === 404) {
          renderError("The repo is private or the workflow moved — browse the CI runs directly, or run the Build Live ISOs workflow to mint a fresh artifact.", API + "/actions/workflows/" + ISO_WORKFLOW + "/runs");
        } else {
          renderError("No downloadable artifact found yet — run the Build Live ISOs workflow, then download the artifact from its run page.", API + "/actions/workflows/" + ISO_WORKFLOW + "/runs");
        }
        return false;
      });
  }

  function initDownloads() {
    var card = $id("iso-card");
    if (!card) return;
    // Try the hand-maintained file first (works for private repos), then live.
    tryOverride().then(function (used) { if (!used) liveFetch(); });
  }

  /* --- Latest commits --------------------------------------------------- */

  function loadCommits() {
    var list = $id("commits");
    if (!list) return;
    fetchJSON(API + "/commits?sha=main&per_page=6").then(function (data) {
      if (data instanceof Error || !data.length) {
        list.textContent = "Could not load commits right now.";
        return;
      }
      list.textContent = "";
      data.forEach(function (c) {
        var li = document.createElement("li");
        var sha = document.createElement("span");
        sha.className = "commit-sha";
        sha.textContent = c.sha.slice(0, 7);

        var msg = document.createElement("span");
        msg.className = "commit-msg";
        var a = document.createElement("a");
        a.textContent = (c.commit.message.split("\n")[0] || "").trim();
        a.href = c.html_url;
        a.title = "by " + (c.commit.author && c.commit.author.name ? c.commit.author.name : "?");
        msg.appendChild(a);

        li.appendChild(sha);
        li.appendChild(msg);
        list.appendChild(li);
      });
    }).catch(function () {
      list.textContent = "Could not reach GitHub right now.";
    });
  }

  /* --- Reveal on scroll ------------------------------------------------------- */

  function initReveal() {
    var nodes = document.querySelectorAll(".reveal");
    if (!("IntersectionObserver" in window)) {
      nodes.forEach(function (n) { n.classList.add("in"); });
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add("in"); io.unobserve(e.target); }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -40px 0px" });
    nodes.forEach(function (n) { io.observe(n); });
  }

  /* --- Light / dark mode ------------------------------------------------------- */

  function initTheme() {
    var root = document.documentElement;
    var btn = $id("theme-toggle");
    var mq = window.matchMedia("(prefers-color-scheme: light)");
    var chosen = null;
    try { chosen = localStorage.getItem("floatfin-theme"); } catch (e) { /* private mode */ }

    function apply(theme) {
      root.setAttribute("data-theme", theme);
      if (btn) btn.setAttribute("aria-pressed", theme === "light" ? "true" : "false");
    }

    function current() { return root.getAttribute("data-theme") === "light" ? "light" : "dark"; }

    if (chosen) apply(chosen);
    else apply(mq.matches ? "light" : "dark");

    if (btn) {
      btn.addEventListener("click", function () {
        var next = current() === "light" ? "dark" : "light";
        chosen = next;
        apply(next);
        try { localStorage.setItem("floatfin-theme", next); } catch (e) { /* ignore */ }
      });
    }
    if (mq.addEventListener) {
      mq.addEventListener("change", function (ev) {
        if (!chosen) apply(ev.matches ? "light" : "dark");
      });
    }
  }

  initDownloads();
  loadCommits();
  initReveal();
  initTheme();
})();