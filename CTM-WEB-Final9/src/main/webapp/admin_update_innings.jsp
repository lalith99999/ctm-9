<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Match, com.ctm.model.Tournament" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) { response.sendRedirect("index.jsp"); return; }

  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  String msg = (String) request.getAttribute("msg");
  String err = (String) request.getAttribute("err");
  String mode = (String) request.getAttribute("mode");
  if (mode == null) mode = "tournaments";
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Update Innings</title>
<style>
/* === THEME === */
:root {
  --bg-start: #0d1b2a;
  --bg-end: #1e3a8a;
  --panel: rgba(15, 23, 42, 0.92);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --danger: #ef4444;
  --success: #22c55e;
  --muted: #94a3b8;
  --text: #f8fafc;
  --radius: 12px;
  --shadow: 0 8px 24px rgba(0,0,0,0.4);
  --font: "Poppins", "Segoe UI", sans-serif;
}

/* === BASE === */
body {
  margin: 0;
  font-family: var(--font);
  background: linear-gradient(150deg, var(--bg-start), var(--bg-end));
  color: var(--text);
  min-height: 100vh;
}

/* === NAVBAR === */
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
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--accent);
}
.link {
  background: var(--accent);
  color: white;
  text-decoration: none;
  font-weight: 600;
  padding: 8px 14px;
  border-radius: var(--radius);
  margin-left: 10px;
  transition: 0.3s;
}
.link:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 8px rgba(96,165,250,0.6);
}

/* === WRAPPER === */
.wrap {
  width: 90%;
  max-width: 960px;
  margin: 40px auto;
  background: var(--panel);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: 32px 40px;
}

/* === MESSAGES === */
.msg {
  padding: 12px;
  border-radius: var(--radius);
  margin-bottom: 16px;
  font-weight: 600;
  text-align: center;
  border-left: 5px solid var(--success);
  background: rgba(34,197,94,0.15);
}
.msg.error {
  border-left-color: var(--danger);
  background: rgba(239,68,68,0.15);
}

/* === HEADINGS === */
h2 {
  margin-top: 0;
  color: var(--accent-hover);
  text-align: center;
}
h3 {
  color: var(--accent);
  text-align: center;
  margin-top: 0;
}

/* === TABLE === */
table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(30,41,59,0.9);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow);
  margin-top: 20px;
}
th, td {
  padding: 12px;
  text-align: center;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}
th {
  background: rgba(30,58,138,0.9);
  text-transform: uppercase;
  font-size: 0.9rem;
}
tr:hover { background: rgba(37,99,235,0.15); }
td a.btn {
  background: var(--accent);
  color: white;
  padding: 6px 10px;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.9rem;
  transition: 0.3s;
}
td a.btn:hover {
  background: var(--accent-hover);
}

/* === SCOREBOARD === */
.scoreboard {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-top: 20px;
}
.scorebox {
  background: rgba(15,23,42,0.8);
  padding: 20px;
  border-radius: var(--radius);
  text-align: center;
  box-shadow: var(--shadow);
}
.scorebox h4 { color: var(--accent-hover); margin-bottom: 10px; }
.scorebox.locked { opacity: 0.6; pointer-events: none; }
input.short {
  width: 100%;
  text-align: center;
  margin-bottom: 10px;
  border: 1px solid #334155;
  border-radius: var(--radius);
  padding: 8px 12px;
  background: rgba(15, 23, 42, 0.85);
  color: var(--text);
  font-size: 1rem;
}
.btn-main {
  background: var(--accent);
  color: white;
  padding: 10px 16px;
  border-radius: var(--radius);
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: 0.3s;
}
.btn-main:hover {
  background: var(--accent-hover);
}

/* === RESPONSIVE === */
@media (max-width: 780px) {
  .scoreboard { grid-template-columns: 1fr; }
  .wrap { padding: 24px; }
}
</style>
<script>
function validateTotals(prefix){
  const runs = +document.getElementById(prefix+'total').value;
  const overs = +document.getElementById(prefix+'overs').value;
  const wkts = +document.getElementById(prefix+'wickets').value;
  if(wkts < 10 && overs != 20){
    alert('If not all out, 20 overs must be completed.');
    return false;
  }
  return true;
}
</script>
</head>
<body>
<div class="top">
  <div class="brand">⚙️ Update Innings</div>
  <div>
    <a href="adminmain.jsp" class="link">Home</a>
    <a href="logout" class="link">Logout</a>
  </div>
