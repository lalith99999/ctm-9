<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Match, com.ctm.model.Tournament, com.ctm.model.MatchStatus" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) {
      response.sendRedirect("index.jsp"); return;
  }

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
    :root {
      --bg-start: #0d1b2a;
      --bg-end: #1e3a8a;
      --card: rgba(15, 23, 42, 0.92);
      --panel: rgba(15, 23, 42, 0.85);
      --accent: #38bdf8;
      --accent-hover: #0ea5e9;
      --danger: #ef4444;
      --success: #22c55e;
      --muted: #94a3b8;
      --text: #f8fafc;
      --radius: 14px;
      --shadow: 0 18px 36px rgba(0,0,0,0.35);
      --font: "Poppins", "Segoe UI", sans-serif;
    }

    body {
      margin: 0;
      font-family: var(--font);
      background: linear-gradient(150deg, var(--bg-start), var(--bg-end));
      color: var(--text);
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

    .brand { font-size: 1.4rem; font-weight: 700; color: var(--accent); }

    .nav-links a {
      display: inline-block;
      margin-left: 12px;
      padding: 8px 16px;
      background: var(--accent);
      border-radius: var(--radius);
      color: #fff;
      text-decoration: none;
      font-weight: 600;
      transition: 0.25s;
    }

    .nav-links a:hover { background: var(--accent-hover); box-shadow: 0 0 12px rgba(14,165,233,0.55); }

    .wrap {
      width: 92%;
      max-width: 1150px;
      margin: 38px auto 60px;
      background: var(--card);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      padding: 34px 42px;
    }

    h2 {
      margin: 0 0 18px;
      font-size: 1.4rem;
      color: var(--accent);
      border-left: 4px solid var(--accent);
      padding-left: 10px;
    }

    .msg {
      padding: 14px;
      border-radius: var(--radius);
      margin-bottom: 18px;
      font-weight: 600;
      text-align: center;
      border-left: 5px solid var(--success);
      background: rgba(34,197,94,0.16);
    }
    .msg.error { border-left-color: var(--danger); background: rgba(239,68,68,0.16); }

    table {
      width: 100%;
      border-collapse: collapse;
      background: var(--panel);
      border-radius: var(--radius);
      overflow: hidden;
      box-shadow: var(--shadow);
    }

    th, td {
      padding: 12px 16px;
      text-align: left;
      border-bottom: 1px solid rgba(148,163,184,0.18);
    }

    th {
      text-transform: uppercase;
      font-size: 0.9rem;
      letter-spacing: 0.06em;
      background: rgba(14,165,233,0.12);
    }

    tr:hover td { background: rgba(59,130,246,0.12); }

    .btn {
      display: inline-block;
      padding: 8px 14px;
      border-radius: 10px;
      font-weight: 600;
      text-decoration: none;
      color: #fff;
      background: var(--accent);
      transition: 0.25s;
    }

    .btn:hover { background: var(--accent-hover); }
    .btn.disabled, .btn.disabled:hover { background: rgba(148,163,184,0.35); cursor: not-allowed; color: rgba(226,232,240,0.5); }

    .back-link {
      display: inline-block;
      margin-bottom: 18px;
      color: var(--accent-hover);
      text-decoration: none;
      font-weight: 600;
    }

    .back-link:hover { text-decoration: underline; }

    .scoreboard {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 22px;
      margin-top: 12px;
    }

    .innings {
      position: relative;
      padding: 24px 26px;
      background: var(--panel);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow: hidden;
    }

    .innings.locked::after {
      content: "Locked";
      position: absolute;
      top: 14px;
      right: -52px;
      transform: rotate(40deg);
      background: rgba(148,163,184,0.22);
      color: var(--muted);
      padding: 6px 70px;
      font-weight: 700;
      letter-spacing: 0.15em;
      text-transform: uppercase;
    }

    .innings h3 {
      margin: 0 0 12px;
      color: var(--accent);
      font-size: 1.2rem;
    }

    .info {
      margin-bottom: 14px;
      font-size: 0.95rem;
      color: var(--muted);
    }

    label {
      display: block;
      margin-bottom: 6px;
      font-size: 0.9rem;
      color: var(--muted);
    }

    input[type="number"] {
      width: 100%;
      padding: 10px 12px;
      border-radius: 10px;
      border: 1px solid rgba(148,163,184,0.25);
      background: rgba(15,23,42,0.9);
      color: var(--text);
      font-size: 1rem;
      margin-bottom: 12px;
    }

    input[type="number"]:disabled { opacity: 0.55; }

    .actions {
      display: flex;
      gap: 12px;
      flex-wrap: wrap;
      margin-top: 20px;
      align-items: center;
    }

    .primary-btn {
      padding: 10px 18px;
      border: none;
      border-radius: 10px;
      font-weight: 600;
      background: var(--accent);
      color: #fff;
      cursor: pointer;
      transition: 0.25s;
    }

    .primary-btn:hover { background: var(--accent-hover); }
    .primary-btn:disabled { background: rgba(148,163,184,0.4); cursor: not-allowed; }

    .note {
      font-size: 0.85rem;
      color: var(--muted);
      margin-top: 6px;
    }

    .summary {
      margin-top: 24px;
      padding: 18px 20px;
      background: rgba(30,41,59,0.75);
      border-radius: var(--radius);
      line-height: 1.5;
    }

    .result {
      margin-top: 12px;
      font-weight: 700;
      color: var(--success);
    }

    @media (max-width: 720px) {
      .wrap { padding: 26px 22px; }
      .scoreboard { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <div class="top">
    <div class="brand">🏏 Update Innings</div>
    <div class="nav-links">
      <a href="adminmain.jsp">Home</a>
      <a href="logout">Logout</a>
    </div>
  </div>

  <div class="wrap">
    <% if (msg != null) { %><div class="msg">✅ <%= msg %></div><% } %>
    <% if (err != null) { %><div class="msg error">❌ <%= err %></div><% } %>

    <% if ("tournaments".equals(mode)) { %>
      <h2>All Tournaments</h2>
      <table>
        <tr><th>Tournament</th><th>Live Matches</th><th>Action</th></tr>
        <%
          List<Map<String,Object>> tours = (List<Map<String,Object>>) request.getAttribute("tournaments");
          if (tours == null || tours.isEmpty()) {
        %>
          <tr><td colspan="3" style="text-align:center;color:var(--muted);font-style:italic;">No tournaments found.</td></tr>
        <% } else { for (Map<String,Object> t : tours) { %>
          <tr>
            <td><%= t.get("tournament_name") %></td>
            <td><%= t.get("live_count") %></td>
            <td><a class="btn" href="updateinnings?action=matches&tid=<%= t.get("tournament_id") %>">View Matches</a></td>
          </tr>
        <% } } %>
      </table>

    <% } else if ("matches".equals(mode)) {
         Tournament tour = (Tournament) request.getAttribute("tournament");
         List<Match> matchList = (List<Match>) request.getAttribute("matches");
    %>
      <a class="back-link" href="updateinnings">← All Tournaments</a>
      <h2>Matches — <%= tour != null ? tour.getName() : "" %></h2>
      <table>
        <tr><th>Match</th><th>Status</th><th>Result / Target</th><th>Action</th></tr>
        <% if (matchList == null || matchList.isEmpty()) { %>
          <tr><td colspan="4" style="text-align:center;color:var(--muted);font-style:italic;">No matches found for this tournament.</td></tr>
        <% } else {
             for (Match m : matchList) {
               MatchStatus st = m.getStatus();
               String statusLabel = st != null ? st.name() : "UNKNOWN";
               String statusDisplay = statusLabel.substring(0,1) + statusLabel.substring(1).toLowerCase();
               boolean live = MatchStatus.LIVE.equals(st);
               String resultText = m.getResult();
               String detail = resultText != null ? resultText : "";
               if (detail.isEmpty() && MatchStatus.LIVE.equals(st)) {
                   int firstRuns = m.getFirstInningsTeamId() != null && m.getFirstInningsTeamId() == m.getTeam1Id() ? m.getARuns() : m.getBRuns();
                   if (m.getFirstInningsTeamId() != null) {
                       detail = "Target " + (firstRuns + 1);
                   }
               }
        %>
          <tr>
            <td><%= m.getTeam1Name() %> vs <%= m.getTeam2Name() %></td>
            <td><%= statusDisplay %></td>
            <td><%= detail %></td>
            <td>
              <% if (live) { %>
                <a class="btn" href="updateinnings?action=form&matchId=<%= m.getMatchId() %>">Update Innings</a>
              <% } else { %>
                <span class="btn disabled">Update Innings</span>
              <% } %>
            </td>
          </tr>
        <% } } %>
      </table>

    <% } else if ("form".equals(mode)) {
         Match match = (Match) request.getAttribute("match");
         boolean firstLocked = Boolean.TRUE.equals(request.getAttribute("firstLocked"));
         boolean secondLocked = Boolean.TRUE.equals(request.getAttribute("secondLocked"));
         boolean canEnd = Boolean.TRUE.equals(request.getAttribute("canEnd"));
         boolean finished = Boolean.TRUE.equals(request.getAttribute("matchFinished"));
         String firstTeamName = (String) request.getAttribute("firstTeamName");
         String secondTeamName = (String) request.getAttribute("secondTeamName");
         int firstRuns = request.getAttribute("firstRuns") != null ? ((Number) request.getAttribute("firstRuns")).intValue() : 0;
         int firstWkts = request.getAttribute("firstWickets") != null ? ((Number) request.getAttribute("firstWickets")).intValue() : 0;
         double firstOvers = request.getAttribute("firstOvers") != null ? ((Number) request.getAttribute("firstOvers")).doubleValue() : 0.0;
         int firstExtras = request.getAttribute("firstExtras") != null ? ((Number) request.getAttribute("firstExtras")).intValue() : 0;
         int secondRuns = request.getAttribute("secondRuns") != null ? ((Number) request.getAttribute("secondRuns")).intValue() : 0;
         int secondWkts = request.getAttribute("secondWickets") != null ? ((Number) request.getAttribute("secondWickets")).intValue() : 0;
         double secondOvers = request.getAttribute("secondOvers") != null ? ((Number) request.getAttribute("secondOvers")).doubleValue() : 0.0;
         int secondExtras = request.getAttribute("secondExtras") != null ? ((Number) request.getAttribute("secondExtras")).intValue() : 0;
         int target = request.getAttribute("target") != null ? ((Number) request.getAttribute("target")).intValue() : 0;
         int maxSecondRuns = request.getAttribute("maxSecondRuns") != null ? ((Number) request.getAttribute("maxSecondRuns")).intValue() : 0;
         Long tid = (Long) request.getAttribute("tournamentId");
         if (tid == null && match != null) tid = match.getTournamentId();
    %>
      <a class="back-link" href="updateinnings?action=matches&tid=<%= tid %>">← Back to Matches</a>
      <h2><%= match.getTeam1Name() %> vs <%= match.getTeam2Name() %></h2>
      <div class="summary">
        <div>Status: <strong><%= match.getStatus() != null ? match.getStatus() : MatchStatus.LIVE %></strong></div>
        <% if (target > 0) { %>
          <div>Target for <%= secondTeamName %>: <strong><%= target %></strong></div>
        <% } %>
        <% if (finished && match.getResult() != null) { %>
          <div class="result">Result: <%= match.getResult() %></div>
        <% } %>
      </div>

      <div class="scoreboard">
        <div class="innings <%= firstLocked ? "locked" : "" %>">
          <h3>First Innings — <%= firstTeamName %></h3>
          <div class="info">Lock once full 20 overs are bowled unless all 10 wickets fall early.</div>
          <form method="post" action="updateinnings" onsubmit="return validateFirst(this)">
            <input type="hidden" name="step" value="saveFirst">
            <input type="hidden" name="matchId" value="<%= match.getMatchId() %>">
            <input type="hidden" name="tid" value="<%= tid %>">
            <label>Total Runs</label>
            <input type="number" name="total" min="0" value="<%= firstRuns %>" <%= firstLocked ? "disabled" : "" %>>
            <label>Overs (0 - 20)</label>
            <input type="number" name="overs" step="0.1" min="0" max="20" value="<%= String.format(java.util.Locale.US, "%.1f", firstOvers) %>" <%= firstLocked ? "disabled" : "" %>>
            <label>Wickets (0 - 10)</label>
            <input type="number" name="wickets" min="0" max="10" value="<%= firstWkts %>" <%= firstLocked ? "disabled" : "" %>>
            <label>Extras</label>
            <input type="number" name="extras" min="0" value="<%= firstExtras %>" <%= firstLocked ? "disabled" : "" %>>
            <div class="actions">
              <button class="primary-btn" <%= firstLocked ? "disabled" : "" %>>Lock First Innings</button>
            </div>
          </form>
        </div>

        <div class="innings <%= (!firstLocked || secondLocked) ? "locked" : "" %>">
          <h3>Second Innings — <%= secondTeamName %></h3>
          <div class="info">
            <% if (firstLocked) { %>
              Max runs allowed: <strong><%= maxSecondRuns %></strong>. Target: <strong><%= target %></strong>.
            <% } else { %>
              Lock the first innings to enable updates for the chase.
            <% } %>
          </div>
          <form method="post" action="updateinnings" onsubmit="return validateSecond(this, <%= target %>, <%= maxSecondRuns %>)">
            <input type="hidden" name="step" value="saveSecond">
            <input type="hidden" name="matchId" value="<%= match.getMatchId() %>">
            <input type="hidden" name="tid" value="<%= tid %>">
            <label>Total Runs</label>
            <input id="secondRuns" type="number" name="total" min="0" value="<%= secondRuns %>" <%= (!firstLocked || secondLocked) ? "disabled" : "" %>>
            <label>Overs (0 - 20)</label>
            <input type="number" name="overs" step="0.1" min="0" max="20" value="<%= String.format(java.util.Locale.US, "%.1f", secondOvers) %>" <%= (!firstLocked || secondLocked) ? "disabled" : "" %>>
            <label>Wickets (0 - 10)</label>
            <input type="number" name="wickets" min="0" max="10" value="<%= secondWkts %>" <%= (!firstLocked || secondLocked) ? "disabled" : "" %>>
            <label>Extras</label>
            <input type="number" name="extras" min="0" value="<%= secondExtras %>" <%= (!firstLocked || secondLocked) ? "disabled" : "" %>>
            <div class="actions">
              <button class="primary-btn" <%= (!firstLocked || secondLocked) ? "disabled" : "" %>>Lock Second Innings</button>
            </div>
          </form>
          <div class="note">Second innings can be locked early only if the target is reached or all wickets are lost.</div>
        </div>
      </div>

      <div class="actions" style="margin-top:32px;">
        <form method="post" action="updateinnings">
          <input type="hidden" name="step" value="endMatch">
          <input type="hidden" name="matchId" value="<%= match.getMatchId() %>">
          <input type="hidden" name="tid" value="<%= tid %>">
          <button class="primary-btn" style="background:#10b981;" <%= canEnd ? "" : "disabled" %>>End Match</button>
        </form>
      </div>
    <% } %>
  </div>

  <script>
    function isValidOvers(value) {
      if (value < 0 || value > 20) return false;
      const scaled = Math.round(value * 10);
      if (Math.abs(value * 10 - scaled) > 1e-6) return false;
      const balls = scaled % 10;
      return balls <= 5;
    }

    function validateFirst(form) {
      const runs = Number(form.total.value);
      const wickets = Number(form.wickets.value);
      const overs = Number(form.overs.value);
      if (!isValidOvers(overs)) { alert('Enter overs in valid cricket format (e.g., 19.5).'); return false; }
      if (wickets < 10 && Math.abs(overs - 20) > 1e-3) {
        alert('Complete 20 overs unless all 10 wickets have fallen.');
        return false;
      }
      return true;
    }

    function validateSecond(form, target, maxRuns) {
      if (form.total.disabled) return false;
      const runs = Number(form.total.value);
      const wickets = Number(form.wickets.value);
      const overs = Number(form.overs.value);
      if (runs > maxRuns) {
        alert('Runs cannot exceed the permitted maximum of ' + maxRuns + '.');
        return false;
      }
      if (!isValidOvers(overs)) {
        alert('Enter overs in valid cricket format (e.g., 19.5).');
        return false;
      }
      const reachedTarget = runs >= target && target > 0;
      if (wickets < 10 && !reachedTarget && Math.abs(overs - 20) > 1e-3) {
        alert('Second innings must finish 20 overs unless target is chased or all out.');
        return false;
      }
      return true;
    }

    <% if ("form".equals(mode)) { %>
      (function(){
        const backUrl = 'updateinnings?action=matches&tid=<%= tid %>';
        if (history.replaceState) {
          history.replaceState({page:'form'}, '', location.href);
        }
        window.onpopstate = function(){ location.href = backUrl; };
        const runsInput = document.getElementById('secondRuns');
        if (runsInput) {
          const maxRuns = <%= request.getAttribute("maxSecondRuns") != null ? ((Number) request.getAttribute("maxSecondRuns")).intValue() : 0 %>;
          if (maxRuns > 0) runsInput.max = maxRuns;
        }
      })();
    <% } %>
  </script>
</body>
</html>
