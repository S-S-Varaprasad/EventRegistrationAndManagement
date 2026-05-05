<%@ page import="java.util.*, com.event.model.*, com.event.service.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
List<Event> events = (List<Event>) request.getAttribute("events");
User user = null; boolean isOrganizer = false;
HttpSession sess = request.getSession(false);
if (sess != null) { user = (User) sess.getAttribute("user"); }

EventService service = new EventService();
if (user != null) {
    OrganizationService orgService = new OrganizationService();
    isOrganizer = (orgService.getOrgByAdmin(user.getId()) != null);
}

String error = request.getParameter("error"); String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Browse events &middot; Event Management</title>
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
      <% if (user != null && !isOrganizer) { %>
      <a href="<%= request.getContextPath() %>/view-events">Browse Events</a>
      <% } %>
      <% if (user != null) { %>
      <a href="<%= request.getContextPath() %>/notifications" class="bell" id="notif-bell">&#128276;<span class="notif-badge" id="notif-badge"></span></a>
      <% } %>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <h1>Upcoming <em>events.</em></h1>
      <div class="meta"><%= events == null ? 0 : events.size() %> listed &middot; sorted by date</div>
    </div>
  </div>

  <form class="dynamic-section" style="display:flex; gap:12px; flex-wrap:wrap; padding:16px;" action="<%= request.getContextPath() %>/view-events" method="get">
    <input type="text" name="search" placeholder="Search by title..." value="<%= request.getParameter("search")!=null ? request.getParameter("search") : "" %>" style="flex:1; min-width:150px;">
    <input type="date" name="date" value="<%= request.getParameter("date")!=null ? request.getParameter("date") : "" %>" style="flex:1; min-width:150px;">
    <input type="text" name="location" placeholder="Location..." value="<%= request.getParameter("location")!=null ? request.getParameter("location") : "" %>" style="flex:1; min-width:150px;">
    <select name="eligibility" style="flex:1; min-width:150px;">
        <option value="">Any Eligibility</option>
        <option value="OPEN" <%= "OPEN".equals(request.getParameter("eligibility")) ? "selected" : "" %>>Open to All</option>
        <option value="COLLEGE_ONLY" <%= "COLLEGE_ONLY".equals(request.getParameter("eligibility")) ? "selected" : "" %>>College Only</option>
        <option value="COMPANY_ONLY" <%= "COMPANY_ONLY".equals(request.getParameter("eligibility")) ? "selected" : "" %>>Company Only</option>
    </select>
    <select name="event_type" style="flex:1; min-width:150px;">
        <option value="">Any Format</option>
        <option value="INDIVIDUAL" <%= "INDIVIDUAL".equals(request.getParameter("event_type")) ? "selected" : "" %>>Individual</option>
        <option value="TEAM" <%= "TEAM".equals(request.getParameter("event_type")) ? "selected" : "" %>>Team</option>
    </select>
    <div style="display:flex; gap:8px;">
      <button type="submit" class="btn btn-primary">Search</button>
      <a href="<%= request.getContextPath() %>/view-events" class="btn btn-soft">Clear</a>
    </div>
  </form>

  <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>
  <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

  <% if (events == null || events.isEmpty()) { %>
    <div class="empty">
      <h3>No events available right now.</h3>
      <p>Check back soon &mdash; new events are published regularly by our organizers.</p>
    </div>
  <% } else {
    for (Event e : events) {
      boolean registered = false; boolean waitlisted = false;
      boolean eligible = service.isEligible(user, e);
      boolean isFull = e.getAvailableSeats() <= 0;
      boolean isPaid = "PAID".equals(e.getEventType()) || "PAID".equals(e.getParticipationMode());
      if (user != null) {
          registered = service.isRegistered(user.getId(), e.getId());
          waitlisted = service.isWaitlisted(user.getId(), e.getId());
      }
      String elig = e.getEligibility();
  %>
    <div class="event-card">
      <div class="ec-head">
        <div>
          <h3><a href="<%= request.getContextPath() %>/event?id=<%= e.getId() %>" style="color:var(--ink); text-decoration:none;"><%= e.getTitle() %></a></h3>
          <div style="font-size:13px; color:var(--ink-mute); margin-top:4px;">
            Organized by: <strong><%= e.getOrganizerName() != null ? e.getOrganizerName() : "Unknown Organizer" %></strong>
            <% if (e.getOrganizerType() != null && !e.getOrganizerType().trim().isEmpty()) { %>
                (<%= e.getOrganizerType() %>)
            <% } %>
          </div>
          <div class="badges" style="margin-top:8px">
            <% if (registered) { %><span class="badge badge-ink">Registered</span><% } %>
            <% if (waitlisted) { %><span class="badge badge-wait">Waitlisted</span><% } %>
            <% if (isFull) { %><span class="badge badge-full">Full &middot; waitlist only</span>
            <% } else { %><span class="badge badge-open">Open (<%= e.getAvailableSeats() %> left)</span><% } %>
            <% if (isPaid) { %><span class="badge badge-paid">Paid</span><% } else { %><span class="badge badge-line">Free</span><% } %>
            <% if ("TEAM".equals(e.getEventType())) { %><span class="badge badge-line">Team</span><% } %>
            <span class="badge badge-line"><%= "OPEN".equals(elig) ? "Open to all" : elig %></span>
          </div>
        </div>
        <div class="price"><%= isPaid ? "&#8377;" + String.format("%.0f", e.getPrice()) : "Free" %></div>
      </div>

      <div class="meta">
        <div><div class="k">Date</div><div class="v"><%= e.getEventDate() %></div></div>
        <div><div class="k">Location</div><div class="v"><%= e.getLocation() %></div></div>
        <div><div class="k">Capacity</div><div class="v"><%= e.getCapacity() - e.getAvailableSeats() %> / <%= e.getCapacity() %></div></div>
        <% if ("TEAM".equals(e.getEventType())) { %><div><div class="k">Team size</div><div class="v"><%= e.getMinTeamSize() %>&ndash;<%= e.getMaxTeamSize() %></div></div><% } %>
      </div>

      <div class="desc"><%= e.getDescription() %></div>

      <div class="actions">
        <% if (user == null) { %>
            <a href="<%= request.getContextPath() %>/jsp/login.jsp?redirect=view-events" class="btn btn-soft">Sign in to register</a>
        <% } else if (isOrganizer) { %>
            <button class="btn btn-soft" disabled>Organizers cannot register</button>
        <% } else if (registered) { 
               if ("TEAM".equals(e.getEventType())) {
                   com.event.dao.TeamDAO tDao = new com.event.dao.TeamDAO();
                   Integer tid = tDao.getTeamIdByLeaderAndEvent(user.getId(), e.getId());
        %>
                   <a href="<%= request.getContextPath() %>/manage-team?teamId=<%= tid %>" class="btn btn-ink">Manage Team</a>
        <%     } else { %>
                   <a href="<%= request.getContextPath() %>/my-tickets" class="btn btn-ink">View My Ticket</a>
        <%     } %>
        <% } else if (waitlisted) { %>
            <button class="btn btn-soft" disabled>Currently on waitlist</button>
        <% } else if (!eligible) { %>
            <button class="btn btn-soft" disabled>Not eligible for event</button>
        <% } else if (isFull) { %>
            <form action="<%= request.getContextPath() %>/register-event" method="post" style="display:inline;">
                <input type="hidden" name="eventId" value="<%= e.getId() %>">
                <button type="submit" class="btn btn-warn">Register to Waitlist</button>
            </form>
        <% } else if ("TEAM".equals(e.getEventType()) || "PAID".equals(e.getParticipationMode()) || (e.getCustomFormSchema() != null && e.getCustomFormSchema().length() > 2)) { %>
            <form action="<%= request.getContextPath() %>/jsp/register-flow.jsp" method="get" style="display:inline;">
                <input type="hidden" name="eventId" value="<%= e.getId() %>">
                <button type="submit" class="btn btn-primary">Complete registration &rarr;</button>
            </form>
        <% } else { %>
            <form action="<%= request.getContextPath() %>/register-event" method="post" style="display:inline;">
                <input type="hidden" name="eventId" value="<%= e.getId() %>">
                <button type="submit" class="btn btn-primary">Register now &rarr;</button>
            </form>
        <% } %>

        <% if (user != null && !isOrganizer && !registered && !waitlisted) { %>
            <div class="right">
                <form action="<%= request.getContextPath() %>/report-event" method="post" style="display:inline;">
                    <input type="hidden" name="eventId" value="<%= e.getId() %>">
                    <button type="submit" class="btn btn-danger btn-tiny">Report Issue</button>
                </form>
            </div>
        <% } %>
      </div>
    </div>
  <% } } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Listings update in real time</span>
</div></div></footer>

<% if (user != null) { %>
<script>
fetch('<%= request.getContextPath() %>/notification-count')
  .then(function(r){return r.text();})
  .then(function(c){var n=parseInt(c);if(n>0){var b=document.getElementById('notif-badge');b.textContent=n;b.style.display='block';}})
  .catch(function(){});
</script>
<% } %>
</body>
</html>