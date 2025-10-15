<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter, java.util.*, com.ctm.model.Match, com.ctm.model.Tournament" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) { response.sendRedirect("index.jsp"); return; }

  String mode = (String) request.getAttribute("mode");
  if (mode == null) mode = "list";
  String msg = (String) request.getAttribute("msg");
  String err = (String) request.getAttribute("err");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Generate Fixtures</title>
<<style>
/* === THEME COLORS === */
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
}

/* === TOP BAR === */
.top {
  background: rgba(15, 23, 42, 0.95);
  padding: 16px 24px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 2px solid var(--accent);
  box-shadow: var(--shadow);
}
.brand {
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--accent);
}
.link {
  color: var(--accent-hover);
  margin-left: 15px;
  text-decoration: none;
  font-weight: 600;
}
.link:hover {
  text-decoration: underline;
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
  text-align: center;
}

/* === STATUS BANNERS === */
.banner {
  padding: 12px;
  border-radius: var(--radius);
  font-weight: 600;
  text-align: center;
  margin-bottom: 20px;
}
.banner.success {
  background: rgba(34, 197, 94, 0.2);
  border-left: 5px solid var(--success);
}
.banner.error {
  background: rgba(239, 68, 68, 0.2);
  border-left: 5px solid var(--danger);
}

/* === CARD PANEL === */
.card {
  background: rgba(30, 41, 59, 0.9);
  border-radius: var(--radius);
  padding: 30px;
  box-shadow: var(--shadow);
  margin: 20px auto;
  width: 100%;
  max-width: 700px;
}
.card h2 {
  margin-bottom: 10px;
}

/* === INLINE FORM === */
.form-inline {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 15px;
  margin-top: 20px;
}
.form-inline label {
  font-weight: 600;
  color: var(--muted);
}
.form-inline select {
  background: rgba(15, 23, 42, 0.8);
  color: var(--text);
  border: 1px solid #334155;
  padding: 8px 12px;
  border-radius: var(--radius);
  outline: none;
  transition: 0.3s;
}
.form-inline select:focus {
  border-color: var(--accent);
  box-shadow: 0 0 6px var(--accent);
}

/* === BUTTONS === */
button, .primary {
  background: var(--accent);
  color: white;
  border: none;
  border-radius: var(--radius);
  padding: 10px 16px;
  cursor: pointer;
  font-weight: 600;
  transition: 0.3s;
  text-decoration: none;
}
button:hover, .primary:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96, 165, 250, 0.5);
}
button[disabled] {
  background: #475569;
  cursor: not-allowed;
  opacity: 0.6;
}

/* === CHIPS (Ready / Pending / Exists) === */
.chip {
  padding: 4px 10px;
  border-radius: 14px;
  font-size: 0.85rem;
  font-weight: 600;
  color: #fff;
}
.chip-ok {
  background: var(--success);
}
.chip-bad {
  background: var(--danger);
}
.chip-warn {
  background: var(--warning);
  color: #000;
}

/* === TABLES === */
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 20px;
  background: rgba(15, 23, 42, 0.8);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow);
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
  background: rgba(59, 130, 246, 0.15);
}
.empty {
  text-align: center;
  color: var(--muted);
  font-style: italic;
}

