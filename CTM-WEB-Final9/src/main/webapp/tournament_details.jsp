<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.*" %>
<%
  String username = (String) session.getAttribute("username");
  String role = (String) session.getAttribute("role");
  if (username == null || role == null || !"viewer".equalsIgnoreCase(role)) {
      response.sendRedirect("index.jsp"); return;
  }
  response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  Tournament tournament = (Tournament) request.getAttribute("tournament");
  List<Map<String,Object>> todayMatches = (List<Map<String,Object>>) request.getAttribute("todayMatches");
  List<Map<String,Object>> scheduledMatches = (List<Map<String,Object>>) request.getAttribute("scheduledMatches");
  List<TeamStanding> points = (List<TeamStanding>) request.getAttribute("pointsTable");
  Map<String, List<String>> teamsPlayers = (Map<String, List<String>>) request.getAttribute("teamsPlayers");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title><%= tournament.getName() %> — Tournament Details</title>
<style>
/* === THEME VARIABLES === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.92);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 14px;
  --shadow: 0 4px 22px rgba(0, 0, 0, 0.45);
  --font: "Poppins", "Segoe UI", sans-serif;
}

/* === BASE === */
body {
  margin: 0;
  background: var(--bg-main);
  color: var(--text);
  font-family: var(--font);
  min-height: 100vh;
  overflow-x: hidden;
}

/* === HEADER === */
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
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--accent);
}
.logout, .back {
  background: var(--accent);
  color: white;
  padding: 8px 14px;
  border-radius: var(--radius);
  text-decoration: none;
  font-weight: 600;
  transition: 0.3s;
}
.logout:hover, .back:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}

/* === MAIN CONTENT LAYOUT === */
.content {
  display: grid;
  grid-template-columns: 2.3fr 1fr;
  gap: 25px;
  width: 90%;
  max-width: 1300px;
  margin: 40px auto;
}
.panel {
  background: var(--card-bg);
  padding: 25px 30px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
}
h2 {
  color: var(--accent-hover);
  font-size: 1.4rem;
  border-left: 4px solid var(--accent);
  padding-left: 10px;
  margin-bottom: 18px;
}

/* === MATCH CARDS === */
.match {
  background: rgba(30, 41, 59, 0.85);
  border: 1px solid rgba(59,130,246,0.3);
  border-radius: var(--radius);
  padding: 12px 18px;
  margin-bottom: 14px;
  box-shadow: var(--shadow);
  transition: 0.3s;
}
.match:hover {
  border-color: var(--accent);
  box-shadow: 0 0 15px rgba(59,130,246,0.4);
  transform: translateY(-3px);
}
.match div:first-child {
  font-weight: 600;
  margin-bottom: 4px;
}
.match .status {
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.85rem;
  text-transform: capitalize;
}
.status.LIVE {
  background: #16a34a;
  color: white;
}
.status.FINISHED {
  background: #eab308;
  color: #1e1e1e;
}
.status.SCHEDULED {
  background: #3b82f6;
  color: white;
}

/* === TABLES === */
table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(30, 41, 59, 0.85);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow);
}
th, td {
  padding: 10px 12px;
  text-align: center;
}
th {
  background: rgba(59,130,246,0.2);
  color: var(--accent-hover);
}
tr:nth-child(even) td {
  background: rgba(255,255,255,0.02);
}
tr:hover td {
  background: rgba(59,130,246,0.07);
}

/* === TEAM BOX === */
.teamBox {
  background: rgba(30,41,59,0.85);
  border-radius: var(--radius);
  padding: 14px 18px;
  margin-bottom: 14px;
  border: 1px solid rgba(59,130,246,0.3);
  box-shadow: var(--shadow);
  transition: 0.3s;
}
.teamBox:hover {
  transform: translateY(-3px);
  border-color: var(--accent);
  box-shadow: 0 0 15px rgba(59,130,246,0.4);
}
.teamBox ul {
  margin: 0;
  list-style-type: circle;
  color: var(--muted);
  line-height: 1.6;
}

