<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");
String success = request.getParameter("success");
if (session.getAttribute("user") == null) {
    response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Create event &middot; Event Management</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
<script>
    function toggleFields() {
        var partMode = document.getElementById("partMode").value;
        var priceGroup = document.getElementById("priceGroup");
        var priceInput = document.getElementById("priceInput");
        var qrCodeGroup = document.getElementById("qrCodeGroup");
        var qrCodeInput = document.getElementById("qr_code");
        if (partMode === "PAID") {
            priceGroup.style.display = "block"; priceInput.required = true;
            if(qrCodeGroup) qrCodeGroup.style.display = "block";
            if(qrCodeInput) qrCodeInput.required = true;
        } else {
            priceGroup.style.display = "none"; priceInput.required = false; priceInput.value = "0";
            if(qrCodeGroup) qrCodeGroup.style.display = "none";
            if(qrCodeInput) qrCodeInput.required = false;
        }

        var eventType = document.getElementById("eventType").value;
        var teamGroup = document.getElementById("teamGroup");
        var minInput = document.getElementById("minTeam");
        var maxInput = document.getElementById("maxTeam");
        if (eventType === "TEAM") {
            teamGroup.style.display = "block"; minInput.required = true; maxInput.required = true;
        } else {
            teamGroup.style.display = "none"; minInput.required = false; maxInput.required = false;
        }
    }
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
      <a href="<%= request.getContextPath() %>/manage-events">&larr; Back to events</a>
    </div>
  </div>
</nav>

<main class="wrap-mid" style="padding-top:36px;padding-bottom:48px;flex:1">
  <div class="form-container">
    <div class="eyebrow">Event &middot; new</div>
    <h2>Publish a new <em>event.</em></h2>
    <p class="sub">Fill in the details. You can edit, hide or delete the event after publishing.</p>

    <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>
    <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

    <form action="<%= request.getContextPath() %>/add-event" method="post" id="event-form" enctype="multipart/form-data">
      <div class="form-group full">
        <label>Event Title</label>
        <input type="text" name="title" required placeholder="e.g. Technozion 2026">
      </div>
      <div class="form-group full">
        <label>Event Description</label>
        <textarea name="description" required rows="4" placeholder="Required background info..."></textarea>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Event Date</label>
          <input type="date" name="date" required>
        </div>
        <div class="form-group">
          <label>Event Location</label>
          <input type="text" name="location" required placeholder="Main Auditorium or Mumbai">
        </div>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Who Can Attend</label>
          <select name="eligibility" required>
            <option value="OPEN">Open to Public</option>
            <option value="COLLEGE_ONLY">College Students Only</option>
            <option value="COMPANY_ONLY">Company Employees Only</option>
          </select>
        </div>
        <div class="form-group">
          <label>Maximum Capacity (Total Seats/Tickets)</label>
          <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="capacity" required placeholder="Total Seats">
        </div>
      </div>

      <div class="dynamic-section">
        <h3>Pricing</h3>
        <p class="hint">Set to Paid to require a ticket fee.</p>
        <div class="form-row">
          <div class="form-group">
            <label>Entry Fee</label>
            <select name="participation_mode" id="partMode" onchange="toggleFields()" required>
                <option value="FREE">Free Event</option>
                <option value="PAID">Paid Event</option>
            </select>
          </div>
          <div class="form-group" id="priceGroup" style="display:none;">
            <label>Ticket Price (&#8377;)</label>
            <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="price" id="priceInput" placeholder="e.g. 500">
          </div>
        </div>
        
        <div id="qrCodeGroup" style="display:none; margin-top: 14px; background:var(--bg); border:1px solid var(--border); padding:16px; border-radius:8px;">
          <label style="font-weight:600;">Payment QR Code (Organizer UPI/Bank)</label>
          <p class="hint" style="margin-bottom:8px;">Upload your QR code for users to scan during checkout. Keep the image clear and high-resolution.</p>
          <input type="file" name="qr_code" id="qr_code" accept="image/*">
        </div>
      </div>

      <div class="dynamic-section">
        <h3>Event Format</h3>
        <p class="hint">Set to Team Registration if attendees need to form teams.</p>
        <div class="form-row">
            <div class="form-group">
                <label>Event Format</label>
                <select name="event_type" id="eventType" onchange="toggleFields()" required>
                    <option value="INDIVIDUAL">Individual Registration</option>
                    <option value="TEAM">Team Registration</option>
                </select>
            </div>
        </div>
        
        <div id="teamGroup" style="display:none;margin-top:14px">
          <div class="form-row">
            <div class="form-group">
              <label>Min Team Size</label>
              <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="min_team_size" id="minTeam" value="1">
            </div>
            <div class="form-group">
              <label>Max Team Size</label>
              <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="max_team_size" id="maxTeam" value="4">
            </div>
          </div>
        </div>
      </div>
      
      <div class="dynamic-section" id="leaderFieldsSection" style="display:none;">
          <h3>Attendee Custom Fields (Leader)</h3>
          <p class="hint">Collect specific info from the primary registrant (Leader).</p>
          <div id="field-builder-container" style="display:flex; flex-direction:column; gap:10px; margin-bottom: 12px;"></div>
          <div style="display:flex; gap:8px;">
              <input type="text" id="newFieldLabel" placeholder="Field name (e.g. Branch)" style="flex:1; padding:8px; border:1px solid #ddd; border-radius:4px;">
              <select id="newFieldType" style="padding:8px; border:1px solid #ddd; border-radius:4px;">
                  <option value="text">Text</option>
                  <option value="number">Number</option>
              </select>
              <button type="button" class="btn btn-soft" onclick="handleField('leader', 'add')">+ Add</button>
          </div>
          <input type="hidden" name="custom_form_schema" id="custom_form_schema" value="[]">
      </div>

      <div class="dynamic-section" id="memberDetailsSection" style="display:none;">
          <h3>Team Member Details</h3>
          <p class="hint">What info should the leader provide for each team member? (e.g. Name, Phone, T-Shirt Size).</p>
          <div id="member-builder-container" style="display:flex; flex-direction:column; gap:10px; margin-bottom: 12px;"></div>
          <div style="display:flex; gap:8px;">
              <input type="text" id="newMemberLabel" placeholder="Member field (e.g. Full Name)" style="flex:1; padding:8px; border:1px solid #ddd; border-radius:4px;">
              <select id="newMemberType" style="padding:8px; border:1px solid #ddd; border-radius:4px;">
                  <option value="text">Text</option>
                  <option value="number">Number</option>
              </select>
              <button type="button" class="btn btn-soft" onclick="handleField('member', 'add')">+ Add</button>
          </div>
          <input type="hidden" name="member_form_schema" id="member_form_schema" value="[]">
      </div>

      <script>
          let leaderFields = [];
          let memberFields = [];
          
          function toggleFields() {
              const type = document.getElementById('eventType').value;
              const isTeam = (type === 'TEAM');
              document.getElementById('teamGroup').style.display = isTeam ? 'block' : 'none';
              document.getElementById('leaderFieldsSection').style.display = isTeam ? 'block' : 'none';
              document.getElementById('memberDetailsSection').style.display = isTeam ? 'block' : 'none';
          }

          function handleField(target, action, index) {
              const list = (target === 'leader') ? leaderFields : memberFields;
              const containerId = (target === 'leader') ? 'field-builder-container' : 'member-builder-container';
              const inputId = (target === 'leader') ? 'newFieldLabel' : 'newMemberLabel';
              const typeId = (target === 'leader') ? 'newFieldType' : 'newMemberType';
              const hiddenId = (target === 'leader') ? 'custom_form_schema' : 'member_form_schema';

              if (action === 'add') {
                  const label = document.getElementById(inputId).value.trim();
                  const type = document.getElementById(typeId).value;
                  if (!label) return;
                  list.push({ name: label.toLowerCase().replace(/ /g, '_'), label: label, type: type });
                  document.getElementById(inputId).value = '';
              } else if (action === 'remove') {
                  list.splice(index, 1);
              }

              render(target, list, containerId, hiddenId);
          }

          function render(target, list, containerId, hiddenId) {
              const container = document.getElementById(containerId);
              container.innerHTML = '';
              list.forEach((f, i) => {
                  const div = document.createElement('div');
                  div.style.cssText = "display:flex; justify-content:space-between; align-items:center; background:#fff; padding:10px; border:1px solid #eee; border-radius:6px;";
                  div.innerHTML = `<div><strong>${f.label}</strong> <span style="font-size:10px; opacity:0.6;">(${f.type.toUpperCase()})</span></div>
                                   <button type="button" onclick="handleField('${target}', 'remove', ${i})" style="color:var(--danger); font-size:18px;">&times;</button>`;
                  container.appendChild(div);
              });
              document.getElementById(hiddenId).value = JSON.stringify(list);
          }
      </script>

      <div class="btn-group">
        <a href="<%= request.getContextPath() %>/home" class="btn btn-soft">Cancel</a>
        <button type="submit" class="btn btn-primary">Submit Event</button>
      </div>
    </form>
  </div>
</main>

<footer><div class="wrap"><div class="foot-row">
  <span>&copy; Event Registration &amp; Management System</span>
  <span>Visible to all eligible attendees once published</span>
</div></div></footer>

</body>
</html>