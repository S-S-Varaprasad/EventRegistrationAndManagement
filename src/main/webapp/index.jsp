<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
if (session.getAttribute("user") != null) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Event Management System</title>
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
      <a href="<%= request.getContextPath() %>/view-events">Browse Events</a>
      <a href="<%= request.getContextPath() %>/jsp/login.jsp">Sign in</a>
      <a href="<%= request.getContextPath() %>/jsp/register.jsp" class="btn btn-tiny btn-primary" style="color: #000;">Register</a>
    </div>
  </div>
</nav>

<section class="thin">
  <div class="wrap">
    <div class="eyebrow">A platform for organizers &amp; attendees</div>
    <h1 style="font-family:var(--ff-head);font-weight:700;font-size:clamp(40px,6vw,72px);line-height:1.1;letter-spacing:-.03em;margin-bottom:24px;max-width:14ch">
      Event <em style="font-style:normal;color:var(--coral)">Management.</em>
    </h1>
    <p style="font-size:17px;color:var(--ink-soft);max-width:60ch;line-height:1.6;margin-bottom:28px">
      A centralized platform to discover, register, and manage events &mdash; college fests, corporate seminars and public activities. Digital tickets, automated waitlists and door check-in, all in one place.
    </p>
    <div style="display:flex;gap:12px;flex-wrap:wrap">
      <a href="<%= request.getContextPath() %>/jsp/register.jsp" class="btn btn-primary">Create an account &rarr;</a>
      <a href="<%= request.getContextPath() %>/view-events" class="btn btn-ghost">Browse events</a>
    </div>
  </div>
</section>

<section class="thin" style="background:var(--paper-2);border-top:var(--line);border-bottom:var(--line)">
  <div class="wrap">
    <div class="eyebrow">What you can do</div>
    <div class="dash-grid" style="margin-top:14px">
      <div class="dash-card">
        <div class="num">01 &middot; Attendees</div>
        <h3>Browse &amp; register</h3>
        <p>Filter events by date, location, eligibility and format. Register instantly, or join a waitlist that auto-promotes when seats free up.</p>
      </div>
      <div class="dash-card">
        <div class="num">02 &middot; Attendees</div>
        <h3>Digital tickets</h3>
        <p>Every confirmed registration generates a ticket with a unique barcode. Show it at the venue &mdash; no printing, no email hunting.</p>
      </div>
      <div class="dash-card">
        <div class="num">03 &middot; Organizers</div>
        <h3>Publish &amp; manage</h3>
        <p>Create an organization, publish events with capacity, pricing, eligibility and team rules. Edit, hide or delete in one click.</p>
      </div>
      <div class="dash-card">
        <div class="num">04 &middot; Organizers</div>
        <h3>Verify &amp; check-in</h3>
        <p>Approve payment proofs, scan tickets at the door, watch the live attendance count, export the full data set as CSV.</p>
      </div>
    </div>
  </div>
</section>

<footer>
  <div class="wrap">
    <div class="foot-row">
      <span>&copy; Event Registration &amp; Management System</span>
      <span>Built for organizers, attendees and the door queue.</span>
    </div>
  </div>
</footer>

</body>
</html>