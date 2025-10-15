<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Team, com.ctm.model.TeamStanding, com.ctm.model.Tournament" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) { response.sendRedirect("index.jsp"); return; }
  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  List<Tournament> tournaments = (List<Tournament>) request.getAttribute("tournaments");
  Set<Long> lockedIds = (Set<Long>) request.getAttribute("lockedIds");
  Tournament selected = (Tournament) request.getAttribute("selectedTournament");
  Boolean locked = (Boolean) request.getAttribute("locked");
  List<TeamStanding> enrolled = (List<TeamStanding>) request.getAttribute("enrolled");
  List<Team> available = (List<Team>) request.getAttribute("available");

  String msg = (String) request.getAttribute("msg");
  String err = (String) request.getAttribute("err");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Enroll Teams</title>
<style>
/* === THEME COLORS === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.9);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --danger: #ef4444;
  --success: #22c55e;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 12px;
  --shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
  --font: "Poppins", "Segoe UI", sans-serif;
}

/* === GLOBAL === */
body {
  background: var(--bg-main);
  color: var(--text);
  font-family: var(--font);
  margin: 0;
  min-height: 100vh;
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
.nav a {
  color: var(--accent-hover);
  margin-left: 10px;
  text-decoration: none;
  font-weight: 600;
}
.nav a:hover {
  text-decoration: underline;
}

/* === MAIN WRAPPER === */
.wrap {
  max-width: 1100px;
  margin: 40px auto;
  background: var(--card-bg);
  padding: 30px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
}

/* === HEADINGS === */
h2, h3 {
  color: var(--accent-hover);
  margin-bottom: 15px;
}

/* === TOASTS === */
.toast {
  padding: 12px;
  border-radius: var(--radius);
  margin-bottom: 15px;
  font-weight: 600;
  text-align: center;
}
.toast.ok {
  background: rgba(34,197,94,0.2);
  border-left: 5px solid var(--success);
}
.toast.err {
  background: rgba(239,68,68,0.2);
  border-left: 5px solid var(--danger);
}

/* === TOURNAMENT LIST === */
.list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.row {
  background: rgba(30, 41, 59, 0.9);
  border-radius: var(--radius);
  padding: 14px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: var(--shadow);
  transition: 0.3s;
}
.row:hover {
  background: rgba(37,99,235,0.15);
}

/* === BUTTON / PILL STYLES === */
.pill {
  background: var(--accent);
  color: white;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.9rem;
  text-decoration: none;
  font-weight: 600;
  transition: 0.3s;
}
.pill:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 8px var(--accent);
}
.pill.add {
  background: var(--success);
}
.pill.del {
  background: var(--danger);
}
.pill.disabled {
  background: #475569;
  cursor: not-allowed;
  opacity: 0.7;
}

/* === LOCK BANNER === */
.banner.lock {
  background: rgba(239,68,68,0.15);
  border-left: 5px solid var(--danger);
  padding: 10px 15px;
  border-radius: var(--radius);
  font-weight: 600;
  margin-bottom: 15px;
}

/* === CARDS === */
.cols {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-top: 20px;
}
.card {
  flex: 1 1 48%;
  background: rgba(15, 23, 42, 0.9);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: 20px;
}
.card h3 {
  text-align: center;
  margin-bottom: 10px;
  color: var(--accent);
}

/* === TABLES === */
table {
  width: 100%;
  border-collapse: collapse;
  color: var(--text);
  background: rgba(30, 41, 59, 0.8);
  border-radius: var(--radius);
  overflow: hidden;
  margin-top: 10px;
}
th, td {
  padding: 10px;
  text-align: center;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}
th {
  background: rgba(30, 58, 138, 0.9);
  color: #f8fafc;
  text-transform: uppercase;
  font-size: 0.85rem;
}
tr:hover {
  background: rgba(37, 99, 235, 0.15);
}
.empty {
  color: var(--muted);
  font-style: italic;
}

/* === HR LINE === */
hr {
  border: 0;
  height: 1px;
  background: rgba(255,255,255,0.1);
  margin: 25px 0;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .cols {
    flex-direction: column;
  }
  .card {
    flex: 1 1 100%;
  }
  .wrap {
    width: 90%;
    padding: 20px;
  }
}
</style>
</head>
<body class="admin-panel">
<div class="top">
  <div class="brand">🏏 Enroll Teams</div>
  <div class="nav">
    <a href="adminmain.jsp">Home</a> | <a href="logout">Logout</a>
  </div>
</div>

<div class="wrap">
  <% if (msg != null) { %><div class="toast ok"><%= msg %></div><% } %>
  <% if (err != null) { %><div class="toast err"><%= err %></div><% } %>

  <h2>Select Tournament</h2>
  <div class="list">
  <% if (tournaments == null || tournaments.isEmpty()) { %>
      <p>No tournaments found.</p>
  <% } else {
      for (Tournament t : tournaments) {
        boolean isLocked = lockedIds != null && lockedIds.contains(t.getId());
  %>
        <div class="row">
          <b><%= t.getName() %></b> (<%= t.getFormat() %>)
          <% if (isLocked) { %><span class="locked">[Fixtures Generated]</span><% } %>
          <a href="enroll?tid=<%= t.getId() %>" class="pill">Open</a>
        </div>
  <%  } } %>
  </div>

  <% if (selected != null) { %>
    <hr><h2>Manage Teams — <%= selected.getName() %></h2>
    <% if (locked != null && locked) { %>
      <div class="banner lock">🔒 Fixtures generated — changes disabled.</div>
    <% } %>

    <div class="cols">
      <div class="card">
        <h3>Available Teams</h3>
        <table>
          <tr><th>ID</th><th>Name</th><th>City</th><th></th></tr>
          <% if (available==null || available.isEmpty()) { %>
            <tr><td colspan="4" class="empty">No more teams to enroll.</td></tr>
          <% } else { for (Team t : available) { %>
            <tr>
              <td><%= t.getId() %></td>
              <td><%= t.getName() %></td>
              <td><%= t.getCity() %></td>
              <td>
                <% if (locked) { %>
                  <span class="pill disabled">Add</span>
                <% } else { %>
                  <a class="pill add" href="enroll?action=add&tid=<%= selected.getId() %>&teamId=<%= t.getId() %>">Add</a>
                <% } %>
              </td>
            </tr>
          <% } } %>
        </table>
      </div>

      <div class="card">
        <h3>Enrolled Teams</h3>
        <table>
          <tr><th>ID</th><th>Name</th><th>City</th><th>Points</th><th>Played</th><th></th></tr>
          <% if (enrolled==null || enrolled.isEmpty()) { %>
            <tr><td colspan="6" class="empty">No teams enrolled yet.</td></tr>
          <% } else { for (TeamStanding ts : enrolled) { %>
            <tr>
              <td><%= ts.getTeamId() %></td>
              <td><%= ts.getName() %></td>
              <td><%= ts.getCity() %></td>
              <td><%= ts.getPoints() %></td>
              <td><%= ts.getPlayed() %></td>
              <td>
                <% if (locked) { %>
                  <span class="pill disabled">Remove</span>
                <% } else { %>
                  <a class="pill del" href="enroll?action=remove&tid=<%= selected.getId() %>&teamId=<%= ts.getTeamId() %>"
                    onclick="return confirm('Remove this team?');">Remove</a>
                <% } %>
              </td>
            </tr>
          <% } } %>
        </table>
      </div>
    </div>
  <% } %>
</div>
</body>
</html>