/* === ACTION LINKS === */
.actions {
  margin-top: 20px;
  text-align: center;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .wrap {
    padding: 20px;
  }
  .form-inline {
    flex-direction: column;
    align-items: flex-start;
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
  <div class="brand">🏏 Generate Fixtures</div>
  <div><a href="adminmain.jsp" class="link">Home</a><a href="logout" class="link">Logout</a></div>
</div>

<div class="wrap">
  <% if (msg != null) { %><div class="banner success"><%= msg %></div><% } %>
  <% if (err != null) { %><div class="banner error"><%= err %></div><% } %>

  <% if ("result".equals(mode)) {
       Tournament t = (Tournament) request.getAttribute("tournament");
       List<Match> matches = (List<Match>) request.getAttribute("matches");
       DateTimeFormatter fmt = DateTimeFormatter.ofPattern("dd MMM yyyy");
  %>
    <h2><%= t.getName() %> Fixtures</h2>
    <% if (matches == null || matches.isEmpty()) { %>
      <p class="empty">No fixtures generated.</p>
    <% } else { %>
      <table>
        <tr><th>ID</th><th>Team A</th><th>Team B</th><th>Venue</th><th>Date</th><th>Status</th></tr>
        <% for (Match m : matches) { %>
          <tr>
            <td><%= m.getMatchId() %></td>
            <td><%= m.getTeam1Name() %></td>
            <td><%= m.getTeam2Name() %></td>
            <td><%= m.getVenue() %></td>
            <td><%= m.getDateTime() == null ? "-" : fmt.format(m.getDateTime()) %></td>
            <td><%= m.getStatus() %></td>
          </tr>
        <% } %>
      </table>
    <% } %>
    <div class="actions"><a class="link" href="fixturesgen">← Back to tournaments</a></div>

  <% } else if ("confirm".equals(mode)) {
       Tournament t = (Tournament) request.getAttribute("tournament");
       Integer enrolledObj = (Integer) request.getAttribute("enrolledCount");
       Boolean squadsOkObj = (Boolean) request.getAttribute("squadsOk");
       Integer alreadyObj = (Integer) request.getAttribute("already");

       int enrolled = (enrolledObj != null) ? enrolledObj : 0;
       boolean squadsOk = (squadsOkObj != null) ? squadsOkObj : false;
       boolean fixturesExist = (alreadyObj != null && alreadyObj == 1);
  %>
    <div class="card">
      <h2><%= t.getName() %> — Fixture Generation</h2>
      <p>Teams enrolled: <b><%= enrolled %></b></p>
      <p>All teams have 11 players: <span class="chip <%= squadsOk ? "chip-ok" : "chip-bad" %>"><%= squadsOk ? "Ready" : "Pending" %></span></p>
      <p>Existing fixtures: <span class="chip <%= fixturesExist ? "chip-warn" : "chip-ok" %>"><%= fixturesExist ? "Exists" : "None" %></span></p>

      <form method="get" action="fixturesgen" class="form-inline">
        <input type="hidden" name="tid" value="<%= t.getId() %>">
        <input type="hidden" name="action" value="generate">
        <label for="venue">Select Venue</label>
        <select id="venue" name="venue" required>
          <option value="">-- Choose Stadium --</option>
          <% for (com.ctm.model.Stadium s : com.ctm.model.Stadium.values()) { %>
            <option value="<%= s.getFullName() %>"><%= s.getFullName() %></option>
          <% } %>
        </select>
        <button class="primary" type="submit" <%= (!squadsOk || enrolled < 3 || fixturesExist) ? "disabled" : "" %>>Generate Fixtures</button>
      </form>

      <a class="link" href="fixturesgen">← Back</a>
    </div>

  <% } else {
       List<Map<String,Object>> stats = (List<Map<String,Object>>) request.getAttribute("tournamentStats");
  %>
    <h2>All Tournaments</h2>
    <% if (stats == null || stats.isEmpty()) { %>
      <p class="empty">No tournaments available.</p>
    <% } else { %>
      <table>
        <tr><th>ID</th><th>Name</th><th>Teams</th><th>11 Players?</th><th>Fixtures?</th><th>Action</th></tr>
        <% for (Map<String,Object> row : stats) {
             Tournament t = (Tournament) row.get("tournament");
             int enrolled = (Integer) row.get("enrolled");
             boolean squadsOk = (Boolean) row.get("squadsOk");
             boolean fixtures = (Boolean) row.get("fixtures");
        %>
          <tr>
            <td><%= t.getId() %></td>
            <td><%= t.getName() %></td>
            <td><%= enrolled %></td>
            <td><span class="chip <%= squadsOk ? "chip-ok" : "chip-bad" %>"><%= squadsOk ? "Ready" : "Pending" %></span></td>
            <td><span class="chip <%= fixtures ? "chip-warn" : "chip-ok" %>"><%= fixtures ? "Exists" : "None" %></span></td>
            <td><a class="primary" href="fixturesgen?tid=<%= t.getId() %>">Review</a></td>
          </tr>
        <% } %>
      </table>
    <% } %>
  <% } %>
</div>
</body>
</html>
