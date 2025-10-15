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

  List<Tournament> tournaments = (List<Tournament>) request.getAttribute("tournaments");
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
  font-family: var(--font);
  background: var(--bg-main);
  color: var(--text);
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
  border-radius: var(--radius);
  text-decoration: none;
  font-weight: 600;
  transition: 0.3s;
  margin-left: 10px;
}
.logout:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}

/* === MAIN WRAP === */
.wrap {
  width: 90%;
  max-width: 1100px;
  margin: 40px auto;
  background: var(--card-bg);
  padding: 40px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
}

/* === HEADING === */
h2 {
  color: var(--accent-hover);
  font-size: 1.6rem;
  font-weight: 700;
  margin-bottom: 25px;
  border-left: 4px solid var(--accent);
  padding-left: 10px;
}

/* === EMPTY STATE === */
p {
  color: var(--muted);
  text-align: center;
  font-style: italic;
  margin-top: 20px;
}

/* === GRID === */
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 25px;
  margin-top: 15px;
}

/* === TOURNAMENT CARDS === */
.card {
  display: block;
  background: rgba(30, 41, 59, 0.9);
  border-radius: var(--radius);
  text-decoration: none;
  color: var(--text);
  padding: 25px 20px;
  box-shadow: var(--shadow);
  border: 1px solid rgba(59,130,246,0.3);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}
.card::before {
  content: "";
  position: absolute;
  top: -60%;
  left: -60%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle at 30% 30%, rgba(59,130,246,0.15), transparent 70%);
  opacity: 0;
  transition: opacity 0.4s;
}
.card:hover::before {
  opacity: 1;
}
.card:hover {
  border-color: var(--accent);
  background: rgba(59,130,246,0.08);
  box-shadow: 0 0 22px rgba(59,130,246,0.5);
  transform: translateY(-4px);
}
.card div:first-child {
  color: var(--accent-hover);
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 5px;
}
.card div:last-child {
  color: var(--muted);
  font-size: 0.9rem;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .wrap {
    padding: 25px;
  }
  h2 {
    font-size: 1.3rem;
  }
  .grid {
    gap: 18px;
  }
}
</style></head>
<body class="user-view">
  <div class="top">
    <div class="brand">🏏 All Tournaments</div>
    <div>
      <a class="logout" href="usermain.jsp">Home</a>
      &nbsp;
      <a class="logout" href="logout">Logout</a>
    </div>
  </div>

  <div class="wrap">
    <h2>Available Tournaments</h2>
    <% if (tournaments == null || tournaments.isEmpty()) { %>
      <p>No tournaments available.</p>
    <% } else { %>
      <div class="grid">
        <% for (Tournament t : tournaments) { %>
          <a class="card" href="tournamentdetails?tId=<%= t.getId() %>">
            <div style="font-size:18px;font-weight:700;"><%= t.getName() %></div>
            <div style="margin-top:6px;opacity:.85;">Format: <%= t.getFormat() %></div>
          </a>
        <% } %>
      </div>
    <% } %>
  </div>

  <script>
    // Prevent navigation caching
    window.history.replaceState && window.history.replaceState(null, "", window.location.href);
    window.onpopstate = function(){ window.history.pushState(null, "", window.location.href); };
  </script>
</body>
</html>