</div>

<div class="wrap">
  <% if (msg != null) { %><div class="msg">✅ <%= msg %></div><% } %>
  <% if (err != null) { %><div class="msg error">❌ <%= err %></div><% } %>

  <% if ("tournaments".equals(mode)) { %>
    <h2>Live Tournaments</h2>
    <table>
      <tr><th>Tournament Name</th><th>Live Matches</th><th>Action</th></tr>
      <%
        List<Map<String,Object>> tours = (List<Map<String,Object>>) request.getAttribute("tournaments");
        if (tours != null && !tours.isEmpty()) {
          for (Map<String,Object> t : tours) {
      %>
        <tr>
          <td><%= t.get("tournament_name") %></td>
          <td><%= t.get("live_count") %></td>
          <td><a href="updateinnings?action=matches&tid=<%= t.get("tournament_id") %>" class="btn">View Matches</a></td>
        </tr>
      <% }} else { %>
        <tr><td colspan="3" style="color:var(--muted);font-style:italic;">No live tournaments.</td></tr>
      <% } %>
    </table>

  <% } else if ("matches".equals(mode)) { %>
    <%
      Tournament t = (Tournament) request.getAttribute("tournament");
      List<Match> liveMatches = (List<Match>) request.getAttribute("liveMatches");
    %>
    <h2>Live Matches - <%= t != null ? t.getName() : "" %></h2>
    <table>
      <tr><th>Match</th><th>Action</th></tr>
      <% if (liveMatches != null && !liveMatches.isEmpty()) {
           for (Match m : liveMatches) { %>
        <tr>
          <td><%= m.getTeam1Name() %> vs <%= m.getTeam2Name() %></td>
          <td><a href="updateinnings?action=form&matchId=<%= m.getMatchId() %>" class="btn">Update Innings</a></td>
        </tr>
      <% }} else { %>
        <tr><td colspan="2" style="color:var(--muted);font-style:italic;">No live matches.</td></tr>
      <% } %>
    </table>

  <% } else if ("form".equals(mode)) { %>
    <%
      Match match = (Match) request.getAttribute("match");
      if (match != null) {
    %>
    <h2>Update Innings: <%= match.getTeam1Name() %> vs <%= match.getTeam2Name() %></h2>

    <div class="scoreboard">
      <!-- First Innings -->
      <div class="scorebox">
        <h4>First Innings</h4>
        <form method="post" action="updateinnings" onsubmit="return validateTotals('')">
          <input type="hidden" name="matchId" value="<%= match.getMatchId() %>">
          <input type="hidden" name="step" value="saveFirst">
          <input id="total" name="total" type="number" placeholder="Total Runs" min="0" required class="short">
          <input id="overs" name="overs" type="number" placeholder="Overs (0–20)" min="0" max="20" required class="short">
          <input id="wickets" name="wickets" type="number" placeholder="Wickets (0–10)" min="0" max="10" required class="short">
          <button class="btn-main">Save First Innings</button>
        </form>
      </div>

      <!-- Second Innings -->
      <div class="scorebox">
        <h4>Second Innings</h4>
        <form method="post" action="updateinnings" onsubmit="return validateTotals('2')">
          <input type="hidden" name="matchId" value="<%= match.getMatchId() %>">
          <input type="hidden" name="step" value="saveSecond">
          <input id="2total" name="total" type="number" placeholder="Total Runs" min="0" required class="short">
          <input id="2overs" name="overs" type="number" placeholder="Overs (0–20)" min="0" max="20" required class="short">
          <input id="2wickets" name="wickets" type="number" placeholder="Wickets (0–10)" min="0" max="10" required class="short">
          <button class="btn-main">Save Second Innings</button>
        </form>
      </div>
    </div>
    <% } %>
  <% } %>
</div>
</body>
</html>
