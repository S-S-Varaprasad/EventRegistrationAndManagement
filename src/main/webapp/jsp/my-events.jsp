<%@ page import="java.util.*, com.event.model.Event, com.event.service.EventService, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
List<Event> list = (List<Event>) request.getAttribute("events");
EventService service = new EventService();
User user = (User) session.getAttribute("user");
String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My registrations &middot; Event Management</title>
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
      <a href="<%= request.getContextPath() %>/home">Dashboard</a>
      <a href="<%= request.getContextPath() %>/notifications" class="bell" id="notif-bell">&#128276;<span class="notif-badge" id="notif-badge"></span></a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <h1>My <em>registrations.</em></h1>
      <div class="meta"><%= list == null ? 0 : list.size() %> active registrations</div>
    </div>
  </div>

  <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

  <% if (list == null || list.isEmpty()) { %>
    <div class="empty">
      <h3>Nothing here yet.</h3>
      <p>You haven't registered for any events.</p>
      <a href="<%= request.getContextPath() %>/view-events" class="btn btn-primary" style="margin-top:16px">Browse events</a>
    </div>
  <% } else {
      for (Event e : list) {
        boolean waitlisted = false;
        if (user != null) { waitlisted = service.isWaitlisted(user.getId(), e.getId()); }
  %>
    <div class="event-card">
      <div class="ec-head">
        <div>
          <h3><%= e.getTitle() %></h3>
          <div style="font-size:13px; color:var(--ink-mute); margin-top:4px;">
            Organized by: <strong><%= e.getOrganizerName() != null ? e.getOrganizerName() : "Unknown Organizer" %></strong>
            <% if (e.getOrganizerType() != null && !e.getOrganizerType().trim().isEmpty()) { %>
                (<%= e.getOrganizerType() %>)
            <% } %>
          </div>
          <div class="badges" style="margin-top:8px">
            <% if (waitlisted) { %>
              <span class="badge badge-wait">Waitlisted</span>
            <% } else { %>
              <span class="badge badge-ink">Registered</span>
            <% } %>
          </div>
        </div>
      </div>

      <div class="meta">
        <div><div class="k">Date</div><div class="v"><%= e.getEventDate() %></div></div>
        <div><div class="k">Location</div><div class="v"><%= e.getLocation() %></div></div>
      </div>

      <div class="desc"><%= e.getDescription() %></div>

      <div class="actions">
        <% 
           if ("TEAM".equals(e.getEventType())) {
              com.event.dao.TeamDAO tDao = new com.event.dao.TeamDAO();
              Integer tid = tDao.getTeamIdByLeaderAndEvent(user.getId(), e.getId());
              if (tid != null) {
                 int mCount = 1 + tDao.getMemberCount(tid);
        %>
           <div style="margin-bottom:15px; padding:12px; background:var(--paper-2); border:1px solid var(--rule); border-radius:8px;">
               <div style="font-size:12px; text-transform:uppercase; color:var(--ink-mute); font-weight:600; letter-spacing:0.5px;">Team Registered</div>
               <div style="font-size:18px; font-weight:700; color:var(--primary); margin:4px 0;"><%= tDao.getTeamNameById(tid) %></div>
               <div style="font-size:13px; color:var(--ink-soft);"><%= mCount %> Total Participants (1 Leader + <%= mCount-1 %> Members)</div>
           </div>
           <a href="<%= request.getContextPath() %>/manage-team?teamId=<%= tid %>" class="btn btn-soft">Manage Team</a>
        <%    } 
           } 
        %>
        <form action="<%= request.getContextPath() %>/cancel-registration" method="post" style="display:inline;" onsubmit="return confirm('Are you sure you want to cancel your registration?');">
          <input type="hidden" name="eventId" value="<%= e.getId() %>">
          <button type="submit" class="btn btn-danger">Cancel registration</button>
        </form>
      </div>
    </div>
  <% } } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Registration tracker</span>
</div></div></footer>

<script>
fetch('<%= request.getContextPath() %>/notification-count')
  .then(function(r){return r.text();})
  .then(function(c){var n=parseInt(c);if(n>0){var b=document.getElementById('notif-badge');b.textContent=n;b.style.display='block';}})
  .catch(function(){});
</script>
</body>
</html>