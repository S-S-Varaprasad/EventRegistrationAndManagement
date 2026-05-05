<%@ page import="java.util.List, java.util.Map, com.event.model.Ticket, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
    String success = (String) session.getAttribute("adminSuccess");
    String error = (String) session.getAttribute("adminError");
    if (success != null) session.removeAttribute("adminSuccess");
    if (error != null) session.removeAttribute("adminError");

    String eventTitle = (String) request.getAttribute("eventTitle");
    Integer eventId = (Integer) request.getAttribute("eventId");
    Integer totalTickets = (Integer) request.getAttribute("totalTickets");
    Integer checkedIn = (Integer) request.getAttribute("checkedIn");
    Integer activeRemaining = (Integer) request.getAttribute("activeRemaining");
    Integer cancelled = (Integer) request.getAttribute("cancelled");
    int total = (totalTickets != null) ? totalTickets : 0;
    int used = (checkedIn != null) ? checkedIn : 0;
    int active = (activeRemaining != null) ? activeRemaining : 0;
    int canc = (cancelled != null) ? cancelled : 0;
    int pct = (total > 0) ? (used * 100 / total) : 0;

    Map<Integer, String> rosterMap = (Map<Integer, String>) request.getAttribute("rosterMap");
    if (rosterMap == null) rosterMap = new java.util.HashMap<>();
    String memberSchema = (String) request.getAttribute("memberSchema");
    String eventType = (String) request.getAttribute("eventType");
    boolean isTeamEvent = "TEAM".equals(eventType);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Check-In &middot; <%= eventTitle != null ? eventTitle : "Event" %></title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
