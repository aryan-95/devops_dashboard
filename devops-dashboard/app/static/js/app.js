async function fetchJSON(url) {
  try {
    const res = await fetch(url, { cache: "no-store" });
    return await res.json();
  } catch (err) {
    return null;
  }
}

function setText(id, text, good) {
  const el = document.getElementById(id);
  if (!el) return;
  el.textContent = text;
  el.classList.remove("status-good", "status-bad");
  if (good === true) el.classList.add("status-good");
  if (good === false) el.classList.add("status-bad");
}

async function refreshDashboard() {
  const [health, status, server, db, version] = await Promise.all([
    fetchJSON("/health"),
    fetchJSON("/api/status"),
    fetchJSON("/api/server"),
    fetchJSON("/api/database"),
    fetchJSON("/api/version"),
  ]);

  setText("health-status", health ? health.status.toUpperCase() : "UNREACHABLE", !!health);
  setText("app-status", status ? status.status : "UNKNOWN", !!status);
  setText("instance-id", server ? server.instance_id : "unknown", null);
  setText("instance-az", server ? server.availability_zone : "unknown", null);
  setText("db-status", db ? db.database : "UNKNOWN", db ? db.database === "CONNECTED" : false);
  setText("app-version", version ? version.version : "-", null);
  setText("last-deployed", version ? version.last_deployed_at : "-", null);
}

refreshDashboard();
setInterval(refreshDashboard, 10000);
