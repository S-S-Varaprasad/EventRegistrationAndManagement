<%@ page import="com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
User user = (User) session.getAttribute("user");
if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Organizer dashboard &middot; Event Management</title>
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
      <a href="<%= request.getContextPath() %>/manage-events">Manage events</a>
      <a href="<%= request.getContextPath() %>/notifications" class="bell" id="notif-bell">&#128276;<span class="notif-badge" id="notif-badge"></span></a>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-top:32px;padding-bottom:48px;flex:1">
  <div class="welcome">
    <div>
      <div class="stamp">Organizer dashboard</div>
      <h2 style="margin-top:10px">Welcome back,<br><em><%= user.getName() %>.</em></h2>
      <p>Create new events, manage registrations and review payments &mdash; all from this hub.</p>
    </div>
  </div>

  <div class="dash-grid">
    <div class="dash-card">
      <div class="num">01 &middot; Publish</div>
      <h3>Create event</h3>
      <p>Add a new event. Set the date, location, ticket price, eligibility and capacity for registrations.</p>
      <a href="<%= request.getContextPath() %>/jsp/add-event.jsp" class="btn btn-primary">Create new event</a>
    </div>
    <div class="dash-card">
      <div class="num">02 &middot; Operate</div>
      <h3>Manage events</h3>
      <p>View all your published events. Track registrations, edit details, hide or delete, and export data.</p>
      <a href="<%= request.getContextPath() %>/manage-events" class="btn btn-ink">Manage my events</a>
    </div>
    <div class="dash-card">
      <div class="num">03 &middot; Verify</div>
      <h3>Payment queue</h3>
      <p>Review payment proofs for paid events. Approve or reject &mdash; rejections free the seat for the next on the waitlist.</p>
      <a href="<%= request.getContextPath() %>/verify-payments" class="btn btn-warn">Open queue</a>
    </div>
  </div>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Organizer mode</span>
</div></div></footer>

<script>
fetch('<%= request.getContextPath() %>/notification-count')
  .then(function(r){return r.text();})
  .then(function(c){var n=parseInt(c);if(n>0){var b=document.getElementById('notif-badge');b.textContent=n;b.style.display='block';}})
  .catch(function(){});
</script>
</body>
</html>