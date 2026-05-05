<%@ page import="java.util.List, com.event.model.Ticket, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    
    List<Ticket> cancelledTickets = (List<Ticket>) request.getAttribute("cancelledTickets");
    String eventTitle = (String) request.getAttribute("eventTitle");
    Integer eventId = (Integer) request.getAttribute("eventId");
    Boolean isPaid = (Boolean) request.getAttribute("isPaid");
    if (isPaid == null) isPaid = false;
    Double eventPrice = (Double) request.getAttribute("eventPrice");
    if (eventPrice == null) eventPrice = 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cancelled Registrations &middot; <%= eventTitle %></title>
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
      <a href="<%= request.getContextPath() %>/manage-events">&larr; Back to Dashboard</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <div class="eyebrow">Analytics &middot; <%= isPaid ? "Refund Management" : "Cancellations" %></div>
      <h1>Cancelled <em>Registrations.</em></h1>
      <% if (eventTitle != null) { %><div class="meta"><%= eventTitle %></div><% } %>
    </div>
  </div>

  <% if (cancelledTickets == null || cancelledTickets.isEmpty()) { %>
    <div class="empty" style="margin-top:32px;">
      <h3>No Cancellations</h3>
      <p>There are no cancelled registrations for this event.</p>
    </div>
  <% } else { %>
    
    <% if (isPaid) { %>
      <div class="dash-grid" style="margin-bottom:32px">
        <div class="dash-card">
          <div class="dc-title">Total Cancellations</div>
          <div class="dc-val"><%= cancelledTickets.size() %></div>
        </div>
        <div class="dash-card">
          <div class="dc-title">Pending Refunds Total</div>
          <div class="dc-val" style="color:var(--warn-dark)">&#8377;<%= String.format("%.0f", eventPrice * cancelledTickets.size()) %></div>
        </div>
      </div>
      
      <div class="msg warn" style="margin-bottom:24px;">
        <strong>Action Required:</strong> These users have cancelled their registration. Since this is a paid event, you must manually refund <strong>&#8377;<%= String.format("%.0f", eventPrice) %></strong> to each user via your original payment receiving method (UPI/Bank Transfer).
      </div>
    <% } else { %>
      <div class="dash-grid" style="margin-bottom:32px">
        <div class="dash-card">
          <div class="dc-title">Total Cancellations</div>
          <div class="dc-val"><%= cancelledTickets.size() %></div>
        </div>
      </div>
    <% } %>

    <div style="background:#fff; border:1px solid var(--border); border-radius:12px; overflow:hidden;">
      <table style="width:100%; border-collapse:collapse; text-align:left;">
        <thead>
          <tr style="background:var(--bg); border-bottom:1px solid var(--border); font-size:12px; font-weight:600; color:var(--ink-mute); text-transform:uppercase; letter-spacing:.05em;">
            <th style="padding:16px 24px">Ticket ID</th>
            <th style="padding:16px 24px">Holder</th>
            <th style="padding:16px 24px">Status</th>
            <th style="padding:16px 24px; text-align:right">Action Required</th>
          </tr>
        </thead>
        <tbody>
          <% for (Ticket t : cancelledTickets) { 
               boolean isTeam = "TEAM".equals(t.getTicketType());
          %>
          <tr style="border-bottom:1px solid var(--border)">
            <td style="padding:16px 24px; font-family:var(--ff-mono); font-weight:600; color:var(--warn-dark)"><%= t.getId() %></td>
            <td style="padding:16px 24px">
              <% if (isTeam) { %>
                <%= t.getTeamName() != null ? t.getTeamName() : (t.getUserName() != null ? t.getUserName() : "Unknown") %> (Team)
              <% } else { %>
                <%= t.getUserName() != null ? t.getUserName() : "Unknown" %>
              <% } %>
            </td>
            <td style="padding:16px 24px">
              <span class="badge badge-warn">CANCELLED</span>
            </td>
            <td style="padding:16px 24px; text-align:right; font-size:14px;">
              <% if (isPaid) { %>
                <strong style="color:var(--warn-dark)">Refund &#8377;<%= String.format("%.0f", eventPrice) %></strong>
              <% } else { %>
                <span style="color:var(--ink-mute)">None</span>
              <% } %>
            </td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  <% } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Cancellations View</span>
</div></div></footer>

</body>
</html>
