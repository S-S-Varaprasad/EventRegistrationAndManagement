<%@ page import="java.util.List, com.event.model.Notification, com.event.model.User, com.event.service.OrganizationService" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    Integer unreadCount = (Integer) request.getAttribute("unreadCount");
    boolean isOrganizer = (new OrganizationService().getOrgByAdmin(user.getId()) != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Notifications &middot; Event Management</title>
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
      <% if (!isOrganizer) { %>
      <a href="<%= request.getContextPath() %>/view-events">Browse Events</a>
      <% } else { %>
      <a href="<%= request.getContextPath() %>/manage-events">Manage events</a>
      <% } %>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap-mid" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <h1><em>Notifications.</em></h1>
      <div class="meta">
        <%= notifications == null ? 0 : notifications.size() %> total
        <% if (unreadCount != null && unreadCount > 0) { %>
          &middot; <span style="color:var(--primary);font-weight:600;"><%= unreadCount %> unread</span>
        <% } %>
      </div>
    </div>
    <div class="actions">
      <% if (notifications != null && !notifications.isEmpty()) { %>
        <form action="<%= request.getContextPath() %>/notifications" method="post" style="display:inline;">
            <input type="hidden" name="action" value="MARK_READ">
            <button type="submit" class="btn btn-soft">Mark All as Read</button>
        </form>
      <% } %>
    </div>
  </div>

  <% if (notifications == null || notifications.isEmpty()) { %>
    <div class="empty">
      <h3>No notifications.</h3>
      <p>When events are updated, payments are verified, or you get promoted from a waitlist &mdash; you'll see updates here.</p>
    </div>
  <% } else { %>
    <div class="notif-list">
      <% for (Notification n : notifications) { %>
        <div class="notif-item <%= !n.isRead() ? "unread" : "" %>">
          <div class="notif-dot"></div>
          <div class="notif-body">
            <div class="notif-msg"><%= n.getMessage() %></div>
            <div class="notif-time"><%= n.getCreatedAt() %></div>
          </div>
        </div>
      <% } %>
    </div>
  <% } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Inbox for <%= user.getName() %></span>
</div></div></footer>

</body>
</html>
