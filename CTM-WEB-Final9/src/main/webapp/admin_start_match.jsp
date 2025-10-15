<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Tournament" %>

<%
    String role = (String) session.getAttribute("role");
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
    response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
    response.setHeader("Pragma","no-cache");
    response.setDateHeader("Expires",0);

    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
    String mode = (String) request.getAttribute("mode");
    if (mode == null) mode = "tournaments";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Start Match | Admin</title>
<style>
/* === THEME VARIABLES === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.92);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --success: #22c55e;
  --warning: #fbbf24;
  --danger: #ef4444;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 12px;
  --shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
  --font: "Poppins", "Segoe UI", sans-serif;
}

/* === BASE PAGE === */
body {
  margin: 0;
  font-family: var(--font);
  color: var(--text);
  background: var(--bg-main);
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

/* === TOP BAR === */
.top {
  background: rgba(15, 23, 42, 0.95);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  border-bottom: 2px solid var(--accent);
  box-shadow: var(--shadow);
}
.brand {
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--accent);
}
.top a {
  text-decoration: none;
  margin-left: 10px;
  font-weight: 600;
  padding: 8px 12px;
  border-radius: var(--radius);
  transition: 0.3s;
}
.viewer-btn {
  background: var(--accent);
  color: white;
}
.viewer-btn:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}
.danger {
  background: var(--danger);
  color: white;
}
.danger:hover {
  background: #f87171;
  box-shadow: 0 0 8px rgba(239,68,68,0.6);
}

/* === ALERTS / MESSAGES === */
.msg, .err {
  text-align: center;
  padding: 10px 12px;
  border-radius: var(--radius);
  width: 90%;
  max-width: 1000px;
  margin: 20px auto 0 auto;
  font-weight: 600;
}
.msg {
  background: rgba(34,197,94,0.2);
  border-left: 5px solid var(--success);
}
.err {
  background: rgba(239,68,68,0.2);
  border-left: 5px solid var(--danger);
}

/* === MAIN WRAP === */
.wrap {
  width: 90%;
  max-width: 1100px;
  margin: 40px auto;
  background: var(--card-bg);
  padding: 30px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
}

/* === HEADINGS === */
h2 {
  color: var(--accent-hover);
  margin-bottom: 20px;
}

/* === TABLE WRAPPER === */
.table-wrap {
  overflow-x: auto;
  background: rgba(30, 41, 59, 0.9);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: 10px;
}
.table-center {
  margin: 0 auto;
}

/* === TABLE STYLING === */
table {
  width: 100%;
  border-collapse: collapse;
  color: var(--text);
  border-radius: var(--radius);
  overflow: hidden;
}
th, td {
  padding: 12px 10px;
  text-align: center;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}
th {
  background: rgba(30, 58, 138, 0.9);
  color: #f8fafc;
  text-transform: uppercase;
  font-size: 0.9rem;
}
tr:hover {
  background: rgba(37,99,235,0.2);
}
.empty {
  text-align: center;
  color: var(--muted);
  font-style: italic;
  padding: 12px;
}

/* === BUTTONS === */
button, .primary, .secondary {
  border: none;
  border-radius: var(--radius);
  font-weight: 600;
  padding: 8px 14px;
  cursor: pointer;
  transition: 0.3s;
}
.primary {
  background: var(--accent);
  color: white;
}
.primary:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}
.secondary {
  background: rgba(59,130,246,0.15);
  color: var(--accent-hover);
  text-decoration: none;
  display: inline-block;
}
.secondary:hover {
  background: rgba(59,130,246,0.25);
  color: var(--accent);
  box-shadow: 0 0 10px rgba(96,165,250,0.4);
}

/* === SELECT DROPDOWNS === */
select {
  background: rgba(15, 23, 42, 0.85);
  color: var(--text);
  border: 1px solid #334155;
  border-radius: var(--radius);
  padding: 6px 10px;
  font-size: 0.9rem;
  transition: 0.3s;
}
select:focus {
  border-color: var(--accent);
  box-shadow: 0 0 6px var(--accent);
}

