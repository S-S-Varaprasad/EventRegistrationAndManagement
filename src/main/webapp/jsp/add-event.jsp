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
    /* toggleFields is defined in the main script block below the form */
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
      
      <div class="dynamic-section" id="leaderFieldsSection" style="display:block;">
          <h3>Attendee Custom Fields</h3>
          <p class="hint">Collect specific info from the attendees (e.g. Branch, USN).</p>
          <div id="field-builder-container" style="display:flex; flex-direction:column; gap:10px; margin-bottom: 12px;"></div>
          <div style="display:flex; gap:8px; align-items: center;">
              <input type="text" id="newFieldLabel" placeholder="Field name (e.g. Branch)" style="flex:1; min-width: 100px; padding:8px; border:1px solid #ddd; border-radius:4px; margin: 0;">
              <select id="newFieldType" style="padding:8px; border:1px solid #ddd; border-radius:4px; width: auto; flex-shrink: 0; margin: 0;">
                  <option value="text">Text</option>
                  <option value="number">Number</option>
              </select>
              <button type="button" class="btn btn-soft" style="width: auto; flex-shrink: 0; padding: 8px 16px;" onclick="handleField('add')">+ Add</button>
          </div>
          <input type="hidden" name="custom_form_schema" id="custom_form_schema" value="[]">
          <input type="hidden" name="member_form_schema" id="member_form_schema" value="[]">
      </div>

      <script>
          let customFields = [];
          
          function toggleFields() {
              // --- Pricing toggle ---
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

              // --- Team toggle ---
              const type = document.getElementById('eventType').value;
              const isTeam = (type === 'TEAM');
              document.getElementById('teamGroup').style.display = isTeam ? 'block' : 'none';
              document.getElementById('leaderFieldsSection').style.display = 'block';
          }

          function handleField(action, index) {
              const list = customFields;
              const containerId = 'field-builder-container';
              const inputId = 'newFieldLabel';
              const typeId = 'newFieldType';

              if (action === 'add') {
                  const label = document.getElementById(inputId).value.trim();
                  const type = document.getElementById(typeId).value;
                  if (!label) return;
                  list.push({ name: label.toLowerCase().replace(/ /g, '_'), label: label, type: type });
                  document.getElementById(inputId).value = '';
              } else if (action === 'remove') {
                  list.splice(index, 1);
              }

              render(list, containerId);
          }

          function render(list, containerId) {
              const container = document.getElementById(containerId);
              container.innerHTML = '';
              list.forEach((f, i) => {
                  const div = document.createElement('div');
                  div.style.cssText = "display:flex; justify-content:space-between; align-items:center; background:#fff; padding:10px; border:1px solid #eee; border-radius:6px;";
                  div.innerHTML = `<div><strong>${f.label}</strong> <span style="font-size:10px; opacity:0.6;">(${f.type.toUpperCase()})</span></div>
                                   <button type="button" onclick="handleField('remove', ${i})" style="color:var(--danger); font-size:18px;">&times;</button>`;
                  container.appendChild(div);
              });
              document.getElementById('custom_form_schema').value = JSON.stringify(list);
              document.getElementById('member_form_schema').value = JSON.stringify(list);
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