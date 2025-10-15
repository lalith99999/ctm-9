<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Tournament" %>
<%
  String role = (String) session.getAttribute("role");
  if (role == null || !"admin".equalsIgnoreCase(role)) { response.sendRedirect("index.jsp"); return; }
  response.setHeader("Cache-Control","no-cache,no-store,must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);

  List<Tournament> tournaments = (List<Tournament>) request.getAttribute("tournaments");
  String msg = request.getParameter("msg");
  String err = request.getParameter("err");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Tournaments</title>

<style>
/* === THEME VARIABLES === */
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
.link {
  color: var(--accent-hover);
  text-decoration: none;
  font-weight: 600;
  margin-left: 15px;
}
.link:hover {
  text-decoration: underline;
}

/* === MAIN WRAPPER === */
.wrap {
  width: 90%;
  max-width: 950px;
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

/* === HEADINGS === */
h2 {
  color: var(--accent-hover);
  margin-bottom: 15px;
  font-weight: 600;
}

/* === FORM STYLING === */
form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  margin-bottom: 15px;
}
input {
  flex: 1;
  background: rgba(15, 23, 42, 0.8);
  color: var(--text);
  border: 1px solid #334155;
  border-radius: var(--radius);
  padding: 8px 12px;
  font-size: 0.95rem;
  transition: 0.3s;
}
input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 8px var(--accent);
}

/* === BUTTONS === */
button, .btn {
  border: none;
  border-radius: var(--radius);
  font-weight: 600;
  padding: 8px 14px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: 0.3s;
}
.btn-primary, .btn {
  background: var(--accent);
  color: white;
}
.btn-primary:hover, .btn:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}
.btn-danger {
  background: var(--danger);
  color: white;
}
.btn-danger:hover {
  background: #f87171;
}

/* === TABLE === */
table {
  width: 100%;
  border-collapse: collapse;
  background: rgba(30, 41, 59, 0.9);
  border-radius: var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow);
  margin-top: 10px;
}
th, td {
  padding: 10px;
  text-align: center;
  border-bottom: 1px solid rgba(255,255,255,0.1);
}
th {
  background: rgba(30, 58, 138, 0.9);
  color: #f1f5f9;
  text-transform: uppercase;
  font-size: 0.85rem;
}
tr:hover {
  background: rgba(59,130,246,0.15);
}
td[colspan] {
  color: var(--muted);
  font-style: italic;
}

/* === INLINE FORM IN TABLE === */
td form {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}
td input {
  width: 160px;
  font-size: 0.85rem;
  padding: 6px 8px;
}
td button {
  font-size: 0.85rem;
  padding: 6px 10px;
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
  td input {
    width: 100%;
  }
}
</style>
<script>
function validateName(form){
  const name = form.name.value.trim();
  if(!/^[A-Za-z0-9\s]+$/.test(name)){
    alert("Tournament name must contain only alphabets or numbers.");
    return false;
  }
  return true;
}

// Prevent re-submission on back/refresh
if (window.history.replaceState) {
  window.history.replaceState(null, null, window.location.href);
}
</script>
</head>
<body class="admin-panel">
<div class="top">
  <div class="brand">🏆 Manage Tournaments</div>
  <div><a href="adminmain.jsp" class="link">Home</a> &nbsp; <a href="logout" class="link">Logout</a></div>
</div>

<div class="wrap">
  <% if (msg != null) { %><div class="msg">✅ <%= msg.replace("+"," ") %></div><% } %>
  <% if (err != null) { %><div class="msg" style="color:#c0392b;">⚠️ <%= err.replace("+"," ") %></div><% } %>

  <h2>Create Tournament</h2>
  <form method="post" action="admtournaments" onsubmit="return validateName(this)">
    <input type="hidden" name="action" value="create">
    <input name="name" placeholder="Tournament Name" required>
    <button class="btn btn-primary">Create</button>
  </form>

  <h2 style="margin-top:22px;">Existing Tournaments</h2>
  <table>
    <tr><th>ID</th><th>Name</th><th>Format</th><th>Actions</th></tr>
    <% if (tournaments == null || tournaments.isEmpty()) { %>
      <tr><td colspan="4" style="text-align:center;">No tournaments yet.</td></tr>
    <% } else { for (Tournament t : tournaments) { %>
      <tr>
        <td><%= t.getId() %></td>
        <td><%= t.getName() %></td>
        <td><%= t.getFormat() %></td>
        <td>
          <form method="post" action="admtournaments" onsubmit="return validateName(this)">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<%= t.getId() %>">
            <input name="name" value="<%= t.getName() %>" required>
            <button class="btn btn-primary">Save</button>
          </form>
          <form method="post" action="admtournaments"
                onsubmit="return confirm('Delete this tournament?');" style="margin-top:5px;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="<%= t.getId() %>">
            <button class="btn btn-danger">Delete</button>
          </form>
        </td>
      </tr>
    <% } } %>
  </table>
</div>
</body>
</html>
