<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Prevent normal caching
  response.setHeader("Cache-Control","no-cache, no-store, must-revalidate");
  response.setHeader("Pragma","no-cache");
  response.setDateHeader("Expires",0);
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Register (Viewer)</title>
<style>
:root {
  --bg-main: linear-gradient(160deg, #0d1b2a, #1e3a8a);
  --card-bg: rgba(15, 23, 42, 0.95);
  --accent: #3b82f6;
  --accent-hover: #60a5fa;
  --text: #f8fafc;
  --muted: #94a3b8;
  --radius: 14px;
  --shadow: 0 4px 25px rgba(0,0,0,0.45);
  --font: "Poppins","Segoe UI",sans-serif;
}

/* === Base === */
body {
  margin: 0;
  font-family: var(--font);
  background: var(--bg-main);
  color: var(--text);
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* === Page container === */
.page {
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* === Card === */
.card {
  background: var(--card-bg);
  padding: 40px 45px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  width: 360px;
  text-align: center;
  animation: fadeIn 0.5s ease;
}
@keyframes fadeIn {
  from {opacity: 0; transform: translateY(-10px);}
  to {opacity: 1; transform: translateY(0);}
}

/* === Heading === */
.card h2 {
  color: var(--accent-hover);
  font-size: 1.6rem;
  margin-bottom: 10px;
  text-shadow: 0 0 10px rgba(59,130,246,0.4);
}

/* === Rule text === */
.rule {
  font-size: 0.9rem;
  color: var(--muted);
  margin-bottom: 20px;
}

/* === Fields === */
.field {
  margin-bottom: 18px;
  text-align: left;
}
label {
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--accent-hover);
}
input {
  width: 100%;
  padding: 10px 12px;
  margin-top: 5px;
  border: 1px solid rgba(59,130,246,0.3);
  border-radius: var(--radius);
  background: rgba(30,41,59,0.8);
  color: var(--text);
  font-size: 0.95rem;
  transition: 0.3s;
}
input:focus {
  outline: none;
  border-color: var(--accent-hover);
  box-shadow: 0 0 8px rgba(59,130,246,0.5);
}

/* === Buttons === */
.btn-primary {
  width: 100%;
  background: var(--accent);
  border: none;
  color: white;
  font-weight: 600;
  padding: 10px 14px;
  border-radius: var(--radius);
  cursor: pointer;
  transition: 0.3s;
}
.btn-primary:hover {
  background: var(--accent-hover);
  box-shadow: 0 0 12px rgba(96,165,250,0.6);
}

/* === Links === */
.links {
  margin-top: 18px;
}
.links a {
  color: var(--accent-hover);
  text-decoration: none;
  font-weight: 600;
  transition: 0.3s;
}
.links a:hover {
  text-shadow: 0 0 8px rgba(96,165,250,0.6);
}

/* === Responsive === */
@media (max-width: 480px) {
  .card { width: 90%; padding: 30px; }
  h2 { font-size: 1.3rem; }
}
</style>  <script src="resources/js/register.js"></script>
</head>
<body class="auth-page">
  <!-- your existing HTML form unchanged -->
  <div class="page">
    <div class="card">
      <h2>Register as Viewer</h2>
      <p class="rule">Password rule: <b>minimum 8 characters</b>, include at least <b>1 Capital letter</b> and <b>1 Special character</b>.</p>

      <form action="register" method="post">
        <div class="field">
          <label>Username</label>
          <input type="text" name="uname" placeholder="Enter username">
        </div>

        <div class="field">
          <label>Password</label>
          <input type="password" name="pass" placeholder="Min 8 chars, 1 Capital, 1 Special">
        </div>

        <div class="field">
          <label>Re-enter Password</label>
          <input type="password" name="repass" placeholder="Re-enter password">
        </div>

        <button class="btn btn-primary" type="submit">Submit</button>
      </form>

      <div class="links">
        <a href="index.jsp">Back to Login</a>
      </div>
    </div>
  </div>
</body>
</html>
