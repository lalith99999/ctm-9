<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.*" %>
<%!
  String formatScore(Object runsObj, Object wktsObj, Object oversObj) {
    if (runsObj == null || wktsObj == null || oversObj == null) return "-";
    try {
      int runs = ((Number) runsObj).intValue();
      int wkts = ((Number) wktsObj).intValue();
      double overs = ((Number) oversObj).doubleValue();
      return runs + "/" + wkts + " (" + String.format(java.util.Locale.US, "%.1f", overs) + " ov)";
    } catch (Exception e) {
      return "-";
    }
  }
%>
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
  List<Map<String,Object>> scheduledMatches = (List<Map<String,Object>>) request.getAttribute("scheduledMatches");
  List<Map<String,Object>> liveMatches = (List<Map<String,Object>>) request.getAttribute("liveMatches");
  List<Map<String,Object>> finishedMatches = (List<Map<String,Object>>) request.getAttribute("finishedMatches");
  List<TeamStanding> standings = (List<TeamStanding>) request.getAttribute("standings");
  Map<String, List<Map<String,Object>>> teamPlayers = (Map<String, List<Map<String,Object>>>) request.getAttribute("teamPlayers");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title><%= tournament.getName() %> — Tournament Hub</title>
  <style>
    :root {
      --bg: linear-gradient(160deg, #0d1b2a, #1e3a8a);
      --panel: rgba(15, 23, 42, 0.92);
      --sub-panel: rgba(30, 41, 59, 0.9);
      --accent: #38bdf8;
      --accent-hover: #0ea5e9;
      --text: #f8fafc;
      --muted: #94a3b8;
      --radius: 16px;
      --shadow: 0 18px 32px rgba(0,0,0,0.35);
      --font: "Poppins", "Segoe UI", sans-serif;
    }

    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: var(--font);
      min-height: 100vh;
    }

    .top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 18px 28px;
      background: rgba(15, 23, 42, 0.95);
      border-bottom: 2px solid var(--accent);
      box-shadow: var(--shadow);
    }

    .brand { font-size: 1.35rem; font-weight: 700; color: var(--accent); }

    .nav a {
      margin-left: 12px;
      padding: 8px 16px;
      border-radius: 12px;
      background: var(--accent);
      color: #fff;
      text-decoration: none;
      font-weight: 600;
      transition: 0.25s;
    }

    .nav a:hover { background: var(--accent-hover); box-shadow: 0 0 12px rgba(14,165,233,0.55); }

    .content {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 26px;
      width: 92%;
      max-width: 1280px;
      margin: 40px auto 60px;
    }

    .panel {
      background: var(--panel);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      padding: 28px 32px;
    }

    h2 {
      margin: 0 0 18px;
      font-size: 1.35rem;
      color: var(--accent);
      border-left: 4px solid var(--accent);
      padding-left: 10px;
    }

    h3 {
      margin: 18px 0 12px;
      font-size: 1.1rem;
      color: var(--accent-hover);
    }

    .match-card {
      padding: 16px 18px;
      background: var(--sub-panel);
      border-radius: var(--radius);
      border: 1px solid rgba(56,189,248,0.25);
      margin-bottom: 12px;
      box-shadow: 0 12px 22px rgba(15,23,42,0.35);
    }

    .match-card:last-child { margin-bottom: 0; }

    .match-card .title {
      font-weight: 700;
      margin-bottom: 6px;
    }

    .match-card .detail { color: var(--muted); font-size: 0.9rem; }

    .empty { color: var(--muted); font-style: italic; margin-bottom: 12px; }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 12px;
      background: var(--sub-panel);
      border-radius: var(--radius);
      overflow: hidden;
    }

    th, td {
      padding: 12px 14px;
      text-align: left;
      border-bottom: 1px solid rgba(148,163,184,0.18);
      font-size: 0.95rem;
    }

    th {
      text-transform: uppercase;
      font-size: 0.85rem;
      letter-spacing: 0.08em;
      background: rgba(14,165,233,0.16);
    }

    tr:last-child td { border-bottom: none; }

    .players-panel {
      display: flex;
      flex-direction: column;
      gap: 18px;
      max-height: 720px;
      overflow-y: auto;
      padding-right: 6px;
    }

    .team-box {
      background: var(--sub-panel);
      border-radius: var(--radius);
      padding: 18px 20px;
      border: 1px solid rgba(56,189,248,0.22);
      box-shadow: 0 12px 22px rgba(15,23,42,0.35);
    }

    .team-box h4 { margin: 0 0 12px; color: var(--accent); }

    .players-table {
      width: 100%;
      border-collapse: collapse;
    }

    .players-table th, .players-table td {
      font-size: 0.85rem;
      padding: 8px 6px;
      border-bottom: 1px solid rgba(148,163,184,0.16);
    }

    .players-table th { text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted); }

    .players-table tr:last-child td { border-bottom: none; }

    @media (max-width: 1024px) {
      .content { grid-template-columns: 1fr; }
      .players-panel { max-height: none; }
    }

    @media (max-width: 768px) {
      .panel { padding: 22px; }
      h2 { font-size: 1.2rem; }
    }
  </style>
