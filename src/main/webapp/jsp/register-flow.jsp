<%@ page import="java.util.*, com.event.model.*, com.event.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
String eventIdStr = request.getParameter("eventId");
User user = (User) session.getAttribute("user");
if (user == null || eventIdStr == null) {
    response.sendRedirect(request.getContextPath() + "/view-events");
    return;
}
int eventId = Integer.parseInt(eventIdStr);
EventDAO dao = new EventDAO();
Event e = null;
try {
    e = dao.getEventById(eventId);
} catch (Exception ex) {
    ex.printStackTrace();
}
if (e == null) {
    response.sendRedirect(request.getContextPath() + "/view-events?error=Event+not+found");
    return;
}

boolean isTeam = "TEAM".equals(e.getEventType());
boolean isPaid = "PAID".equals(e.getParticipationMode());
boolean hasCustomFields = e.getCustomFormSchema() != null && e.getCustomFormSchema().trim().length() > 2;

List<Team> activeTeams = new ArrayList<>();
if (isTeam) {
    TeamDAO tDao = new TeamDAO();
    activeTeams = tDao.getTeamsByEventId(eventId);
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Register &middot; <%= e.getTitle() %></title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
<script>
    function renderCustomFields() {
        var schemaStr = document.getElementById("hiddenSchema").value;
        if(!schemaStr || schemaStr.trim() === "null" || schemaStr.length < 5) return;
        
        var container = document.getElementById("customFieldsContainer");
        try {
            var schema = JSON.parse(schemaStr);
            var html = '<h3>Additional Information</h3>';
            schema.forEach(function(field) {
                html += '<div class="form-group">';
                html += '<label>' + field.label + '</label>';
                if(field.type === 'text') {
                    html += '<input type="text" class="custom-input" data-key="' + field.name + '" required>';
                } else if (field.type === 'number') {
                    html += '<input type="number" class="custom-input" data-key="' + field.name + '" required>';
                } else if (field.type === 'select' && field.options) {
                    html += '<select class="custom-input" data-key="' + field.name + '" required>';
                    field.options.forEach(function(opt) {
                        html += '<option value="' + opt + '">' + opt + '</option>';
                    });
                    html += '</select>';
                }
                html += '</div>';
            });
            container.innerHTML = html;
            container.style.display = 'block';
        } catch(e) {
            console.error("Invalid Custom Schema JSON", e);
        }
    }

    function serializeForm(event) {
        // Package custom fields
        var customInputs = document.querySelectorAll('.custom-input');
        if(customInputs.length > 0) {
            var ans = {};
            customInputs.forEach(function(input) {
                ans[input.getAttribute('data-key')] = input.value;
            });
            document.getElementById("customAnswers").value = JSON.stringify(ans);
        }
        return true;
    }

    window.onload = function() {
        renderCustomFields();
    };
</script>
</head>
<body>

<nav class="bar">
  <div class="bar-row">
    <a href="<%= request.getContextPath() %>/" class="logo">
      <span class="logo-mark">E</span>
      <span class="logo-name">Event Management</span>
    </a>
    <div class="nav-links">
      <a href="<%= request.getContextPath() %>/view-events">&larr; Back to events</a>
    </div>
  </div>
</nav>

<main class="wrap-mid" style="padding-top:36px;padding-bottom:48px;flex:1">
  <div class="form-container">
    <div class="eyebrow">Registration &middot; confirm</div>
    <h2>Register for <em><%= e.getTitle() %></em></h2>
    <p class="sub"><%= e.getEventDate() %> &middot; <%= e.getLocation() %> &middot; <%= isPaid ? "&#8377;" + String.format("%.0f", e.getPrice()) : "Free" %></p>

    <form action="<%= request.getContextPath() %>/process-registration" method="post" enctype="multipart/form-data" onsubmit="return serializeForm(event)">
      
      <% if (isPaid && e.getAvailableSeats() == 0) { %>
        <div class="msg error" style="margin-bottom: 20px;">
          <strong>Event Sold Out!</strong><br/>
          This is a paid event and all seats are currently full. Waitlist is disabled for paid events to avoid upfront payments without guaranteed seats.
        </div>
        <div class="btn-group">
          <a href="<%= request.getContextPath() %>/view-events" class="btn btn-soft">Return to Events</a>
        </div>
      <% } else { %>
      
      <% if (e.getAvailableSeats() == 0) { %>
        <div class="msg warn" style="margin-bottom: 20px;">
          <strong>Notice: Event Full!</strong><br/>
          You are joining the <b>Waitlist</b>. You will be automatically promoted if a seat opens up.
        </div>
      <% } %>

      <input type="hidden" name="eventId" value="<%= e.getId() %>">
      <input type="hidden" id="customAnswers" name="custom_answers" value="">
      <input type="hidden" id="hiddenSchema" value='<%= hasCustomFields ? e.getCustomFormSchema().replace("\"", "&quot;") : "" %>'>

      <% if (isTeam) { %>
      <div class="dynamic-section">
        <h3>Team Configuration</h3>
        <p class="hint">As the Team Leader, please provide a name for your team and fill in details for all members including yourself.</p>
        
        <div class="form-group">
            <label>Team Name</label>
            <input type="text" name="team_name" placeholder="e.g. Innovators" required>
        </div>

        <!-- Member 1: Leader (You) -->
        <div id="rosterContainer" style="margin-top:20px;">
            <h4 style="font-size:15px; margin-bottom:12px; color:var(--ink);">Team Members</h4>
            <div style="background:var(--paper-2); border:1px solid var(--rule); padding:16px; border-radius:8px; margin-bottom:12px;">
                <div style="font-weight:600; font-size:13px; margin-bottom:10px; color:var(--ink);">Member 1 (You)</div>
                <div id="leaderFields"></div>
            </div>
            <div id="memberList"></div>
            <% if (e.getMaxTeamSize() > 1) { %>
                <button type="button" class="btn btn-soft btn-tiny" onclick="addMemberRow()" id="addMemberBtn" style="margin-top:10px;">+ Add Member</button>
            <% } %>
        </div>
        <input type="hidden" id="rosterJson" name="roster_json" value="[]">
        <input type="hidden" id="memberSchema" value='<%= (e.getMemberFormSchema() != null) ? e.getMemberFormSchema().replace("\"", "&quot;") : "[]" %>'>
        <input type="hidden" id="maxTeamSize" value="<%= e.getMaxTeamSize() %>">
      </div>

      <script>
        var roster = [];
        var memberSchema = [];
        try { memberSchema = JSON.parse(document.getElementById('memberSchema').value); } catch(e){}
        var maxLimit = parseInt(document.getElementById('maxTeamSize').value);

        // Build leader fields using the same schema
        (function() {
            var container = document.getElementById('leaderFields');
            var html = '';
            for (var i = 0; i < memberSchema.length; i++) {
                var f = memberSchema[i];
                html += '<div class="form-group"><label>' + f.label + '</label>';
                html += '<input type="' + f.type + '" class="leader-input" data-key="' + f.name + '" required></div>';
            }
            container.innerHTML = html;
        })();

        function addMemberRow() {
            var list = document.getElementById('memberList');
            if (list.children.length >= maxLimit - 1) {
                alert("Maximum team size reached.");
                return;
            }
            
            var index = list.children.length;
            var div = document.createElement('div');
            div.className = 'member-block';
            div.style.cssText = "background:var(--paper-2); border:1px solid var(--rule); padding:16px; border-radius:8px; margin-bottom:12px; position:relative;";
            
            var fieldsHtml = '<div style="font-weight:600; font-size:13px; margin-bottom:10px; color:var(--ink-soft);" class="member-label">Member ' + (index + 2) + '</div>';
            for (var i = 0; i < memberSchema.length; i++) {
                var f = memberSchema[i];
                fieldsHtml += '<div class="form-group"><label>' + f.label + '</label>';
                fieldsHtml += '<input type="' + f.type + '" class="roster-input" data-index="' + index + '" data-key="' + f.name + '" required></div>';
            }
            
            div.innerHTML = fieldsHtml + '<button type="button" onclick="this.parentElement.remove(); reIndexRegMembers();" style="position:absolute; top:12px; right:12px; color:var(--danger); font-size:18px; background:none; border:none; cursor:pointer;">&times;</button>';
            list.appendChild(div);
            reIndexRegMembers();
        }

        function reIndexRegMembers() {
            var labels = document.getElementById('memberList').querySelectorAll('.member-label');
            for (var i = 0; i < labels.length; i++) {
                labels[i].innerText = "Member " + (i + 2);
            }
            var addBtn = document.getElementById('addMemberBtn');
            if (addBtn) {
                addBtn.style.display = (document.getElementById('memberList').children.length < maxLimit - 1) ? 'inline-block' : 'none';
            }
        }

        // Add initial min members if needed (min-1 because leader is Member 1)
        <% if (e.getMinTeamSize() > 1) { %>
           window.addEventListener('DOMContentLoaded', function() {
               for(var i=0; i < <%= e.getMinTeamSize() - 1 %>; i++) addMemberRow();
           });
        <% } %>

        function captureRoster() {
            var dataArr = [];

            // Capture leader (Member 1) data first
            var leaderInputs = document.querySelectorAll('.leader-input');
            var leaderObj = {};
            for (var k = 0; k < leaderInputs.length; k++) {
                leaderObj[leaderInputs[k].getAttribute('data-key')] = leaderInputs[k].value;
            }
            dataArr.push(leaderObj);

            // Capture other members
            var rosterInputs = document.querySelectorAll('.roster-input');
            var data = {};
            for (var r = 0; r < rosterInputs.length; r++) {
                var inp = rosterInputs[r];
                var idx = inp.getAttribute('data-index');
                if(!data[idx]) data[idx] = {};
                data[idx][inp.getAttribute('data-key')] = inp.value;
            }
            var keys = Object.keys(data);
            for (var m = 0; m < keys.length; m++) {
                dataArr.push(data[keys[m]]);
            }

            document.getElementById('rosterJson').value = JSON.stringify(dataArr);
            return true;
        }
        
        // Hook into existing serializeForm if it exists, or create wrapper
        var oldSerialize = serializeForm;
        serializeForm = function(ev) {
            captureRoster();
            return oldSerialize(ev);
        };
      </script>
      <% } %>

      <% if (hasCustomFields) { %>
      <div class="dynamic-section" id="customFieldsContainer" style="display:none;"></div>
      <% } %>

      <% if (isPaid) { %>
      <div class="dynamic-section">
        <h3>Payment Verification</h3>
        <p class="hint" style="margin-bottom: 15px;">This is a paid event. Total cost is: <strong>&#8377;<%= String.format("%.0f", e.getPrice()) %></strong>.</p>
        <p class="hint" style="margin-bottom: 15px;">Please transfer funds to Organizer via UPI or Bank Transfer and upload screenshot confirmation.</p>
        
        <% if (e.getQrCodePath() != null && !e.getQrCodePath().isEmpty()) { %>
        <div style="background:var(--bg); border:1px solid var(--border); border-radius:8px; padding:16px; margin-bottom:16px; text-align:center;">
            <p style="font-weight:600; margin-bottom:12px; color:var(--ink);">Scan to Pay Organizer</p>
            <img src="<%= request.getContextPath() %>/<%= e.getQrCodePath() %>" alt="Organizer Payment QR Code" style="max-width:200px; border-radius:8px; border:1px solid var(--border);">
        </div>
        <% } %>

        <div class="form-group" style="margin-bottom:0">
            <label>Upload Payment Screenshot</label>
            <input type="file" name="payment_screenshot" accept="image/*" required>
        </div>
      </div>
      <% } else { %>
      <div class="dynamic-section">
        <h3>Free event</h3>
        <p class="hint" style="margin-bottom:0">No payment required. You'll be registered immediately and a digital ticket generated.</p>
      </div>
      <% } %>

      <div class="btn-group">
        <a href="<%= request.getContextPath() %>/view-events" class="btn btn-soft">Cancel</a>
        <button type="submit" class="btn btn-primary">Finalize Registration</button>
      </div>
      <% } %>
    </form>
  </div>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Registering as <%= user.getName() %></span>
</div></div></footer>

</body>
</html>
