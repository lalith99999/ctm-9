<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String username = (String) session.getAttribute("username");
  String role = (String) session.getAttribute("role");
  if (username == null || role == null || !"admin".equalsIgnoreCase(role)) {
      response.sendRedirect("index.jsp"); return;
  }
  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<style>
/* === THEME VARIABLES === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.95);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --danger: #ef4444;
  --success: #22c55e;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 12px;
  --shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
  --font: "Poppins", "Segoe UI", sans-serif;
}

/* === BASE === */
body {
  margin: 0;
  font-family: var(--font);
  background: var(--bg-main);
  color: var(--text);
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* === TOP NAV BAR === */
.top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(15, 23, 42, 0.95);
  padding: 16px 24px;
  border-bottom: 2px solid var(--accent);
  box-shadow: var(--shadow);
}
.brand {
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--accent);
}
.logout {
  background: var(--accent);
  color: white;
  margin-left: 10px;
  text-decoration: none;
  padding: 8px 14px;
  border-radius: var(--radius);
  font-weight: 600;
  transition: 0.3s;
}
.logout:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}

/* === MAIN WRAPPER === */
.wrap {
  width: 90%;
  max-width: 1100px;
  margin: 50px auto;
  background: var(--card-bg);
  padding: 40px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  text-align: center;
}

/* === PANEL HEADER === */
.panel h2 {
  color: var(--accent-hover);
  font-size: 1.6rem;
  font-weight: 700;
  margin-bottom: 25px;
}

/* === DASHBOARD GRID === */
.actions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 25px;
  justify-items: center;
  margin-top: 20px;
}

/* === ACTION CARDS === */
.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(30, 41, 59, 0.9);
  color: var(--text);
  text-decoration: none;
  font-weight: 600;
  font-size: 1.05rem;
  padding: 30px 20px;
  width: 100%;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  transition: all 0.3s ease;
  border: 1px solid rgba(59,130,246,0.3);
}
.action-btn:hover {
  background: rgba(59,130,246,0.15);
  border-color: var(--accent);
  transform: translateY(-3px);
  box-shadow: 0 0 20px rgba(59,130,246,0.5);
  color: var(--accent-hover);
}

/* === ICON AND TEXT === */
.action-btn::before {
  content: attr(data-icon);
  font-size: 1.6rem;
  margin-right: 10px;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .wrap {
    padding: 25px;
  }
  .actions {
    grid-template-columns: 1fr 1fr;
  }
  .action-btn {
    font-size: 0.95rem;
    padding: 20px;
  }
}

/* === FOOTER-LIKE SPACING === */
body::after {
  content: "";
  display: block;
  height: 40px;
}
</style>
<script>
window.history.replaceState && window.history.replaceState(null, "", window.location.href);
window.onpopstate = function(){ window.location.replace('adminmain.jsp'); };
</script>
</head>
<body class="admin-panel">
<div class="top">
  <div class="brand">🛠️ Admin Panel — Welcome <b><%= username %></b></div>
  <div><a class="logout" href="adminmain.jsp">Home</a> <a class="logout" href="logout">Logout</a></div>
</div>

<div class="wrap">
  <div class="panel">
    <h2>Dashboard</h2>
    <div class="actions">
      <a class="action-btn" href="admteams">📋 Manage Teams</a>
      <a class="action-btn" href="admtournaments">🏆 Manage Tournaments</a>
      <a class="action-btn" href="enroll">➕ Enroll Teams</a>
      <a class="action-btn" href="fixturesgen">📅 Generate Fixtures</a>
      <a class="action-btn" href="startmatch">🎯 Start Match</a>
      <a class="action-btn" href="updateinnings">📝 Update Innings</a>
    </div>
  </div>
</div>
</body>
</html>
