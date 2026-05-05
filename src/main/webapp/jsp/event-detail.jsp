<%@ page import="com.event.model.Event" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
Event event = (Event) request.getAttribute("event");
String orgName = (String) request.getAttribute("orgName");
int registeredCount = (Integer) request.getAttribute("registeredCount");
boolean isRegistered = (Boolean) request.getAttribute("isRegistered");
boolean isWaitlisted = (Boolean) request.getAttribute("isWaitlisted");
boolean loggedIn = (Boolean) request.getAttribute("loggedIn");
boolean isFull = event.getAvailableSeats() <= 0;
boolean isPaid = "PAID".equals(event.getParticipationMode()) || "PAID".equals(event.getEventType());
boolean isTeam = "TEAM".equals(event.getEventType());
boolean isPast = event.getEventDate().before(new java.sql.Date(System.currentTimeMillis()));
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%= event.getTitle() %> &middot; Event Management</title>
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
      <a href="<%= request.getContextPath() %>/view-events">&larr; All events</a>
    </div>
  </div>
</nav>

<main class="wrap-mid" style="padding-top:32px;padding-bottom:48px;flex:1">
  <div style="background:var(--paper);border:var(--line);border-radius:12px;padding:32px;box-shadow:var(--shadow-sm);">
    
    <div style="margin-bottom:24px">
      <div class="badges" style="margin-bottom:12px">
        <% if (isPast) { %><span class="badge badge-line">PAST EVENT</span><% } %>
        <% if (isPaid) { %><span class="badge badge-paid">PAID - &#8377;<%= String.format("%.0f", event.getPrice()) %></span><% } else { %><span class="badge badge-open">FREE</span><% } %>
        <% if (isTeam) { %><span class="badge badge-ink">TEAM EVENT</span><% } else { %><span class="badge badge-line">INDIVIDUAL</span><% } %>
        
        <% if ("OPEN".equals(event.getEligibility())) { %>
            <span class="badge badge-line">Open to All</span>
        <% } else if ("COLLEGE_ONLY".equals(event.getEligibility())) { %>
            <span class="badge badge-wait">College Only</span>
        <% } else if ("COMPANY_ONLY".equals(event.getEligibility())) { %>
            <span class="badge badge-warn">Company Only</span>
        <% } %>
        
        <% if (isFull && !isPast) { %><span class="badge badge-full">FULL</span><% } %>
      </div>

      <h1 style="font-family:var(--ff-head);font-weight:700;font-size:32px;letter-spacing:-.02em;margin-bottom:8px;line-height:1.2">
        <%= event.getTitle() %>
      </h1>
      <div style="color:var(--ink-soft);font-size:15px">
        Organized by <strong><%= orgName %></strong>
        <% if (event.getOrganizerType() != null && !event.getOrganizerType().trim().isEmpty()) { %>
            (<%= event.getOrganizerType() %>)
        <% } %>
      </div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:24px">
      <div style="background:var(--paper-2);border-radius:8px;padding:16px">
        <div style="font-size:12px;text-transform:uppercase;font-weight:600;color:var(--ink-soft);margin-bottom:4px">Date</div>
        <div style="font-size:16px;font-weight:500;color:var(--ink)"><%= event.getEventDate() %></div>
      </div>
      <div style="background:var(--paper-2);border-radius:8px;padding:16px">
        <div style="font-size:12px;text-transform:uppercase;font-weight:600;color:var(--ink-soft);margin-bottom:4px">Location</div>
        <div style="font-size:16px;font-weight:500;color:var(--ink)"><%= event.getLocation() %></div>
      </div>
      <div style="background:var(--paper-2);border-radius:8px;padding:16px">
        <div style="font-size:12px;text-transform:uppercase;font-weight:600;color:var(--ink-soft);margin-bottom:4px">Registrations</div>
        <div style="font-size:16px;font-weight:500;color:var(--ink)"><%= registeredCount %> / <%= event.getCapacity() %></div>
        <div style="height:6px;background:var(--line);border-radius:3px;margin-top:8px;overflow:hidden">
          <div style="height:100%;background:<%= isFull ? "var(--coral)" : "var(--primary)" %>;width:<%= (event.getCapacity() > 0) ? (registeredCount * 100 / event.getCapacity()) : 0 %>%;"></div>
        </div>
      </div>
      <div style="background:var(--paper-2);border-radius:8px;padding:16px">
        <div style="font-size:12px;text-transform:uppercase;font-weight:600;color:var(--ink-soft);margin-bottom:4px">Available Seats</div>
        <div style="font-size:20px;font-weight:600;color:<%= isFull ? "var(--coral)" : "var(--primary)" %>"><%= event.getAvailableSeats() %></div>
      </div>
    </div>

    <% if (isTeam) { %>
      <div style="background:#f0f9ff;border:1px solid #bae6fd;border-radius:8px;padding:16px;margin-bottom:24px">
        <h4 style="color:#0369a1;font-size:15px;margin-bottom:4px">Team Requirements</h4>
        <p style="color:#0284c7;font-size:14px">Min size: <strong><%= event.getMinTeamSize() %></strong> &middot; Max size: <strong><%= event.getMaxTeamSize() %></strong></p>
      </div>
    <% } %>

    <div style="border-top:var(--line);padding-top:24px;margin-bottom:32px">
      <h3 style="font-size:18px;font-weight:600;margin-bottom:12px">About this event</h3>
      <div style="font-size:16px;line-height:1.6;color:var(--ink-soft)">
        <%= event.getDescription() != null ? event.getDescription() : "No description provided." %>
      </div>
    </div>

    <div style="background:var(--paper-2);border:var(--line);border-radius:8px;padding:24px;text-align:center">
      <% if (isPast) { %>
          <h3 style="font-size:18px;font-weight:600;margin-bottom:8px">This event has ended</h3>
          <p style="color:var(--ink-soft);margin-bottom:16px">Registrations are closed for past events.</p>
          <a href="<%= request.getContextPath() %>/view-events" class="btn btn-soft">Browse other events</a>

      <% } else if (!loggedIn) { %>
          <h3 style="font-size:18px;font-weight:600;margin-bottom:8px">Want to register?</h3>
          <p style="color:var(--ink-soft);margin-bottom:16px">Sign in to your account to register for this event.</p>
          <a href="<%= request.getContextPath() %>/jsp/login.jsp?redirect=event?id=<%= event.getId() %>" class="btn btn-primary">Sign in to register</a>

      <% } else if (isRegistered) { %>
          <h3 style="font-size:18px;font-weight:600;margin-bottom:8px">You are registered!</h3>
          <p style="color:var(--ink-soft);margin-bottom:16px">You have already registered for this event. Check your tickets for entry details.</p>
          <a href="<%= request.getContextPath() %>/my-tickets" class="btn btn-ink">View my tickets</a>

      <% } else if (isWaitlisted) { %>
          <h3 style="font-size:18px;font-weight:600;margin-bottom:8px">You are on the waitlist</h3>
          <p style="color:var(--ink-soft);margin-bottom:16px">You will be automatically promoted when a spot opens up.</p>
          <a href="<%= request.getContextPath() %>/my-events" class="btn btn-wait">View my registrations</a>

      <% } else if (isTeam || isPaid || (event.getCustomFormSchema() != null && event.getCustomFormSchema().length() > 2)) { %>
          <h3 style="font-size:18px;font-weight:600;margin-bottom:8px"><%= isFull ? "Event is full — Join waitlist" : "Register Now" %></h3>
          <p style="color:var(--ink-soft);margin-bottom:16px"><%= isPaid ? "This is a paid event. You will need to upload payment proof." : "Fill out the registration form to join." %></p>
          <form action="<%= request.getContextPath() %>/jsp/register-flow.jsp" method="get" style="display:inline;">
              <input type="hidden" name="eventId" value="<%= event.getId() %>">
              <button type="submit" class="btn <%= isFull ? "btn-warn" : "btn-primary" %>">
                  <%= isFull ? "Join waitlist" : "Complete registration &rarr;" %>
              </button>
          </form>

      <% } else if (isFull) { %>
          <h3 style="font-size:18px;font-weight:600;margin-bottom:8px">Event is full</h3>
          <p style="color:var(--ink-soft);margin-bottom:16px">All seats are taken. Join the waitlist and you will be auto-promoted when a spot opens.</p>
          <form action="<%= request.getContextPath() %>/register-event" method="post" style="display:inline;">
              <input type="hidden" name="eventId" value="<%= event.getId() %>">
              <button type="submit" class="btn btn-warn">Join waitlist</button>
          </form>

      <% } else { %>
          <h3 style="font-size:18px;font-weight:600;margin-bottom:8px">Register Now — It's Free!</h3>
          <p style="color:var(--ink-soft);margin-bottom:16px">Secure your spot instantly. A digital ticket will be generated for you.</p>
          <form action="<%= request.getContextPath() %>/register-event" method="post" style="display:inline;">
              <input type="hidden" name="eventId" value="<%= event.getId() %>">
              <button type="submit" class="btn btn-primary">Register for free</button>
          </form>
      <% } %>
    </div>
  </div>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Event Details</span>
</div></div></footer>

</body>
</html>
