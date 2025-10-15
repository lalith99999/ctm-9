<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String role = (String) session.getAttribute("role");
    if ("admin".equalsIgnoreCase(role)) {
        response.sendRedirect("adminmain.jsp");
        return;
    }
    if ("viewer".equalsIgnoreCase(role)) {
        response.sendRedirect("usermain.jsp");
        return;
    }

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cricket Tournament Login</title>

<style>
/* === THEME VARIABLES === */
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.9);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --danger: #ef4444;
  --success: #22c55e;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 14px;
  --shadow: 0 4px 25px rgba(0, 0, 0, 0.5);
  --font: "Poppins", "Segoe UI", sans-serif;
}

/* === PAGE BACKGROUND === */
body {
  margin: 0;
  font-family: var(--font);
  color: var(--text);
  background: var(--bg-main);
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* === HEADER === */
header {
  text-align: center;
  font-size: 1.8rem;
  font-weight: 700;
  margin-top: 40px;
  color: var(--accent-hover);
  letter-spacing: 0.5px;
  text-shadow: 0 0 8px rgba(59,130,246,0.5);
}

/* === LOGIN CONTAINER === */
.container {
  background: var(--card-bg);
  padding: 40px 50px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  width: 90%;
  max-width: 420px;
  margin-top: 40px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(59,130,246,0.3);
  animation: fadeIn 1s ease-in;
}

/* === FORM ELEMENTS === */
form {
  display: flex;
  flex-direction: column;
}
h2 {
  text-align: center;
  color: var(--accent-hover);
  margin-bottom: 20px;
}
label {
  font-weight: 600;
  margin-top: 10px;
}
input {
  background: rgba(15, 23, 42, 0.8);
  color: var(--text);
  border: 1px solid #334155;
  border-radius: var(--radius);
  padding: 10px 12px;
  font-size: 1rem;
  margin-top: 6px;
  outline: none;
  transition: 0.3s;
}
input:focus {
  border-color: var(--accent);
  box-shadow: 0 0 10px var(--accent);
}

/* === BUTTONS === */
button {
  border: none;
  border-radius: var(--radius);
  font-weight: 600;
  padding: 12px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 15px;
}
.viewer-btn {
  background: var(--accent);
  color: white;
}
.viewer-btn:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 12px rgba(96,165,250,0.6);
}
.admin-btn {
  background: #1e40af;
  color: white;
}
.admin-btn:hover {
  background: #3b82f6;
  box-shadow: 0 0 12px rgba(96,165,250,0.7);
}

/* === ALERT MESSAGES === */
.ok, .error {
  text-align: center;
  border-radius: var(--radius);
  font-weight: 600;
  padding: 10px;
  margin-top: 5px;
}
.ok {
  background: rgba(34,197,94,0.15);
  border-left: 5px solid var(--success);
}
.error {
  background: rgba(239,68,68,0.15);
  border-left: 5px solid var(--danger);
}

/* === REGISTER LINK === */
.register-line {
  text-align: center;
  margin-top: 18px;
  color: var(--muted);
}
.register-line a {
  color: var(--accent-hover);
  text-decoration: none;
  font-weight: 600;
}
.register-line a:hover {
  text-decoration: underline;
}

/* === FOOTER === */
footer {
  margin-top: auto;
  padding: 20px;
  text-align: center;
  font-size: 0.9rem;
  color: var(--muted);
}

/* === ANIMATIONS === */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* === RESPONSIVE === */
@media (max-width: 500px) {
  .container {
    padding: 30px;
  }
  header {
    font-size: 1.4rem;
  }
}
</style>
    <script src="resources/js/index.js"></script>
</head>
<body class="auth-page">

    <header>🏏 Cricket Tournament Manager</header>

    <div class="container">
        <form action="./login" method="post">
            <h2>Welcome Back</h2>

           
            <%
                String okMsg = request.getParameter("okMsg");
                String errorMsg = (String) request.getAttribute("errorMsg");
                if (okMsg != null && okMsg.trim().length() > 0) {
            %>
                <p class="ok"><%= okMsg %></p>
            <%
                }
                if (errorMsg != null && errorMsg.trim().length() > 0) {
            %>
                <p class="error"><%= errorMsg %></p>
            <%
                }
            %>

            <label>Username</label>
            <input type="text" id="username" name="username" placeholder="Enter your username">

            <label>Password</label>
            <input type="password" id="password" name="password" placeholder="Enter your password">

            <input type="hidden" id="role" name="role">

            <button type="submit" class="viewer-btn" onclick="return validateLoginForm('viewer')">Login as Viewer</button>
            <button type="submit" class="admin-btn" onclick="return validateLoginForm('admin')">Login as Scorer</button>

            <p class="register-line">New user? <a href="register.jsp">Click here</a></p>
        </form>
    </div>

    <footer>⚡ Powered by Planon | Cricket Management Portal</footer>
</body>
</html>
