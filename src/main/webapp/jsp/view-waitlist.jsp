<%@ page import="java.util.*, java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
String eventTitle = (String) request.getAttribute("eventTitle");
Integer eventId = (Integer) request.getAttribute("eventId");
List<Map<String, String>> waitlist = (List<Map<String, String>>) request.getAttribute("waitlist");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Waitlist &middot; <%= eventTitle %></title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
<style>
  .waitlist-stat { background:#fff; border:1px solid var(--border); border-radius:12px; padding:24px; margin-bottom:32px; display:flex; justify-content:space-between; align-items:center; }
  .waitlist-stat .stat-val { font-size:32px; font-weight:700; color:var(--warn); line-height:1; }
  .waitlist-stat .stat-lbl { font-size:14px; font-weight:600; color:var(--ink-mute); text-transform:uppercase; letter-spacing:.05em; margin-bottom:8px; }
  .position-badge { display:inline-flex; width:28px; height:28px; background:var(--warn); color:#fff; border-radius:50%; align-items:center; justify-content:center; font-weight:600; font-size:13px; font-family:var(--ff-mono); }
</style>
</head>
<body>

<nav class="bar">
  <div class="bar-row">
    <a href="<%= request.getContextPath() %>/" class="logo">
      <span class="logo-mark">E</span>
      <span class="logo-name">Event Management</span>
    </a>
    <div class="nav-links">
      <a href="<%= request.getContextPath() %>/manage-events">Manage Events</a>
      <a href="<%= request.getContextPath() %>/home">Dashboard</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <div class="eyebrow">Waitlist</div>
      <h1><em><%= eventTitle %></em></h1>
    </div>
    <div class="actions">
      <a href="<%= request.getContextPath() %>/manage-events" class="btn btn-soft">&larr; Back to Events</a>
    </div>
  </div>

  <div class="waitlist-stat">
    <div>
      <div class="stat-lbl">Total Users on Waitlist</div>
      <div class="stat-val"><%= waitlist != null ? waitlist.size() : 0 %></div>
    </div>
    <div style="font-size:13px; color:var(--ink-mute); text-align:right;">
      Users are promoted in FIFO order<br>(first come, first served)
    </div>
  </div>

  <% if (waitlist == null || waitlist.isEmpty()) { %>
    <div class="empty">
      <h3>No users on waitlist.</h3>
      <p>There are currently no users waiting for this event.</p>
    </div>
  <% } else { %>
    <div style="background:#fff; border:1px solid var(--border); border-radius:12px; overflow:hidden;">
      <table style="width:100%; border-collapse:collapse; text-align:left;">
        <thead>
          <tr style="background:var(--bg); border-bottom:1px solid var(--border); font-size:12px; font-weight:600; color:var(--ink-mute); text-transform:uppercase; letter-spacing:.05em;">
            <th style="padding:16px 24px; width:64px;">#</th>
            <th style="padding:16px 24px;">Name</th>
            <th style="padding:16px 24px;">Email</th>
            <th style="padding:16px 24px;">Joined At</th>
          </tr>
        </thead>
        <tbody>
          <% for (Map<String, String> entry : waitlist) { %>
          <tr style="border-bottom:1px solid var(--border)">
            <td style="padding:16px 24px;">
              <span class="position-badge"><%= entry.get("position") %></span>
            </td>
            <td style="padding:16px 24px; font-weight:500; color:var(--ink);"><%= entry.get("name") %></td>
            <td style="padding:16px 24px; color:var(--ink-mute);"><%= entry.get("email") %></td>
            <td style="padding:16px 24px; font-family:var(--ff-mono); font-size:13px; color:var(--ink-mute);"><%= entry.get("waitlistedAt") %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  <% } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
</div></div></footer>

</body>
</html>
