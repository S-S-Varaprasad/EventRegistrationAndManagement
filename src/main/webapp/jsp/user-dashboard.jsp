<%@ page import="com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
User user = (User) session.getAttribute("user");
if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Dashboard &middot; Event Management</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>

<nav class="bar">
  <div class="bar-row">
    <a href="<%= request.getContextPath() %>/home" class="logo">
      <span class="logo-mark">E</span>
      <span class="logo-name">Event Management</span>
    </a>
    <div class="nav-links">
      <a href="<%= request.getContextPath() %>/view-events">Browse events</a>
      <a href="<%= request.getContextPath() %>/my-events">My registrations</a>
      <a href="<%= request.getContextPath() %>/my-tickets">Tickets</a>
      <a href="<%= request.getContextPath() %>/notifications" class="bell" id="notif-bell">&#128276;<span class="notif-badge" id="notif-badge"></span></a>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-top:32px;padding-bottom:48px;flex:1">
  <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>

  <div class="welcome">
    <div>
      <div class="stamp">User dashboard</div>
      <h2 style="margin-top:10px">Welcome,<br><em><%= user.getName() %>.</em></h2>
      <p>Manage your event registrations, view your digital tickets and update your profile from here.</p>
    </div>
  </div>

  <div class="dash-grid">
    <div class="dash-card">
      <div class="num">01 &middot; Discover</div>
      <h3>Browse events</h3>
      <p>View all public events available for registration. Check capacities and register instantly.</p>
      <a href="<%= request.getContextPath() %>/view-events" class="btn btn-primary">Browse all events</a>
    </div>
    <div class="dash-card">
      <div class="num">02 &middot; Track</div>
      <h3>My registrations</h3>
      <p>View the events you have successfully registered for, plus your current waitlist status.</p>
      <a href="<%= request.getContextPath() %>/my-events" class="btn btn-soft">View my events</a>
    </div>
    <div class="dash-card">
      <div class="num">03 &middot; Attend</div>
      <h3>My tickets</h3>
      <p>Access your digital ticket wallet for check-in at the venue. Generated automatically when registration is approved.</p>
      <a href="<%= request.getContextPath() %>/my-tickets" class="btn btn-ink">View tickets</a>
    </div>
  </div>

  <div class="dash-callout">
    <div>
      <div class="t">Want to host your own events?</div>
      <div class="s">Upgrade to organizer status by registering an organization. Same login &mdash; new toolkit.</div>
    </div>
    <a href="<%= request.getContextPath() %>/jsp/create-organization.jsp" class="btn btn-primary">Create organization</a>
  </div>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Signed in as <%= user.getName() %></span>
</div></div></footer>

<script>
fetch('<%= request.getContextPath() %>/notification-count')
  .then(function(r){return r.text();})
  .then(function(c){var n=parseInt(c);if(n>0){var b=document.getElementById('notif-badge');b.textContent=n;b.style.display='block';}})
  .catch(function(){});
</script>
</body>
</html>