/* === FOOTER === */
footer {
  text-align: center;
  color: var(--muted);
  padding: 16px;
  margin-top: auto;
  font-size: 0.9rem;
  background: rgba(15, 23, 42, 0.9);
  border-top: 1px solid rgba(59,130,246,0.3);
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .wrap {
    padding: 20px;
  }
  .top {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  table th, table td {
    font-size: 0.85rem;
    padding: 8px;
  }
}
</style>
</head>
<body class="admin-panel">

<div class="top">
  <div class="brand">🏏 Start Match Panel</div>
  <div>
    <a href="adminmain.jsp" class="viewer-btn">🏠 Home</a>
    <a href="logout" class="danger">🚪 Logout</a>
  </div>
</div>

<% if (msg != null) { %>
  <div class="msg"><%= msg %></div>
<% } if (err != null) { %>
  <div class="err"><%= err %></div>
<% } %>

<div class="wrap">

<%-- ==========================
     1️⃣ LIST ALL TOURNAMENTS
     ========================== --%>
<% if ("tournaments".equals(mode)) {
    List<Tournament> tournaments = (List<Tournament>) request.getAttribute("tournaments");
    Map<Long,Integer> todayCounts = (Map<Long,Integer>) request.getAttribute("todayCounts");
%>
<h2 style="text-align:center;">Select Tournament to Start Matches</h2>
<div class="table-wrap table-center">
<table>
  <thead>
    <tr>
      <th>ID</th>
      <th>Name</th>
      <th>Format</th>
      <th>Today's Matches</th>
      <th>Action</th>
    </tr>
  </thead>
  <tbody>
  <% for (Tournament t : tournaments) { %>
    <tr>
      <td><%= t.getId() %></td>
      <td><%= t.getName() %></td>
      <td><%= t.getFormat() %></td>
      <td><%= todayCounts.getOrDefault(t.getId(), 0) %></td>
      <td>
        <form method="get" action="startmatch">
          <input type="hidden" name="tid" value="<%= t.getId() %>">
          <button class="viewer-btn" type="submit">View Matches</button>
        </form>
      </td>
    </tr>
  <% } %>
  </tbody>
</table>
</div>
<% } %>

<%-- ==========================
     2️⃣  TODAY'S MATCHES + TOSS SELECTION
     ========================== --%>
<% if ("matches".equals(mode)) {
    Tournament t = (Tournament) request.getAttribute("tournament");
    List<Map<String,Object>> matches = (List<Map<String,Object>>) request.getAttribute("matches");
%>
<h2 style="text-align:center;">Today's Matches - <%= t != null ? t.getName() : "Tournament" %></h2>
<div class="table-wrap table-center">
<table>
  <thead>
    <tr>
      <th>Match ID</th>
      <th>Teams</th>
      <th>Venue</th>
      <th>Date</th>
      <th>Toss Winner</th>
      <th>Decision</th>
      <th>Action</th>
    </tr>
  </thead>
  <tbody>
  <% if (matches.isEmpty()) { %>
    <tr><td colspan="7" class="empty">No scheduled matches for today</td></tr>
  <% } else {
       for (Map<String,Object> m : matches) { %>
    <tr>
      <td><%= m.get("id") %></td>
      <td><strong><%= m.get("aName") %></strong> vs <strong><%= m.get("bName") %></strong></td>
      <td><%= m.get("venue") %></td>
      <td><%= m.get("datetime") %></td>
      <td>
        <select name="tossWinnerId" form="form_<%= m.get("id") %>">
          <option value="<%= m.get("aId") %>"><%= m.get("aName") %></option>
          <option value="<%= m.get("bId") %>"><%= m.get("bName") %></option>
        </select>
      </td>
      <td>
        <select name="tossDecision" form="form_<%= m.get("id") %>">
          <option value="BAT">Bat</option>
          <option value="BOWL">Bowl</option>
        </select>
      </td>
      <td>
        <form id="form_<%= m.get("id") %>" method="post" action="startmatch">
          <input type="hidden" name="tid" value="<%= t.getId() %>">
          <input type="hidden" name="matchId" value="<%= m.get("id") %>">
          <button class="primary" type="submit">Start Match</button>
        </form>
      </td>
    </tr>
  <% } } %>
  </tbody>
</table>
</div>

<div style="text-align:center; margin-top: 36px;">
  <a href="startmatch" class="secondary">⬅ Back to Tournaments</a>
</div>
<% } %>

</div> <!-- wrap -->

<footer>
  Cricket Tournament Manager • Admin Portal
</footer>

</body>
</html>