</head>
<body>
  <div class="top">
    <div class="brand">🏏 <%= tournament.getName() %> — <%= tournament.getFormat() %></div>
    <div class="nav">
      <a href="viewer_tournament.jsp">← All Tournaments</a>
      <a href="logout">Logout</a>
    </div>
  </div>

  <div class="content">
    <div>
      <div class="panel">
        <h2>Matches Overview</h2>

        <h3>Scheduled Matches</h3>
        <% if (scheduledMatches == null || scheduledMatches.isEmpty()) { %>
          <div class="empty">No upcoming fixtures scheduled.</div>
        <% } else { for (Map<String,Object> m : scheduledMatches) { %>
          <div class="match-card">
            <div class="title"><%= m.get("aName") %> vs <%= m.get("bName") %></div>
            <div class="detail"><%= m.get("datetime") %> — <%= m.get("venue") %></div>
          </div>
        <% } } %>

        <h3>Live Matches</h3>
        <% if (liveMatches == null || liveMatches.isEmpty()) { %>
          <div class="empty">No matches are live right now.</div>
        <% } else { for (Map<String,Object> m : liveMatches) { %>
          <div class="match-card">
            <div class="title"><%= m.get("aName") %> vs <%= m.get("bName") %></div>
            <div class="detail">Score: <%= formatScore(m.get("aRuns"), m.get("aWkts"), m.get("aOvers")) %> | <%= formatScore(m.get("bRuns"), m.get("bWkts"), m.get("bOvers")) %></div>
            <div class="detail">Venue: <%= m.get("venue") %></div>
          </div>
        <% } } %>

        <h3>Finished Matches</h3>
        <% if (finishedMatches == null || finishedMatches.isEmpty()) { %>
          <div class="empty">No finished matches yet.</div>
        <% } else { for (Map<String,Object> m : finishedMatches) { %>
          <div class="match-card">
            <div class="title"><%= m.get("aName") %> vs <%= m.get("bName") %></div>
            <div class="detail">Result: <%= m.get("result") != null ? m.get("result") : "Match completed" %></div>
            <div class="detail">Final Scores: <%= formatScore(m.get("aRuns"), m.get("aWkts"), m.get("aOvers")) %> | <%= formatScore(m.get("bRuns"), m.get("bWkts"), m.get("bOvers")) %></div>
          </div>
        <% } } %>
      </div>

      <div class="panel" style="margin-top:24px;">
        <h2>Points Table</h2>
        <% if (standings == null || standings.isEmpty()) { %>
          <div class="empty">Points table will appear once matches are completed.</div>
        <% } else { %>
          <table>
            <tr><th>Team</th><th>Played</th><th>Points</th><th>NRR</th></tr>
            <% for (TeamStanding s : standings) { %>
              <tr>
                <td><%= s.getName() %></td>
                <td><%= s.getPlayed() %></td>
                <td><%= s.getPoints() %></td>
                <td><%= String.format(java.util.Locale.US, "%.2f", s.getNrr()) %></td>
              </tr>
            <% } %>
          </table>
        <% } %>
      </div>
    </div>

    <div class="panel">
      <h2>Teams & Players</h2>
      <% if (teamPlayers == null || teamPlayers.isEmpty()) { %>
        <div class="empty">Teams and player statistics will appear once squads are published.</div>
      <% } else { %>
        <div class="players-panel">
          <% for (Map.Entry<String, List<Map<String,Object>>> entry : teamPlayers.entrySet()) { %>
            <div class="team-box">
              <h4>🏏 <%= entry.getKey() %></h4>
              <% List<Map<String,Object>> players = entry.getValue(); %>
              <% if (players == null || players.isEmpty()) { %>
                <div class="empty" style="margin:0;">No player statistics available yet.</div>
              <% } else { %>
                <table class="players-table">
                  <tr><th>Player</th><th>Matches</th><th>Runs</th><th>Wickets</th></tr>
                  <% for (Map<String,Object> p : players) { %>
                    <tr>
                      <td><%= p.get("name") %></td>
                      <td style="text-align:center;"><%= p.get("matches") %></td>
                      <td style="text-align:center;"><%= p.get("runs") %></td>
                      <td style="text-align:center;"><%= p.get("wickets") %></td>
                    </tr>
                  <% } %>
                </table>
              <% } %>
            </div>
          <% } %>
        </div>
      <% } %>
    </div>
  </div>

  <script>
    if (history.replaceState) {
      history.replaceState(null, '', location.href);
    }
  </script>
</body>
</html>
