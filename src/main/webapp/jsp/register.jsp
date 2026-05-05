<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");

if (session.getAttribute("user") != null) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Create account &middot; Event Management</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>

<nav class="bar">
  <div class="bar-row">
    <a href="<%= request.getContextPath() %>/" class="logo">
      <span class="logo-mark">E</span>
      <span class="logo-name">Event Management</span>
    </a>
    <div class="nav-links">
      <a href="<%= request.getContextPath() %>/">&larr; Back to home</a>
    </div>
  </div>
</nav>

<div class="auth-shell">
  <div class="auth-card" style="max-width:480px">
    <div class="eyebrow">Account &middot; new</div>
    <h2>Create an <em>account.</em></h2>
    <p class="sub">One account works as both attendee and organizer &mdash; just create an organization later if you want to host events.</p>

    <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>

    <form action="<%= request.getContextPath() %>/register-user" method="post">
      <div class="form-group">
        <label>Full name</label>
        <input type="text" name="name" required autocomplete="name">
      </div>
      <div class="form-group">
        <label>Email address</label>
        <input type="email" name="email" required autocomplete="email" placeholder="you@example.com">
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" required>
      </div>
      <div class="form-group">
        <label>User type</label>
        <select name="user_type" required>
          <option value="">&mdash; Select type &mdash;</option>
          <option value="COLLEGE">College student</option>
          <option value="COMPANY">Company employee</option>
          <option value="PUBLIC">General public</option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary btn-block" style="margin-top:6px">Register</button>
    </form>

    <div class="auth-foot">
      Already have an account? <a href="login.jsp">Sign in here</a>
    </div>
  </div>
</div>

<footer>
  <div class="wrap"><div class="foot-row">
    <span>&copy; Event Registration &amp; Management System</span>
    <span>Free &middot; no card &middot; one minute</span>
  </div></div>
</footer>

</body>
</html>