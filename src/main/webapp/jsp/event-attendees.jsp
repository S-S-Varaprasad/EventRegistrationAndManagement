<%@ page import="java.util.*, com.event.model.Event, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    Event event = (Event) request.getAttribute("event");
    List<Map<String, String>> waitlist = (List<Map<String, String>>) request.getAttribute("waitlist");
    if (waitlist == null) waitlist = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Waitlist &middot; <%= event != null ? event.getTitle() : "Event" %></title>
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
      <a href="<%= request.getContextPath() %>/manage-events">&larr; My Events</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <div class="eyebrow">Event Management &middot; Waitlist Queue</div>
      <h1><%= event != null ? event.getTitle() : "Event" %></h1>
      <div class="meta">Users below are queued and will be auto-promoted when a registered user cancels.</div>
    </div>
  </div>

  <div class="dash-grid" style="margin-bottom:32px">
    <div class="dash-card">
      <div class="dc-title">Users in Queue</div>
      <div class="dc-val" style="color:var(--primary)"><%= waitlist.size() %></div>
    </div>
  </div>

  <% if (waitlist.isEmpty()) { %>
    <div class="empty" style="margin-top:16px;">
      <h3>Queue Empty</h3>
      <p>No users are currently on the waitlist for this event.</p>
    </div>
  <% } else { %>
    <div style="background:#fff; border:1px solid var(--border); border-radius:12px; overflow:hidden;">
      <table style="width:100%; border-collapse:collapse; text-align:left;">
        <thead>
          <tr style="background:var(--bg); border-bottom:2px solid var(--border); font-size:12px; font-weight:700; color:var(--ink-mute); text-transform:uppercase; letter-spacing:.07em;">
            <th style="padding:16px 24px">Position</th>
            <th style="padding:16px 24px">Name</th>
            <th style="padding:16px 24px">Email</th>
            <th style="padding:16px 24px">Intended Team</th>
            <th style="padding:16px 24px">Joined Queue At</th>
          </tr>
        </thead>
        <tbody>
          <% int pos = 1; for (Map<String, String> w : waitlist) { %>
          <tr style="border-bottom:1px solid var(--border)">
            <td style="padding:16px 24px; font-weight:700; color:var(--primary)">#<%= pos++ %></td>
            <td style="padding:16px 24px; font-weight:600"><%= w.get("name") %></td>
            <td style="padding:16px 24px; color:var(--ink-mute)"><%= w.get("email") %></td>
            <td style="padding:16px 24px;">
              <% String tName = w.get("teamName"); %>
              <% if (tName != null && !tName.isEmpty()) { %>
                <span class="badge badge-soft"><%= tName %></span>
              <% } else { %>
                <span style="color:var(--ink-soft); font-size:12px;">Individual</span>
              <% } %>
            </td>
            <td style="padding:16px 24px; font-family:var(--ff-mono); font-size:13px;"><%= w.get("waitlistedAt") %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  <% } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Waitlist Queue</span>
</div></div></footer>

</body>
</html>
