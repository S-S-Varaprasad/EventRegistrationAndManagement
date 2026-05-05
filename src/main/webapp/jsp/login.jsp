<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");
String success = request.getParameter("success");
String redirect = request.getParameter("redirect");

if (session.getAttribute("user") != null) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Sign in &middot; Event Management</title>
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
  <div class="auth-card">
    <div class="eyebrow">Account &middot; sign in</div>
    <h2>Welcome <em>back.</em></h2>
    <p class="sub">Use your registered email to access your dashboard, tickets and notifications.</p>

    <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>
    <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

    <form action="<%= request.getContextPath() %>/login" method="post">
      <% if (redirect != null && !redirect.isEmpty()) { %>
        <input type="hidden" name="redirect" value="<%= redirect %>">
      <% } %>
      <div class="form-group">
        <label>Email address</label>
        <input type="email" name="email" required autocomplete="email" placeholder="you@example.com">
      </div>
      <div class="form-group">
        <label>Password</label>
        <input type="password" name="password" required>
      </div>
      <button type="submit" class="btn btn-ink btn-block" style="margin-top:6px">Sign in</button>
    </form>

    <div class="auth-foot">
      Don't have an account? <a href="register.jsp">Register here</a>
    </div>
  </div>
</div>

<footer>
  <div class="wrap"><div class="foot-row">
    <span>&copy; Event Registration &amp; Management System</span>
    <span>Sign-in &middot; secured session</span>
  </div></div>
</footer>

</body>
</html>