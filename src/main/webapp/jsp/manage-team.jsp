<%@ page import="com.event.model.Event, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    Event e = (Event) request.getAttribute("event");
    String rosterJson = (String) request.getAttribute("rosterJson");
    Integer teamId = (Integer) request.getAttribute("teamId");
    User user = (User) session.getAttribute("user");
    String success = request.getParameter("success");
    String error = request.getParameter("error");

    // Determine if roster already contains leader data (index 0)
    // Old registrations: roster = [member2, member3, ...]
    // New registrations: roster = [leader, member2, member3, ...]
    // We detect this by checking if the roster length matches expected "others only" count
    // The servlet will pass a flag for this
    Boolean leaderInRoster = (Boolean) request.getAttribute("leaderInRoster");
    if (leaderInRoster == null) leaderInRoster = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Team &middot; <%= e != null ? e.getTitle() : "Event" %></title>
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
      <a href="<%= request.getContextPath() %>/my-events">&larr; My Events</a>
      <a href="<%= request.getContextPath() %>/logout" class="danger">Sign out</a>
    </div>
  </div>
</nav>

<main class="wrap-mid" style="padding-top:36px; padding-bottom:60px;">
    <div class="page-head">
        <div class="titles">
            <h1>Manage Team</h1>
            <div class="meta"><%= e != null ? e.getTitle() : "" %></div>
        </div>
    </div>

    <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>
    <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>

    <div style="background:#fff; border:1px solid var(--rule); border-radius:8px; padding:24px 28px; margin-bottom:24px;">
        <p style="font-size:14px; color:var(--ink-soft); line-height:1.7; margin:0;">
            Fill in details for all team members including yourself (Member 1).
            The event requires <strong><%= e != null ? e.getMinTeamSize() : 1 %></strong> to
            <strong><%= e != null ? e.getMaxTeamSize() : 4 %></strong> members per team.
        </p>
    </div>

    <form id="rosterForm" action="<%= request.getContextPath() %>/manage-team" method="post" onsubmit="return captureRoster()">
        <input type="hidden" name="teamId" value="<%= teamId %>">
        <input type="hidden" id="rosterJsonInput" name="roster_json">
        <input type="hidden" id="memberSchema" value='<%= (e != null && e.getMemberFormSchema() != null) ? e.getMemberFormSchema().replace("\"", "&quot;") : "[]" %>'>
        <input type="hidden" id="maxTeamSize" value="<%= e != null ? e.getMaxTeamSize() : 4 %>">
        <input type="hidden" id="initialData" value='<%= (rosterJson != null) ? rosterJson.replace("\"", "&quot;") : "[]" %>'>
        <input type="hidden" id="leaderInRoster" value="<%= leaderInRoster %>">

        <!-- All members rendered here by JS, including Member 1 (You) -->
        <div id="memberList"></div>

        <button type="button" class="btn btn-soft" onclick="addMemberRow()" id="addBtn" style="margin-top:8px;">+ Add Member</button>

        <div style="display:flex; gap:12px; margin-top:28px; padding-top:20px; border-top:1px solid var(--rule);">
            <a href="<%= request.getContextPath() %>/my-events" class="btn btn-soft">Back</a>
            <button type="submit" class="btn btn-primary">Save Changes</button>
        </div>
    </form>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Team Management</span>
</div></div></footer>

<script>
    var memberSchema = [];
    try { memberSchema = JSON.parse(document.getElementById('memberSchema').value); } catch(err){}
    var maxLimit = parseInt(document.getElementById('maxTeamSize').value);
    var initialData = [];
    try { initialData = JSON.parse(document.getElementById('initialData').value); } catch(err){}
    var leaderInRoster = document.getElementById('leaderInRoster').value === 'true';

    // Normalize: ensure initialData always has leader at index 0
    // Old data format: [member2, member3, ...] → prepend empty leader entry
    // New data format: [leader, member2, member3, ...] → use as-is
    if (!leaderInRoster && initialData.length > 0) {
        // Old format: insert empty leader object at beginning
        initialData.unshift({});
    }
    if (initialData.length === 0) {
        // No data at all: create empty leader slot
        initialData = [{}];
    }

    function createMemberCard(index, data, isLeader) {
        var div = document.createElement('div');
        div.style.cssText = 'background:#fff; border:1px solid var(--rule); border-radius:8px; padding:20px 24px; margin-bottom:12px; position:relative;';
        div.setAttribute('data-member-index', index);

        var label = isLeader ? 'Member 1 (You - Team Leader)' : ('Member ' + (index + 1));
        var html = '<div style="font-weight:600; font-size:14px; margin-bottom:14px; color:var(--ink);" class="member-label">' + label + '</div>';

        for (var i = 0; i < memberSchema.length; i++) {
            var f = memberSchema[i];
            var val = data ? (data[f.name] || '') : '';
            html += '<div class="form-group"><label>' + f.label + '</label>';
            html += '<input type="' + f.type + '" class="roster-input" data-key="' + f.name + '" value="' + val + '" required></div>';
        }

        // Leader card is not removable
        if (!isLeader) {
            html += '<button type="button" onclick="removeMember(this)" style="position:absolute; top:16px; right:16px; color:var(--ink-mute); font-size:18px; background:none; border:none; cursor:pointer; padding:4px 8px;" title="Remove member">&times;</button>';
        }

        div.innerHTML = html;
        return div;
    }

    function addMemberRow(data) {
        var list = document.getElementById('memberList');
        // Total members = all cards in list; max = maxLimit
        if (list.children.length >= maxLimit) {
            alert("Maximum team size reached.");
            return;
        }
        var idx = list.children.length; // 0-based: 0=leader, 1=member2, etc.
        var card = createMemberCard(idx, data || null, false);
        list.appendChild(card);
        reIndexMembers();
    }

    function removeMember(btn) {
        btn.parentElement.remove();
        reIndexMembers();
    }

    function reIndexMembers() {
        var list = document.getElementById('memberList');
        var labels = list.querySelectorAll('.member-label');
        for (var i = 0; i < labels.length; i++) {
            if (i === 0) {
                labels[i].innerText = "Member 1 (You - Team Leader)";
            } else {
                labels[i].innerText = "Member " + (i + 1);
            }
        }
        // Show add button only if below max
        document.getElementById('addBtn').style.display = (list.children.length < maxLimit) ? 'inline-block' : 'none';
    }

    function captureRoster() {
        var list = document.getElementById('memberList');
        var dataArr = [];
        var blocks = list.children;
        for (var b = 0; b < blocks.length; b++) {
            var inputs = blocks[b].querySelectorAll('.roster-input');
            var member = {};
            for (var j = 0; j < inputs.length; j++) {
                member[inputs[j].getAttribute('data-key')] = inputs[j].value;
            }
            dataArr.push(member);
        }
        document.getElementById('rosterJsonInput').value = JSON.stringify(dataArr);
        return true;
    }

    // Initialize: render all members from saved data
    window.addEventListener('DOMContentLoaded', function() {
        var list = document.getElementById('memberList');

        // Render Member 1 (leader) — always present, not removable
        var leaderCard = createMemberCard(0, initialData[0], true);
        list.appendChild(leaderCard);

        // Render other saved members
        for (var i = 1; i < initialData.length; i++) {
            var card = createMemberCard(i, initialData[i], false);
            list.appendChild(card);
        }

        reIndexMembers();
    });
</script>

</body>
</html>
