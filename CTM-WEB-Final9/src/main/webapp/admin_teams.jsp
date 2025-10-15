<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Team, com.ctm.model.Cities" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) { response.sendRedirect("index.jsp"); return; }
  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  List<Team> teams = (List<Team>) request.getAttribute("teams");
  String msg = request.getParameter("msg");
  String err = request.getParameter("err");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Teams</title>
<style>
/* --- (Keep your same CSS exactly as before) --- */
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
  --shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
  --font: "Poppins", "Segoe UI", sans-serif;
}
body { background: var(--bg-main); color: var(--text); font-family: var(--font); margin: 0; min-height: 100vh; }
.top { display:flex; justify-content:space-between; align-items:center; background:rgba(15,23,42,0.95); padding:16px 24px; border-bottom:2px solid var(--accent); box-shadow:var(--shadow);}
.brand { font-size:1.4rem; font-weight:700; color:var(--accent);}
.link { color:var(--accent-hover); text-decoration:none; font-weight:600; margin-left:14px;}
.link:hover { text-decoration:underline;}
.wrap { width:90%; max-width:1000px; margin:40px auto; background:var(--card-bg); padding:30px; border-radius:var(--radius); box-shadow:var(--shadow);}
.msg { padding:12px; border-radius:var(--radius); margin-bottom:15px; font-weight:600; text-align:center; background:rgba(34,197,94,0.15); border-left:5px solid var(--success);}
.msg[style*="#c0392b"] { background:rgba(239,68,68,0.15); border-left:5px solid var(--danger);}
h2 { color:var(--accent-hover); margin-bottom:18px;}
form { display:flex; flex-wrap:wrap; gap:10px; align-items:center; margin-bottom:18px;}
input, select { flex:1; background:rgba(15,23,42,0.8); color:var(--text); border:1px solid #334155; border-radius:var(--radius); padding:8px 12px; font-size:0.95rem; transition:0.3s;}
input:focus, select:focus { border-color:var(--accent); box-shadow:0 0 8px var(--accent);}
button, .btn { border:none; border-radius:var(--radius); font-weight:600; padding:8px 14px; cursor:pointer; font-size:0.95rem; transition:0.3s;}
.btn-primary, .btn { background:var(--accent); color:white;}
.btn-primary:hover, .btn:hover { background:var(--accent-hover); box-shadow:0 0 10px rgba(96,165,250,0.5);}
.btn-danger { background:var(--danger); color:white;}
.btn-danger:hover { background:#f87171;}
table { width:100%; border-collapse:collapse; background:rgba(30,41,59,0.9); border-radius:var(--radius); overflow:hidden; box-shadow:var(--shadow); margin-top:10px;}
th, td { padding:10px; text-align:center; border-bottom:1px solid rgba(255,255,255,0.1);}
th { background:rgba(30,58,138,0.9); text-transform:uppercase; font-size:0.85rem;}
tr:hover { background:rgba(37,99,235,0.15);}
td[colspan] { color:var(--muted); font-style:italic;}
td form { display:flex; justify-content:center; gap:8px; align-items:center;}
td input, td select { width:130px; font-size:0.85rem; padding:6px 8px;}
td button { font-size:0.85rem; padding:6px 10px;}
@media (max-width:768px){ .wrap{padding:20px;} form{flex-direction:column;align-items:stretch;} td form{flex-direction:column;} td input, td select{width:100%;}}
</style>
<script>
function validateName(form){
  const name=form.name.value.trim();
  if(!/^[A-Za-z\s]+$/.test(name)){
    alert("Team name must contain only alphabets.");
    return false;
  }
  return true;
}
function validatePlayer(form){
  const pname=form.playerName.value.trim();
  const jersey=form.jersey.value.trim();
  if(!/^[A-Za-z\s]+$/.test(pname)){ alert("Player name must contain only alphabets."); return false; }
  if(!/^\d+$/.test(jersey)){ alert("Jersey number must be numeric."); return false; }
  return true;
}
if (window.history.replaceState) window.history.replaceState(null,null,window.location.href);
</script>
</head>
<body class="admin-panel">
<div class="top">
  <div class="brand">⚙️ Manage Teams</div>
  <div>
    <a href="adminmain.jsp" class="link">Home</a>
    <a href="logout" class="link">Logout</a>
  </div>
</div>

<div class="wrap">
  <% if (msg!=null) { %><div class="msg">✅ <%= msg.replace("+"," ") %></div><% } %>
  <% if (err!=null) { %><div class="msg" style="color:#c0392b;">⚠️ <%= err.replace("+"," ") %></div><% } %>

  <!-- === CREATE TEAM === -->
  <h2>Create Team</h2>
  <form method="post" action="admteams" onsubmit="return validateName(this)">
    <input type="hidden" name="action" value="create">
    <input name="name" placeholder="Team Name" required>
    <select name="city" required>
      <option value="">--Select City--</option>
      <% for (Cities c : Cities.values()) { %>
        <option value="<%= c.name() %>"><%= c.name().replace('_',' ') %></option>
      <% } %>
    </select>
    <button class="btn btn-primary">Create</button>
  </form>

  <!-- === EXISTING TEAMS === -->
  <h2 style="margin-top:22px;">Existing Teams</h2>
  <table>
    <tr><th>ID</th><th>Name</th><th>City</th><th>Actions</th></tr>
    <% if (teams==null || teams.isEmpty()) { %>
      <tr><td colspan="4" style="text-align:center;">No teams added yet.</td></tr>
    <% } else { for (Team t : teams) { %>
      <tr>
        <td><%= t.getId() %></td>
        <td><%= t.getName() %></td>
        <td><%= t.getCity() %></td>
  <td>
  <form method="post" action="admteams" onsubmit="return validateName(this)">
    <input type="hidden" name="action" value="update">
    <input type="hidden" name="id" value="<%= t.getId() %>">
    <input name="name" value="<%= t.getName() %>" required>
    <select name="city" required>
      <% for (Cities c : Cities.values()) { %>
        <option value="<%= c.name() %>" <%= c.name().equalsIgnoreCase(t.getCity())?"selected":"" %>>
          <%= c.name().replace('_',' ') %>
        </option>
      <% } %>
    </select>
    <button class="btn btn-primary">Save</button>
  </form>

  <form method="post" action="admteams"
        onsubmit="return confirm('Delete this team?');" style="margin-top:5px;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" value="<%= t.getId() %>">
    <button class="btn btn-danger">Delete</button>
  </form>

  <!-- ✅ NEW: Enroll / Manage Players Button -->
  <form method="get" action="admplayers" style="margin-top:5px;">
    <input type="hidden" name="teamId" value="<%= t.getId() %>">
    <button class="btn btn-primary">Manage Players</button>
  </form>
</td>


      </tr>
    <% } } %>
  </table>

  
    
 
  </form>
</div>
</body>
</html>
