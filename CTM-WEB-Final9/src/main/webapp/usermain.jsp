<%@ page contentType="text/html; charset=UTF-8" %>
<%
  // Session guard
  String username = (String) session.getAttribute("username");
  String role = (String) session.getAttribute("role");
  if (username == null || role == null || !"viewer".equalsIgnoreCase(role)) {
      response.sendRedirect("index.jsp"); return;
  }
  // Disable caching
  response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Viewer Dashboard</title>
<style>
/* === THEME VARIABLES === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.92);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --success: #22c55e;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 14px;
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
}
.logout:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 10px rgba(96,165,250,0.5);
}

/* === MAIN WRAPPER === */
.wrap {
  width: 90%;
  max-width: 1100px;
  margin: 50px auto;
  background: var(--card-bg);
  padding: 40px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  text-align: center;
}

/* === HEADING === */
h2 {
  color: var(--accent-hover);
  font-size: 1.6rem;
  font-weight: 700;
  margin-bottom: 25px;
  text-shadow: 0 0 8px rgba(59,130,246,0.4);
}

/* === SUBTEXT / GREETING === */
.wrap p {
  color: var(--muted);
  font-size: 1rem;
  margin-bottom: 40px;
}

/* === DASHBOARD GRID === */
.dashboard {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 25px;
  justify-items: center;
}

/* === DASHBOARD CARDS === */
.card {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: rgba(30, 41, 59, 0.9);
  color: var(--text);
  text-decoration: none;
  padding: 30px 20px;
  width: 100%;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  border: 1px solid rgba(59,130,246,0.3);
  transition: all 0.3s ease;
}
.card:hover {
  background: rgba(59,130,246,0.1);
  border-color: var(--accent);
  box-shadow: 0 0 18px rgba(59,130,246,0.5);
  transform: translateY(-4px);
}
.card span {
  font-size: 1.8rem;
  margin-bottom: 10px;
}
.card h3 {
  margin: 0;
  color: var(--accent-hover);
  font-size: 1.1rem;
  font-weight: 600;
}

/* === RESPONSIVE === */
@media (max-width: 768px) {
  .wrap {
    padding: 25px;
  }
  h2 {
    font-size: 1.3rem;
  }
  .card {
    padding: 20px;
  }
}
</style>
</head>
<body class="user-view">
  <div class="top">
    <div class="brand"> Hello <b><%= username %></b></div>
    <a class="logout" href="logout">Logout</a>
  </div>

  <div class="wrap">
    <h2>Welcome to Cricket Viewer Portal</h2>

</body>
</html>
