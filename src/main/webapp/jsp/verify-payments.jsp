<%@ page import="java.util.List, java.util.Map, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Map<String, String>> pendingList = (List<Map<String, String>>) request.getAttribute("pendingList");
    String success = (String) session.getAttribute("adminSuccess");
    if (success != null) session.removeAttribute("adminSuccess");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Verify payments &middot; Event Management</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
<style>
  .verify-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(280px, 1fr)); gap:24px; margin-top:32px; }
  .verify-card { background:#fff; border:1px solid var(--border); border-radius:12px; padding:24px; box-shadow:var(--shadow-sm); display:flex; flex-direction:column; gap:16px; }
  .verify-head h3 { font-family:var(--ff-serif); font-size:20px; font-weight:600; color:var(--ink); margin:0 0 4px; }
  .verify-head .who { font-size:14px; color:var(--ink); font-weight:500; display:flex; flex-direction:column; }
  .verify-head .who span { color:var(--ink-mute); font-weight:400; font-family:var(--ff-mono); font-size:12px; }
  .verify-amt { font-family:var(--ff-mono); font-weight:600; font-size:18px; color:var(--primary); margin-top:8px; }
  .verify-img { width:100%; height:180px; object-fit:cover; border-radius:8px; border:1px solid var(--border); background:var(--bg); transition:transform .2s ease; }
  .verify-img:hover { transform:scale(1.02); }
  .verify-actions { display:flex; gap:8px; margin-top:auto; }
  .verify-actions form { flex:1; }
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
      <a href="<%= request.getContextPath() %>/home">Dashboard</a>
      <a href="<%= request.getContextPath() %>/manage-events">Manage events</a>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1">
  <div class="page-head">
    <div class="titles">
      <h1>Payment <em>queue.</em></h1>
      <div class="meta"><%= pendingList == null ? 0 : pendingList.size() %> awaiting verification</div>
    </div>
    <div class="actions">
      <a href="<%= request.getContextPath() %>/manage-events" class="btn btn-soft">&larr; Back to Dashboard</a>
    </div>
  </div>

  <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

  <% if (pendingList == null || pendingList.isEmpty()) { %>
    <div class="empty">
      <h3>Nothing to verify.</h3>
      <p>All payments for your events have been reviewed. New submissions will appear here automatically.</p>
    </div>
  <% } else { %>
    <div class="verify-grid">
      <% for (Map<String, String> map : pendingList) { %>
        <div class="verify-card">
          <div class="verify-head">
            <h3><%= map.get("eventTitle") %></h3>
            <div class="who"><%= map.get("userName") %><span><%= map.get("userEmail") %></span></div>
            <div class="verify-amt">&#8377;<%= map.get("amount") %></div>
          </div>
          <% 
              String rawPath = map.get("screenshot");
              String safePath = (rawPath != null && !rawPath.trim().isEmpty()) ? rawPath.replace("\\", "/") : ""; 
          %>
          <% if (!safePath.isEmpty()) { %>
            <a href="<%= request.getContextPath() %>/<%= safePath %>" target="_blank" style="display:block;text-decoration:none;">
              <img src="<%= request.getContextPath() %>/<%= safePath %>" alt="Payment Screenshot" class="verify-img" title="Click to open full size" onerror="this.style.display='none'; this.nextElementSibling.style.display='grid';">
              <div style="display:none; place-items:center; color:var(--ink-mute); font-family:var(--ff-mono); font-size:12px; letter-spacing:.1em; text-transform:uppercase; background:var(--bg); border-radius:6px; height:100%; min-height:80px;">Image Not Found</div>
            </a>
          <% } else { %>
            <div class="verify-img" style="display:grid;place-items:center;color:var(--ink-mute);font-family:var(--ff-mono);font-size:12px;letter-spacing:.18em;text-transform:uppercase">No proof uploaded</div>
          <% } %>
          <div class="verify-actions">
            <form action="<%= request.getContextPath() %>/verify-payments" method="post">
              <input type="hidden" name="paymentId" value='<%= map.get("paymentId") %>'>
              <input type="hidden" name="action" value="APPROVE">
              <button class="btn btn-leaf btn-tiny btn-block" style="width:100%" type="submit">Approve</button>
            </form>
            <form action="<%= request.getContextPath() %>/verify-payments" method="post">
              <input type="hidden" name="paymentId" value='<%= map.get("paymentId") %>'>
              <input type="hidden" name="action" value="REJECT">
              <button class="btn btn-danger btn-tiny btn-block" style="width:100%" type="submit" onclick="return confirm('Are you sure? This will permanently cancel their registration and automatically give their seat to the next person on the waitlist.');">Reject</button>
            </form>
          </div>
        </div>
      <% } %>
    </div>
  <% } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Verifier &middot; <%= user.getName() %></span>
</div></div></footer>

</body>
</html>
