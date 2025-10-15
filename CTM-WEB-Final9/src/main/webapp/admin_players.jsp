<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Player, com.ctm.model.PlayerType, com.ctm.model.Team" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) { response.sendRedirect("index.jsp"); return; }
  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  Team team = (Team) request.getAttribute("team");
  List<Player> players = (List<Player>) request.getAttribute("players");
  String msg = request.getParameter("msg");
  String err = request.getParameter("err");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Players - <%= team.getName() %></title>
<style>
/* === THEME === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.92);
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
  background: var(--bg-main);
  color: var(--text);
  font-family: var(--font);
  min-height: 100vh;
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
  font-size: 1.3rem;
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

/* === MAIN WRAPPER === */
.wrap {
  width: 90%;
  max-width: 1000px;
  margin: 40px auto;
  background: var(--card-bg);
  padding: 30px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
}

/* === MESSAGES === */
.msg {
  padding: 12px;
  border-radius: var(--radius);
  margin-bottom: 15px;
  font-weight: 600;
  text-align: center;
  background: rgba(34,197,94,0.15);
  border-left: 5px solid var(--success);
}
.msg[style*="#c0392b"] {
  background: rgba(239,68,68,0.15);
  border-left: 5px solid var(--danger);
}

/* === FORM STYLING === */
form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  margin-bottom: 15px;
}
input, select {
  flex: 1;
  background: rgba(15, 23, 42, 0.8);
  color: var(--text);
  border: 1px solid #334155;
  border-radius: var(--radius);
  padding: 8px 12px;
  font-size: 0.95rem;
  outline: none;
  transition: 0.3s;
}
input:focus, select:focus {
  border-color: var(--accent);
  box-shadow: 0 0 8px var(--accent);
}

/* === BUTTONS === */
button, .btn {
  background: var(--accent);
  border: none;
  color: #fff;
  border-radius: var(--radius);
  padding: 8px 16px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: 0.3s;
}
button:hover, .btn:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96, 165, 250, 0.5);
}
.btn-danger {
  background: var(--danger);
}
.btn-danger:hover {
  background: #f87171;
}

/* === HEADINGS === */
h2 {
  color: var(--accent-hover);
  margin-top: 20px;
  margin-bottom: 15px;
  text-align: left;
}

/* === TABLE STYLING === */
table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 10px;
  background: rgba(30, 41, 59, 0.85);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow);
}
th, td {
  padding: 10px 8px;
  text-align: center;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}
th {
  background: rgba(30, 58, 138, 0.9);
  text-transform: uppercase;
  font-size: 0.85rem;
  letter-spacing: 0.5px;
}
tr:hover {
  background: rgba(37,99,235,0.2);
}

/* === INLINE FORMS INSIDE TABLE === */
td form {
  display: flex;
  gap: 8px;
  justify-content: center;
  align-items: center;
}
td input {
  width: 120px;
  font-size: 0.85rem;
}
td select {
  width: 110px;
}
td button {
  font-size: 0.85rem;
  padding: 6px 10px;
}

/* === EMPTY STATE === */
td[colspan="4"] {
  color: var(--muted);
  font-style: italic;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .wrap {
    padding: 20px;
  }
  form {
    flex-direction: column;
    align-items: stretch;
  }
  td form {
    flex-direction: column;
  }
}
</style>
<script>
function validateForm(form){
  const name = form.name.value.trim();
  const jersey = form.jerseyNo.value.trim();
  if(!/^[A-Za-z\s]+$/.test(name)){ alert("Name must contain only alphabets."); return false; }
  if(!/^[0-9]+$/.test(jersey) || jersey < 1 || jersey > 999){ alert("Invalid jersey number."); return false; }
  return true;
}
if(window.history.replaceState){ window.history.replaceState(null,null,window.location.href); }
</script>
</head>
<body class="admin-panel">
<div class="top">
  <div class="brand">👕 Manage Players - <%= team.getName() %> (<%= team.getCity() %>)</div>
  <div>
    <a href="admteams" class="link">Back to Teams</a>
    <a href="logout" class="link">Logout</a>
  </div>
</div>

<div class="wrap">
  <% if (msg!=null) { %><div class="msg">✅ <%= msg.replace("+"," ") %></div><% } %>
  <% if (err!=null) { %><div class="msg" style="color:#c0392b;">⚠️ <%= err.replace("+"," ") %></div><% } %>

  <h2>Add Player</h2>
  <form method="post" action="admplayers" onsubmit="return validateForm(this)">
    <input type="hidden" name="action" value="create">
    <input type="hidden" name="teamId" value="<%= team.getId() %>">
    <input name="jerseyNo" placeholder="Jersey No (1-999)" required>
    <input name="name" placeholder="Player Name" required>
    <select name="type" required>
      <% for (PlayerType t : PlayerType.values()) { %>
        <option value="<%= t.name() %>"><%= t.name().replace('_',' ') %></option>
      <% } %>
    </select>
    <button class="btn btn-primary">Add</button>
  </form>

  <h2 style="margin-top:22px;">Team Players</h2>
  <table>
    <tr><th>#</th><th>Name</th><th>Role</th><th>Actions</th></tr>
    <% if (players==null || players.isEmpty()) { %>
      <tr><td colspan="4" style="text-align:center;">No players yet.</td></tr>
    <% } else { for (Player p : players) { %>
      <tr>
        <td><%= p.getJerseyNumber() %></td>
        <td><%= p.getName() %></td>
        <td><%= p.getType() %></td>
        <td>
          <form method="post" action="admplayers" onsubmit="return validateForm(this)">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="teamId" value="<%= team.getId() %>">
            <input type="hidden" name="jerseyNo" value="<%= p.getJerseyNumber() %>">
            <input name="name" value="<%= p.getName() %>" required>
            <select name="type" required>
              <% for (PlayerType t : PlayerType.values()) { %>
                <option value="<%= t.name() %>" <%= t==p.getType()?"selected":"" %>><%= t.name().replace('_',' ') %></option>
              <% } %>
            </select>
            <button class="btn btn-primary">Save</button>
          </form>
          <form method="post" action="admplayers"
                onsubmit="return confirm('Delete this player?');" style="margin-top:5px;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="teamId" value="<%= team.getId() %>">
            <input type="hidden" name="jerseyNo" value="<%= p.getJerseyNumber() %>">
            <button class="btn btn-danger">Delete</button>
          </form>
        </td>
      </tr>
    <% } } %>
  </table>
</div>
</body>
</html>
