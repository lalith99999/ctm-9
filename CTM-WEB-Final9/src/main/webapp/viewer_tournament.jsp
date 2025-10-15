<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*, com.ctm.model.Tournament" %>
<%
  String username = (String) session.getAttribute("username");
  String role = (String) session.getAttribute("role");
  if (username == null || role == null || !"viewer".equalsIgnoreCase(role)) {
      response.sendRedirect("index.jsp"); return;
  }
  response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);
  List<Tournament> list = (List<Tournament>) request.getAttribute("tournaments");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>All Tournaments</title>
<style>
/* === THEME VARIABLES === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.9);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 14px;
  --shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
  --font: "Poppins", "Segoe UI", sans-serif;
}

/* === BASE === */
body {
  margin: 0;
  font-family: var(--font);
  color: var(--text);
  background: var(--bg-main);
  min-height: 100vh;
}

/* === TOP BAR === */
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
  font-size: 1.4rem;
  font-weight: 700;
  color: var(--accent);
}
.logout {
  background: var(--accent);
  color: white;
  padding: 8px 14px;
  text-decoration: none;
  border-radius: var(--radius);
  font-weight: 600;
  transition: 0.3s;
}
.logout:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}

/* === MAIN CONTAINER === */
.wrap {
  width: 90%;
  max-width: 1100px;
  margin: 40px auto;
  background: var(--card-bg);
  padding: 30px 40px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
}

/* === BACK LINK === */
.back {
  text-decoration: none;
  color: var(--accent-hover);
  font-weight: 600;
  display: inline-block;
  margin-bottom: 20px;
  transition: 0.3s;
}
.back:hover {
  text-decoration: underline;
  color: var(--accent);
}

/* === HEADING === */
h2 {
  color: var(--accent-hover);
  font-size: 1.5rem;
  margin-bottom: 25px;
  border-left: 4px solid var(--accent);
  padding-left: 10px;
}

/* === EMPTY STATE === */
p {
  color: var(--muted);
  text-align: center;
  font-style: italic;
}

/* === GRID === */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 25px;
}

/* === CARD STYLE === */
.card {
  display: block;
  background: rgba(30, 41, 59, 0.9);
  border-radius: var(--radius);
  text-decoration: none;
  color: var(--text);
  padding: 25px;
  box-shadow: var(--shadow);
  border: 1px solid rgba(59,130,246,0.3);
  transition: all 0.3s ease;
}
.card:hover {
  background: rgba(59,130,246,0.1);
  border-color: var(--accent);
  box-shadow: 0 0 18px rgba(59,130,246,0.6);
  transform: translateY(-3px);
}

/* === CARD CONTENT === */
.card div:first-child {
  color: var(--accent-hover);
  font-size: 1.1rem;
  font-weight: 700;
}
.card div:last-child {
  color: var(--muted);
  font-size: 0.9rem;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .wrap {
    padding: 20px;
  }
  .grid {
    gap: 18px;
  }
  h2 {
    font-size: 1.3rem;
  }
}
</style>
</head>
<body class="user-view">
  <div class="top">
    <div class="brand">🏏 All Tournaments</div>
    <a class="logout" href="logout">Logout</a>
  </div>

  <div class="wrap">
    <a class="back" href="usermain.jsp">← Back</a>
    <h2>Available Tournaments</h2>
    <%
      if (list == null || list.isEmpty()) {
    %><p>No tournaments found.</p><%
      } else {
    %>
    <div class="grid">
      <% for (Tournament t : list) { %>
<a class="card" href="tournamentdetails?tid=<%= t.getId() %>">
          <div style="font-size:18px;font-weight:800"><%= t.getName() %></div>
          <div style="margin-top:6px;opacity:.85">Format: <%= t.getFormat() %></div>
        </a>
      <% } %>
    </div>
    <% } %>
</div>


</body>
</html>
