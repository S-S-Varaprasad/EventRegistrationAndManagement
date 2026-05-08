<%@ page import="com.event.model.Event" %>
  <%@ page import="com.event.model.Event" %>
    <%@ page import="com.event.dao.EventDAO" %>
      <%@ page import="com.event.model.User" %>
        <%@ page import="com.event.service.OrganizationService" %>
          <%@ page contentType="text/html; charset=UTF-8" %>
<% User user = (User) session.getAttribute("user"); %>
<% if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; } %>
<% OrganizationService orgService = new OrganizationService(); %>
<% Integer orgId = orgService.getOrgByAdmin(user.getId()); %>
<% if (orgId == null) { response.sendRedirect(request.getContextPath() + "/home"); return; } %>
<% String eventIdStr = request.getParameter("eventId"); %>
<% if (eventIdStr == null) { response.sendRedirect(request.getContextPath() + "/manage-events"); return; } %>
<% int eventId = Integer.parseInt(eventIdStr); %>
<% EventDAO dao = new EventDAO(); %>
<% Event e = dao.getEventById(eventId); %>
<% if (e == null || e.getOrganizationId() != orgId) { response.sendRedirect(request.getContextPath() + "/manage-events"); return; } %>
<% String error = request.getParameter("error"); %>
              <!DOCTYPE html>
              <html lang="en">

              <head>
                <meta charset="UTF-8">
                <title>Edit event &middot; Event Management</title>
                <link rel="stylesheet" href="<%= request.getContextPath() %>/css/app.css">
                <script>
                  function togglePrice() {
                    var mode = document.getElementById("pMode").value;
                    var group = document.getElementById("priceGroup");
                    var qrGroup = document.getElementById("qrCodeGroup");
                    if (mode === "PAID") {
                      group.style.display = "block";
                      if (qrGroup) qrGroup.style.display = "block";
                    } else {
                      group.style.display = "none";
                      if (qrGroup) qrGroup.style.display = "none";
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
                    <div class="eyebrow">Event &middot; edit</div>
                    <h2>Edit <em>
                        <%= e.getTitle() %>
                      </em></h2>
                    <p class="sub">Update the event details. Existing registrations are not affected.</p>

                    <% if (error !=null) { %>
                      <div class="msg error">
                        <%= error %>
                      </div>
                      <% } %>

                        <form action="<%= request.getContextPath() %>/edit-event" method="post" id="event-form" enctype="multipart/form-data">
                          <input type="hidden" name="eventId" value="<%= e.getId() %>">

                          <div class="form-group full">
                            <label>Event Title</label>
                            <input type="text" name="title" required value="<%= e.getTitle() %>">
                          </div>

                          <div class="form-group full">
                            <label>Description Details</label>
                            <textarea name="description" required rows="4"><%= e.getDescription() %></textarea>
                          </div>

                          <div class="form-row">
                            <div class="form-group">
                              <label>Event Date</label>
                              <input type="date" name="eventDate" required value="<%= e.getEventDate() %>">
                            </div>
                            <div class="form-group">
                              <label>Location (Virtual or Physical)</label>
                              <input type="text" name="location" required value="<%= e.getLocation() %>">
                            </div>
                          </div>

                          <div class="form-row">
                            <div class="form-group">
                              <label>Who Can Attend</label>
                              <select name="eligibility" required>
                                <option value="OPEN" <%= "OPEN".equals(e.getEligibility()) ? "selected" : "" %>>Publicly
                                  Open</option>
                                <option value="COLLEGE_ONLY" <%= "COLLEGE_ONLY".equals(e.getEligibility()) ? "selected" : "" %>>College/Students Only</option>
                                <option value="COMPANY_ONLY" <%= "COMPANY_ONLY".equals(e.getEligibility()) ? "selected" : "" %>>Corporate/Company Only</option>
                              </select>
                            </div>
                            <div class="form-group">
                              <label>Total Tickets Available (Must be &ge; Current Registrations)</label>
                              <input type="text" inputmode="numeric" pattern="[0-9]+"
                                oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="capacity" required
                                value="<%= e.getCapacity() %>">
                            </div>
                          </div>

                          <div class="dynamic-section">
                            <h3>Pricing</h3>
                            <p class="hint">Set to Paid to require a ticket fee.</p>
                            <div class="form-row">
                              <div class="form-group">
                                <label>Entry Type</label>
                                <select name="participationMode" id="pMode" onchange="togglePrice()" required>
                                  <option value="FREE" <%= "FREE".equals(e.getParticipationMode()) ? "selected" : "" %>>Free Entry</option>
                                  <option value="PAID" <%= "PAID".equals(e.getParticipationMode()) ? "selected" : "" %>>Paid Entry</option>
                                </select>
                              </div>
                              <div class="form-group" id="priceGroup"
                                style='display:<%= "PAID".equals(e.getParticipationMode()) ? "block" : "none" %>'>
                                <label>Ticket Price (&#8377;)</label>
                                <input type="text" inputmode="numeric" pattern="[0-9]+"
                                  oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="price"
                                  value='<%= String.format("%.0f", e.getPrice()) %>'>
                              </div>
                            </div>
                            <div id="qrCodeGroup" style='display:<%= "PAID".equals(e.getParticipationMode()) ? "block" : "none" %>; margin-top: 14px; background:var(--bg); border:1px solid var(--border); padding:16px; border-radius:8px;'>
                              <label style="font-weight:600;">Payment QR Code (Organizer UPI/Bank)</label>
                              <p class="hint" style="margin-bottom:8px;">Upload a new QR code image to replace the existing one, or leave blank to keep the current image.</p>
                              <input type="file" name="qr_code" id="qr_code" accept="image/*">
                              <% if (e.getQrCodePath() != null && !e.getQrCodePath().isEmpty()) { %>
                                <div style="margin-top:10px; font-size:13px; color:var(--primary);">
                                  &#10003; A QR code is currently uploaded.
                                </div>
                              <% } %>
                            </div>
                          </div>

                          <div class="dynamic-section">
                            <h3>Event Format</h3>
                            <div class="form-row">
                              <div class="form-group">
                                <label>Event Format</label>
                                <select name="eventType" id="eventType" onchange="toggleFields()" required>
                                  <option value="INDIVIDUAL" <%= "INDIVIDUAL".equals(e.getEventType()) ? "selected" : "" %>>Individual Action</option>
                                  <option value="TEAM" <%= "TEAM".equals(e.getEventType()) ? "selected" : "" %>>Team Oriented</option>
                                </select>
                              </div>
                            </div>
                          </div>

                          <div class="dynamic-section" id="leaderFieldsSection" style="display:block;">
                            <h3>Attendee Custom Fields</h3>
                            <p class="hint">Fields required for the attendees.</p>
                            <div id="field-builder-container" style="display:flex; flex-direction:column; gap:10px; margin-bottom: 12px;"></div>
                            <div style="display:flex; gap:8px; align-items: center;">
                              <input type="text" id="newFieldLabel" placeholder="Field name" style="flex:1; min-width: 100px; padding:8px; border:1px solid #ddd; border-radius:4px; margin: 0;">
                              <select id="newFieldType" style="padding:8px; border:1px solid #ddd; border-radius:4px; width: auto; flex-shrink: 0; margin: 0;">
                                <option value="text">Text</option>
                                <option value="number">Number</option>
                              </select>
                              <button type="button" class="btn btn-soft" style="width: auto; flex-shrink: 0; padding: 8px 16px;" onclick="handleField('add')">+ Add</button>
                            </div>
                            <input type="hidden" name="custom_form_schema" id="custom_form_schema" value='<%= (e.getCustomFormSchema() == null || e.getCustomFormSchema().isEmpty()) ? "[]" : e.getCustomFormSchema() %>'>
                            <input type="hidden" name="member_form_schema" id="member_form_schema" value='<%= (e.getMemberFormSchema() == null || e.getMemberFormSchema().isEmpty()) ? "[]" : e.getMemberFormSchema() %>'>
                          </div>

                          <script>
                            let customFields = [];
                            
                            function toggleFields() {
                                const type = document.getElementById('eventType').value;
                                const isTeam = (type === 'TEAM');
                                document.getElementById('leaderFieldsSection').style.display = 'block';
                                // Note: teamGroup handling if present
                                let tg = document.getElementById('teamGroup');
                                if(tg) tg.style.display = isTeam ? 'block' : 'none';
                            }
                            
                            function init() {
                                try {
                                    customFields = JSON.parse(document.getElementById('custom_form_schema').value || "[]");
                                    render(customFields, 'field-builder-container');
                                } catch(e) { console.error(e); }
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

                            window.onload = init;
                          </script>

                          <div class="btn-group">
                            <a href="<%= request.getContextPath() %>/manage-events" class="btn btn-soft">Cancel</a>
                            <button type="submit" class="btn btn-primary">Save changes</button>
                          </div>
                        </form>
                  </div>
                </main>

                <footer>
                  <div class="wrap">
                    <div class="foot-row">
                      <span>&copy; Event Registration &amp; Management System</span>
                      <span>Editing event #<%= e.getId() %></span>
                    </div>
                  </div>
                </footer>

              </body>

              </html>