/* === RESPONSIVE === */
@media (max-width: 1000px) {
  .content {
    grid-template-columns: 1fr;
  }
}
@media (max-width: 768px) {
  .panel {
    padding: 18px;
  }
  h2 {
    font-size: 1.2rem;
  }
}
</style></head>
<body class="user-view">
  <div class="top">
    <div class="brand">🏏 <%= tournament.getName() %> — <%= tournament.getFormat() %></div>
    <div>
      <a class="back" href="tournament_home.jsp">← All Tournaments</a>
      &nbsp;
      <a class="logout" href="logout">Logout</a>
    </div>
  </div>

  <div class="content">
    <!-- LEFT: Matches + Points -->
    <div>
      <div class="panel">
        <h2>Today’s Live / Finished Matches</h2>
        <% if (todayMatches == null || todayMatches.isEmpty()) { %>
          <p>No live or finished matches today.</p>
        <% } else {
             for (Map<String,Object> m : todayMatches) {
               String status = String.valueOf(m.get("status"));
               String aTeam = String.valueOf(m.get("teamA"));
               String bTeam = String.valueOf(m.get("teamB"));
               String scoreA = m.get("aRuns") + "/" + m.get("aWkts");
               String scoreB = m.get("bRuns") + "/" + m.get("bWkts");
        %>
          <div class="match">
            <div><b><%= aTeam %></b> vs <b><%= bTeam %></b> — <span class="status <%= status %>"><%= status %></span></div>
            <div>Score: <%= scoreA %>  |  <%= scoreB %></div>
            <div><%= m.get("venue") %>  —  <%= m.get("datetime") %></div>
          </div>
        <% } } %>
      </div>

      <div class="panel" style="margin-top:18px;">
        <h2>Scheduled Matches</h2>
        <% if (scheduledMatches == null || scheduledMatches.isEmpty()) { %>
          <p>No upcoming matches scheduled.</p>
        <% } else {
             for (Map<String,Object> m : scheduledMatches) { %>
          <div class="match">
            <div><b><%= m.get("teamA") %></b> vs <b><%= m.get("teamB") %></b></div>
            <div><%= m.get("datetime") %> — <%= m.get("venue") %></div>
          </div>
        <% } } %>
      </div>

      <div class="panel" style="margin-top:18px;">
        <h2>Points Table</h2>
        <% if (points == null || points.isEmpty()) { %>
          <p>No points data available.</p>
        <% } else { %>
          <table>
            <tr><th>Team</th><th>Played</th><th>Points</th><th>NRR</th></tr>
            <% for (TeamStanding s : points) { %>
              <tr>
                <td><%= s.getName() %></td>
                <td><%= s.getPlayed() %></td>
                <td><%= s.getPoints() %></td>
                <td><%= String.format("%.2f", s.getNrr()) %></td>
              </tr>
            <% } %>
          </table>
        <% } %>
      </div>
    </div>

    <!-- RIGHT: Teams & Players -->
    <div class="panel">
      <h2>Teams & Players</h2>
      <% if (teamsPlayers == null || teamsPlayers.isEmpty()) { %>
        <p>No team or player data available.</p>
      <% } else {
           for (Map.Entry<String, List<String>> e : teamsPlayers.entrySet()) { %>
        <div class="teamBox">
          <div style="font-weight:800; margin-bottom:6px;">🏏 <%= e.getKey() %></div>
          <div class="players">
            <ul style="margin:0; padding-left:16px;">
              <% for (String p : e.getValue()) { %>
                <li><%= p %></li>
              <% } %>
            </ul>
          </div>
        </div>
      <% } } %>
    </div>
  </div>

  <script>
    // Prevent cached navigation
    window.history.replaceState && window.history.replaceState(null, "", window.location.href);
    window.onpopstate = function(){ window.location.replace("tournament_home.jsp"); };
  </script>
</body>
</html>
