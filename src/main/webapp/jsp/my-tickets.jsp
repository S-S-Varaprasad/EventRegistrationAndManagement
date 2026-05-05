<%@ page import="java.util.List, com.event.model.Ticket, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My tickets &middot; Event Management</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
</head>
<body>

<nav class="bar">
  <div class="bar-row">
    <a href="<%= request.getContextPath() %>/home" class="logo">
      <span class="logo-mark">E</span>
      <span class="logo-name">Event Management</span>
    </a>
    <div class="nav-links">
      <a href="<%= request.getContextPath() %>/home">Dashboard</a>
      <a href="<%= request.getContextPath() %>/my-events">Registrations</a>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap-mid" style="padding-bottom:48px;flex:1;padding-top:32px;">
  <div class="page-head">
    <div class="titles">
      <h1>My <em>tickets.</em></h1>
      <div class="meta"><%= tickets == null ? 0 : tickets.size() %> issued &middot; show at the door</div>
    </div>
  </div>

  <% if (tickets == null || tickets.isEmpty()) { %>
    <div class="empty">
      <h3>No tickets yet.</h3>
      <p>Tickets are generated automatically once your registration is confirmed.</p>
      <a href="<%= request.getContextPath() %>/view-events" class="btn btn-primary" style="margin-top:16px">Browse events &rarr;</a>
    </div>
  <% } else { %>
    <div class="ticket-list">
    <% int tktIdx = 0; for (Ticket t : tickets) { tktIdx++;
        String s = t.getStatus();
        String pillClass = "status-active";
        if ("USED".equals(s)) pillClass = "status-used";
        else if ("CANCELLED".equals(s)) pillClass = "status-cancelled";
    %>
      <div class="ticket">
        <div class="ticket-body">
          <div class="ticket-head">
            <div>
              <div class="ticket-id">Admit one</div>
              <div class="title"><em><%= t.getEventTitle() %></em></div>
            </div>
            <div class="date">
              <%= t.getEventDate() %>
            </div>
          </div>
          <div style="display:flex;justify-content:space-between;align-items:flex-end;gap:18px;flex-wrap:wrap">
            <div>
              <% if (t.getTeamName() != null && !t.getTeamName().trim().isEmpty()) { %>
                 <div class="ticket-id">Team Name</div>
                 <div class="ticket-id-val" style="color:var(--primary); font-size:18px; margin-bottom:12px;"><%= t.getTeamName() %></div>
              <% } %>
              <div class="ticket-id">Ticket number</div>
              <div class="ticket-id-val"><%= t.getId() %></div>
              <div style="margin-top:10px"><span class="status-pill <%= pillClass %>"><%= s %></span></div>
            </div>
            <div class="ticket-barcode">
              <canvas id="barcode-<%= tktIdx %>" width="340" height="55" data-text="<%= t.getId() %>"></canvas>
              <div class="lbl">Scan at venue</div>
            </div>
          </div>
        </div>
        <div class="ticket-stub">
          <div class="stub-hole"></div>
          <div class="type" style="writing-mode: vertical-rl; text-orientation: mixed; letter-spacing: 2px;">
            <%= ("TEAM".equals(t.getTicketType()) ? "TEAM ENTRY" : "INDIVIDUAL ENTRY") %>
          </div>
          <div class="pill">&#10003;</div>
        </div>
      </div>
    <% } %>
    </div>
  <% } %>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Wallet for <%= user.getName() %></span>
</div></div></footer>

<script>
function drawBarcode(canvas) {
    var text = canvas.getAttribute('data-text');
    if (!text || !canvas.getContext) return;
    var ctx = canvas.getContext('2d');
    var x = 15;
    ctx.fillStyle = '#1f2937';
    // Start guard bars
    ctx.fillRect(x, 5, 2, 45); x += 4;
    ctx.fillRect(x, 5, 2, 45); x += 6;
    // Encode each character as binary bars
    for (var i = 0; i < text.length; i++) {
        var c = text.charCodeAt(i);
        for (var b = 7; b >= 0; b--) {
            if ((c >> b) & 1) {
                ctx.fillRect(x, 8, 2, 39);
            }
            x += 3;
        }
        x += 2; // inter-character gap
    }
    // End guard bars
    x += 4;
    ctx.fillRect(x, 5, 2, 45); x += 4;
    ctx.fillRect(x, 5, 2, 45);
}
// Render all barcodes on page load
var canvases = document.querySelectorAll('canvas[data-text]');
for (var i = 0; i < canvases.length; i++) {
    drawBarcode(canvases[i]);
}
</script>
</body>
</html>