<style>
  .quick-scan { display:flex; gap:12px; margin-bottom:32px; background:#fff; padding:24px; border-radius:12px; border:1px solid var(--rule); align-items:center; }
  .quick-scan-label { font-weight:600; font-size:12px; color:var(--ink-mute); letter-spacing:.05em; text-transform:uppercase; white-space:nowrap; }
  .quick-scan input { flex:1; padding:12px 16px; border:1px solid var(--rule); border-radius:8px; font-family:var(--ff-mono); font-size:15px; }
  .quick-scan input:focus { outline:none; border-color:var(--ink-soft); }
  .roster-row { background:var(--paper); }
  .roster-row td { padding:8px 24px 16px !important; }
  .roster-table { width:100%; border-collapse:collapse; font-size:13px; }
  .roster-table th { text-align:left; padding:6px 12px; font-size:11px; font-weight:600; color:var(--ink-mute); text-transform:uppercase; letter-spacing:.04em; border-bottom:1px solid var(--rule); }
  .roster-table td { padding:8px 12px; border-bottom:1px solid var(--rule-soft); }
  .toggle-btn { background:none; border:none; color:var(--ink-soft); font-size:12px; cursor:pointer; text-decoration:underline; }
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
      <a href="<%= request.getContextPath() %>/manage-events">&larr; Back to Dashboard</a>
    </div>
  </div>
</nav>

<main class="wrap" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <h1>Check-In</h1>
      <% if (eventTitle != null) { %><div class="meta"><%= eventTitle %></div><% } %>
    </div>
  </div>

  <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>
  <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>

  <div class="dash-grid" style="margin-bottom:32px">
    <div class="dash-card">
      <div class="dc-title">Total Tickets</div>
      <div class="dc-val"><%= total %></div>
    </div>
    <div class="dash-card">
      <div class="dc-title">Checked In</div>
      <div class="dc-val" style="color:var(--primary)"><%= used %></div>
    </div>
    <div class="dash-card">
      <div class="dc-title">Remaining</div>
      <div class="dc-val" style="color:var(--ink)"><%= active %></div>
    </div>
    <div class="dash-card">
      <div class="dc-title">Cancelled</div>
      <div class="dc-val" style="color:var(--coral)"><%= canc %></div>
    </div>
  </div>

  <% if (total > 0) { %>
  <div style="background:#fff;border:1px solid var(--rule);border-radius:8px;padding:24px;margin-bottom:32px">
    <div style="display:flex;justify-content:space-between;margin-bottom:12px;font-weight:600;font-size:14px;color:var(--ink)">
      <span>Attendance</span>
      <span style="color:var(--ink-soft)"><%= pct %>%</span>
    </div>
    <div style="background:var(--paper);height:6px;border-radius:3px;overflow:hidden">
      <div style="background:var(--ink);height:100%;width:<%= pct %>%;transition:width .5s ease"></div>
    </div>
  </div>
  <% } %>

  <form class="quick-scan" action="<%= request.getContextPath() %>/event-checkin" method="post">
    <span class="quick-scan-label">Ticket ID</span>
    <input type="text" name="ticketId" placeholder="Enter ticket ID" autocomplete="off" autofocus>
    <input type="hidden" name="eventId" value="<%= eventId %>">
    <button type="submit" class="btn btn-primary">Check In</button>
  </form>

  <% if (tickets == null || tickets.isEmpty()) { %>
    <div class="empty" style="margin-top:32px;">
      <h3>No tickets found.</h3>
      <p>There are no tickets issued for this event yet.</p>
    </div>
  <% } else { %>
    <div style="background:#fff; border:1px solid var(--rule); border-radius:8px; overflow:hidden;">
      <table style="width:100%; border-collapse:collapse; text-align:left;">
        <thead>
          <tr style="background:var(--paper); border-bottom:1px solid var(--rule); font-size:12px; font-weight:600; color:var(--ink-mute); text-transform:uppercase; letter-spacing:.05em;">
            <th style="padding:14px 24px">Ticket ID</th>
            <th style="padding:14px 24px">Type</th>
            <th style="padding:14px 24px">Holder</th>
            <th style="padding:14px 24px">Status</th>
            <th style="padding:14px 24px; text-align:right">Action</th>
          </tr>
        </thead>
        <tbody>
          <% 
            int rowIdx = 0;
            for (Ticket t : tickets) { 
              boolean isActive = "ACTIVE".equals(t.getStatus()); 
              String badgeClass = isActive ? "badge-open" : ("USED".equals(t.getStatus()) ? "badge-mute" : "badge-warn");
              boolean isTeam = "TEAM".equals(t.getTicketType());
              String rosterJson = (isTeam && t.getTeamId() != null) ? rosterMap.get(t.getTeamId()) : null;
              boolean hasRoster = (rosterJson != null && !rosterJson.equals("[]") && rosterJson.length() > 2);
              rowIdx++;
          %>
          <tr style="border-bottom:1px solid var(--rule)">
            <td style="padding:14px 24px; font-family:var(--ff-mono); font-weight:600; color:var(--ink)"><%= t.getId() %></td>
            <td style="padding:14px 24px; font-weight:500"><%= t.getTicketType() %></td>
            <td style="padding:14px 24px">
              <% if (isTeam) { %>
                <%= t.getTeamName() != null ? t.getTeamName() : (t.getUserName() != null ? t.getUserName() : "Unknown") %>
                <% if (hasRoster) { %>
                  <button type="button" class="toggle-btn" onclick="var el=document.getElementById('roster-<%= rowIdx %>');el.style.display=(el.style.display==='none'?'table-row':'none');">View Members</button>
                <% } %>
              <% } else { %>
                <%= t.getUserName() != null ? t.getUserName() : "Unknown" %>
              <% } %>
            </td>
            <td style="padding:14px 24px">
              <% if ("CANCELLED".equals(t.getStatus())) { %>
                <span class="badge badge-warn">CANCELLED</span>
              <% } else { %>
                <span class="badge <%= badgeClass %>"><%= t.getStatus() != null ? t.getStatus() : "" %></span>
              <% } %>
            </td>
            <td style="padding:14px 24px; text-align:right">
              <% if (isActive) { %>
                <form action="<%= request.getContextPath() %>/event-checkin" method="post" style="display:inline;">
                  <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                  <input type="hidden" name="eventId" value="<%= eventId %>">
                  <button type="submit" class="btn btn-primary btn-tiny">Mark Entry</button>
                </form>
              <% } else if ("USED".equals(t.getStatus())) { %>
                <span style="font-size:13px; color:var(--ink-mute); font-weight:500">Done</span>
              <% } else if ("CANCELLED".equals(t.getStatus())) { %>
                <span style="font-size:13px; color:var(--coral); font-weight:500">Voided</span>
              <% } %>
            </td>
          </tr>
          <% if (isTeam && hasRoster) { %>
          <tr id="roster-<%= rowIdx %>" class="roster-row" style="display:none;">
            <td colspan="5" style="padding:8px 24px 16px;">
              <div style="margin-left:16px;">
                <table class="roster-table">
                  <thead><tr id="roster-head-<%= rowIdx %>"></tr></thead>
                  <tbody id="roster-body-<%= rowIdx %>"></tbody>
                </table>
              </div>
              <script>
              (function(){
                var schema = [];
                try { schema = JSON.parse('<%= memberSchema != null ? memberSchema.replace("\\", "\\\\").replace("'", "\\'") : "[]" %>'); } catch(e){}
                var data = [];
                try { data = JSON.parse('<%= rosterJson.replace("\\", "\\\\").replace("'", "\\'") %>'); } catch(e){}
                var head = document.getElementById('roster-head-<%= rowIdx %>');
                var body = document.getElementById('roster-body-<%= rowIdx %>');
                // Build header
                var hh = '<th>#</th>';
                for (var i = 0; i < schema.length; i++) { hh += '<th>' + schema[i].label + '</th>'; }
                head.innerHTML = hh;
                // Build rows
                for (var r = 0; r < data.length; r++) {
                  var rw = '<td>' + (r+1) + '</td>';
                  for (var c = 0; c < schema.length; c++) {
                    rw += '<td>' + (data[r][schema[c].name] || '-') + '</td>';
                  }
                  body.innerHTML += '<tr>' + rw + '</tr>';
                }
              })();
              </script>
            </td>
          </tr>
          <% } %>
          <% } %>
        </tbody>
      </table>
    </div>
  <% } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Check-In</span>
</div></div></footer>

</body>
</html>