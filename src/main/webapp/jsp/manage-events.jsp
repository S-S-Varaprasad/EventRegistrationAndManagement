<%@ page import="java.util.*, com.event.model.Event" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
List<Event> list = (List<Event>) request.getAttribute("orgEvents");
Map<Integer, Double> revenueMap = (Map<Integer, Double>) request.getAttribute("revenueMap");
String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Manage events &middot; Event Management</title>
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
      <a href="<%= request.getContextPath() %>/verify-payments" style="color:var(--warn-dark);font-weight:600">Review Payments</a>
      <a href="<%= request.getContextPath() %>/manage-refunds" style="color:var(--coral);font-weight:600">Pending Refunds</a>
      <a href="<%= request.getContextPath() %>/jsp/add-event.jsp" class="btn btn-tiny btn-primary">+ New Event</a>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <h1>My <em>events.</em></h1>
      <div class="meta"><%= list == null ? 0 : list.size() %> total &middot; published &amp; drafts</div>
    </div>
  </div>

  <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

  <!-- TELEMETRY DASHBOARD -->
  <%
      Integer totalEvents = (Integer) request.getAttribute("totalEvents");
      Integer totalRegistrations = (Integer) request.getAttribute("totalRegistrations");
      Integer totalWait = (Integer) request.getAttribute("totalWaitlistNetwork");
      Map<Integer, Integer> waits = (Map<Integer, Integer>) request.getAttribute("waitlistMap");
      Map<Integer, Integer> cancels = (Map<Integer, Integer>) request.getAttribute("cancelMap");
  %>
  <div class="dash-grid" style="margin-bottom:32px">
      <div class="dash-card">
          <div class="dc-title">Total Events Created</div>
          <div class="dc-val"><%= totalEvents != null ? totalEvents : 0 %></div>
      </div>
      <div class="dash-card">
          <div class="dc-title">Total Registrations (Slots)</div>
          <div class="dc-val" style="color:var(--primary)"><%= totalRegistrations != null ? totalRegistrations : 0 %></div>
      </div>
      <div class="dash-card">
          <div class="dc-title">Total Participants (People)</div>
          <div class="dc-val" style="color:var(--leaf)"><%= request.getAttribute("totalParticipants") != null ? request.getAttribute("totalParticipants") : 0 %></div>
      </div>
      <div class="dash-card">
          <div class="dc-title">People on Waitlist</div>
          <div class="dc-val" style="color:var(--coral)"><%= totalWait != null ? totalWait : 0 %></div>
      </div>
  </div>

  <% if (list == null || list.isEmpty()) { %>
    <div class="empty">
      <h3>No events yet.</h3>
      <p>Create your first event to start collecting registrations and managing attendance.</p>
      <a href="<%= request.getContextPath() %>/jsp/add-event.jsp" class="btn btn-primary" style="margin-top:16px">Create event &rarr;</a>
    </div>
  <% } else { for (Event e : list) { 
        boolean isHidden = "HIDDEN".equals(e.getStatus());
        int registeredCount = e.getCapacity() - e.getAvailableSeats();
        boolean isPaid = "PAID".equals(e.getParticipationMode());
        boolean isTeam = "TEAM".equals(e.getEventType());
        Double revObj = revenueMap != null ? revenueMap.get(e.getId()) : null;
        double revenue = revObj != null ? revObj : 0.0;
  %>
    <div class="event-card">
      <div class="ec-head">
        <div>
          <h3><%= e.getTitle() %></h3>
          <div class="badges" style="margin-top:8px">
            <% if (!isHidden) { %><span class="badge badge-open">Published &amp; Live</span><% } else { %><span class="badge badge-warn">Hidden &amp; Offline</span><% } %>
            <% if (isPaid) { %><span class="badge badge-paid">Paid</span><% } else { %><span class="badge badge-line">Free</span><% } %>
            <span class="badge badge-line"><%= e.getEventType() %></span>
          </div>
        </div>
        <% if (isPaid) { %>
          <div class="price">&#8377;<%= String.format("%.0f", e.getPrice()) %></div>
        <% } else { %><div class="price">Free</div><% } %>
      </div>

      <div class="meta" style="display:flex;gap:32px;flex-wrap:wrap">
        <div><div class="k">Date</div><div class="v"><%= e.getEventDate() %></div></div>
        <div><div class="k">Location</div><div class="v"><%= e.getLocation() %></div></div>
        <% if (isTeam) { %>
          <div>
            <div class="k">Teams Registered</div>
            <div class="v"><%= registeredCount %> / <%= e.getCapacity() %> teams</div>
          </div>
          <div>
            <div class="k">Team Size</div>
            <div class="v"><%= e.getMinTeamSize() %> &ndash; <%= e.getMaxTeamSize() %> members</div>
          </div>
          <div>
            <div class="k">Available Team Slots</div>
            <div class="v" style="color:<%= e.getAvailableSeats() == 0 ? "var(--warn-dark)" : "var(--primary)" %>">
              <%= e.getAvailableSeats() == 0 ? "FULL" : e.getAvailableSeats() + " slots" %>
            </div>
          </div>
        <% } else { %>
          <div>
            <div class="k">People Registered</div>
            <div class="v"><%= registeredCount %> / <%= e.getCapacity() %></div>
          </div>
          <div>
            <div class="k">Available Seats</div>
            <div class="v" style="color:<%= e.getAvailableSeats() == 0 ? "var(--warn-dark)" : "var(--primary)" %>">
              <%= e.getAvailableSeats() == 0 ? "FULL" : e.getAvailableSeats() %>
            </div>
          </div>
        <% } %>
        <% if (isPaid) { %>
          <div><div class="k">Verified Revenue</div><div class="v" style="color:var(--primary)">₹<%= String.format("%.0f", revenue) %></div></div>
        <% } %>
      </div>

      <div class="actions" style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px">
        <form action="<%= request.getContextPath() %>/toggle-event-status" method="post" style="display:inline;">
            <input type="hidden" name="eventId" value="<%= e.getId() %>">
            <% if (isHidden) { %>
                <button type="submit" class="btn btn-primary btn-tiny">Publish Publicly</button>
            <% } else { %>
                <button type="submit" class="btn btn-ghost btn-tiny" onclick="return confirm('Hiding this event will remove it from the public page. Proceed?');">Hide Event</button>
            <% } %>
        </form>
        
        <div class="right" style="display:flex;gap:8px;flex-wrap:wrap">
            <button onclick="document.getElementById('broadcast-<%= e.getId() %>').style.display='block'" class="btn btn-soft btn-tiny" style="color:var(--coral);border-color:var(--coral)" title="Send message to all registered users">Broadcast</button>
            <a href="<%= request.getContextPath() %>/event-checkin?eventId=<%= e.getId() %>" class="btn btn-ink btn-tiny" title="Check-in attendees at venue">Check-In</a>
            <% if (!isPaid) { %>
            <a href="<%= request.getContextPath() %>/event-attendees?eventId=<%= e.getId() %>" class="btn btn-soft btn-tiny" title="View waitlist queue and cancellations">Waitlist</a>
            <% } %>
            <a href="<%= request.getContextPath() %>/jsp/edit-event.jsp?eventId=<%= e.getId() %>" class="btn btn-soft btn-tiny" title="Edit event details">Edit</a>
            <a href="<%= request.getContextPath() %>/export-data?eventId=<%= e.getId() %>" class="btn btn-soft btn-tiny" title="Export registration data">Export</a>
            <form action="<%= request.getContextPath() %>/delete-event" method="post" style="display:inline;" onsubmit="return confirm('WARNING: Are you absolutely sure? This drops all registrations permanently.');">
                <input type="hidden" name="eventId" value="<%= e.getId() %>">
                <button type="submit" class="btn btn-danger btn-tiny" title="Permanently delete this event">Delete</button>
            </form>
        </div>
      </div>

      <div id="broadcast-<%= e.getId() %>" class="dynamic-section" style="display:none; margin-top:20px; margin-bottom:0;">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
            <h3>Broadcast Message to Attendees</h3>
            <button onclick="document.getElementById('broadcast-<%= e.getId() %>').style.display='none'" class="btn btn-ghost btn-tiny">&times; Close</button>
        </div>
        <p class="hint">This message will be instantly sent to the notification inbox of all <%= registeredCount %> registered users.</p>
        <form action="<%= request.getContextPath() %>/broadcast-announcement" method="post">
            <input type="hidden" name="eventId" value="<%= e.getId() %>">
            <div class="form-group" style="margin-bottom:12px">
                <textarea name="message" placeholder="Type your announcement here (e.g., 'Venue changed to Hall B' or 'Event starts in 1 hour')..." required style="min-height:80px"></textarea>
            </div>
            <button type="submit" class="btn btn-primary btn-tiny">Send Broadcast</button>
        </form>
      </div>
    </div>
  <% } } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Manage Events</span>
</div></div></footer>

</body>
</html>
