<%@ page import="java.util.*, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Map<String, Object>> refunds = (List<Map<String, Object>>) request.getAttribute("refunds");
    if (refunds == null) refunds = new ArrayList<>();
    double totalOwed = 0;
    for (Map<String, Object> r : refunds) { totalOwed += (Double) r.get("eventPrice"); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Pending Refunds &middot; Organizer Dashboard</title>
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
      <a href="<%= request.getContextPath() %>/manage-events">My Events</a>
      <a href="<%= request.getContextPath() %>/verify-payments" style="color:var(--warn-dark);font-weight:600">Review Payments</a>
      <a href="<%= request.getContextPath() %>/manage-refunds" style="color:var(--coral);font-weight:600">Pending Refunds</a>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <div class="eyebrow">Finance &middot; Organizer Action Required</div>
      <h1>Pending <em>Refunds.</em></h1>
      <div class="meta">These users cancelled their registration for a paid event. You must refund them manually via UPI/Bank Transfer.</div>
    </div>
  </div>

  <% if (refunds.isEmpty()) { %>
    <div class="empty" style="margin-top:32px;">
      <h3>All Clear!</h3>
      <p>No pending refunds. All paid event cancellations have been handled.</p>
      <a href="<%= request.getContextPath() %>/manage-events" class="btn btn-soft" style="margin-top:16px">Back to My Events</a>
    </div>
  <% } else { %>
    <div class="dash-grid" style="margin-bottom:32px">
      <div class="dash-card">
        <div class="dc-title">Pending Refunds</div>
        <div class="dc-val" style="color:var(--warn-dark)"><%= refunds.size() %></div>
      </div>
      <div class="dash-card">
        <div class="dc-title">Total Amount Owed</div>
        <div class="dc-val" style="color:var(--warn-dark)">&#8377;<%= String.format("%.0f", totalOwed) %></div>
      </div>
    </div>

    <div class="msg warn" style="margin-bottom:24px;">
      <strong>Action Required:</strong> The system cannot automatically refund UPI/Bank payments. Please contact each user below and initiate the refund via your original payment method.
    </div>

        <div style="background:#fff; border:1px solid var(--border); border-radius:12px; overflow:hidden;">
      <table style="width:100%; border-collapse:collapse; text-align:left;">
        <thead>
          <tr style="background:var(--bg); border-bottom:2px solid var(--border); font-size:12px; font-weight:700; color:var(--ink-mute); text-transform:uppercase; letter-spacing:.07em;">
            <th style="padding:16px 24px">User</th>
            <th style="padding:16px 24px">Contact</th>
            <th style="padding:16px 24px">Event</th>
            <th style="padding:16px 24px">Ticket ID</th>
            <th style="padding:16px 24px; text-align:right">Refund Amount</th>
          </tr>
        </thead>
        <tbody>
          <% for (Map<String, Object> r : refunds) { %>
          <tr style="border-bottom:1px solid var(--border)">
            <td style="padding:16px 24px">
              <div style="font-weight:600; color:var(--ink)"><%= r.get("userName") %></div>
              <div style="font-size:13px; color:var(--ink-mute)"><%= r.get("userEmail") %></div>
            </td>
            <td style="padding:16px 24px">
              <% String phone = (String) r.get("userPhone"); %>
              <% if (phone != null && !phone.isEmpty()) { %>
                <a href="tel:<%= phone %>" style="font-weight:600; color:var(--primary); text-decoration:none;"><%= phone %></a>
              <% } else { %>
                <span style="color:var(--ink-mute); font-size:13px;">Not provided</span>
              <% } %>
            </td>
            <td style="padding:16px 24px; color:var(--ink)"><%= r.get("eventTitle") %></td>
            <td style="padding:16px 24px; font-family:var(--ff-mono); font-size:13px; color:var(--ink-mute)"><%= r.get("ticketId") %></td>
            <td style="padding:16px 24px; text-align:right">
              <strong style="color:var(--warn-dark); font-size:16px;">&#8377;<%= String.format("%.0f", (Double) r.get("eventPrice")) %></strong>
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
  <span>Refund Management</span>
</div></div></footer>

</body>
</html>
