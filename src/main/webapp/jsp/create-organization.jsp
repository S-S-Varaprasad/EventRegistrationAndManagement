<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");
if (session.getAttribute("user") == null) {
    response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Create Organization</title>
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
      <a href="<%= request.getContextPath() %>/home">&larr; Back to Dashboard</a>
    </div>
  </div>
</nav>

<main class="wrap-mid" style="padding-top:48px;padding-bottom:48px;flex:1">
  <div class="form-container">
    <div class="eyebrow">Setup</div>
    <h2>Create Organization</h2>
    <p class="sub" style="margin-bottom:24px">Register your institution or community group to start hosting events.</p>

    <% if (error != null) { %> <div class="msg error"><%= error %></div> <% } %>

    <form action="<%= request.getContextPath() %>/register-org" method="post">
      <div class="form-group">
        <label>Organization Name</label>
        <input type="text" name="name" required placeholder="Ex: IIT Bombay Cultural Committee">
      </div>

      <div class="form-group">
        <label>Organization Type</label>
        <select name="type" required>
          <option value="">-- Select Type --</option>
          <option value="COLLEGE">College or University</option>
          <option value="COMPANY">Company or Business</option>
          <option value="COMMUNITY">Community Group</option>
        </select>
      </div>

      <div class="btn-group">
        <a href="<%= request.getContextPath() %>/home" class="btn btn-soft">Cancel</a>
        <button type="submit" class="btn btn-primary">Create Organization</button>
      </div>
    </form>
  </div>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
</div></div></footer>

</body>
</html>