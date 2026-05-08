package com.event.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.model.User;
import com.event.service.OrganizationService;
import com.event.util.DBConnection;

@WebServlet("/export-data")
public class ExportRegistrationsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Authentication: user must be logged in
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        // Authorization: user must be an organizer
        OrganizationService orgService = new OrganizationService();
        Integer orgId = orgService.getOrgByAdmin(user.getId());
        if (orgId == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        if (eventIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing eventId");
            return;
        }
        
        int eventId = Integer.parseInt(eventIdStr);
        
        // SECURITY PATCH (IDOR Fix): Verify the event belongs to the requesting Organizer
        com.event.service.EventService eventService = new com.event.service.EventService();
        com.event.model.Event currentEvent = eventService.getEventById(eventId);
        if (currentEvent == null || currentEvent.getOrganizationId() != orgId) {
            response.sendRedirect(request.getContextPath() + "/manage-events?error=Unauthorized");
            return;
        }

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"event_" + eventIdStr + "_registrations.csv\"");

        try (PrintWriter out = response.getWriter();
             Connection con = DBConnection.getConnection()) {

            List<String> customKeys = new ArrayList<>();
            List<String> customLabels = new ArrayList<>();
            String schema = currentEvent.getCustomFormSchema();
            if (schema != null && schema.length() > 2) {
                String cleanSchema = schema.substring(1, schema.length() - 1);
                String[] objects = cleanSchema.split("\\},\\{");
                for (String obj : objects) {
                    String cleanObj = obj.replace("{", "").replace("}", "");
                    String[] pairs = cleanObj.split(",");
                    String keyName = null, keyLabel = null;
                    for (String pair : pairs) {
                        String[] kv = pair.split(":");
                        if (kv.length >= 2) {
                            String k = kv[0].replace("\"", "").trim();
                            String v = kv[1].replace("\"", "").trim();
                            if ("name".equals(k)) keyName = v;
                            if ("label".equals(k)) keyLabel = v;
                        }
                    }
                    if (keyName != null) {
                        customKeys.add(keyName);
                        customLabels.add(keyLabel != null ? keyLabel : keyName);
                    }
                }
            }

            boolean isTeamEvent = "TEAM".equals(currentEvent.getEventType());
            boolean isPaidEvent = "PAID".equals(currentEvent.getParticipationMode());

            // Header
            StringBuilder header = new StringBuilder("Registration ID");
            if (isTeamEvent) header.append(",Role");
            header.append(",User Name,User Email");
            if (isTeamEvent) header.append(",Team Name");
            if (isPaidEvent) header.append(",Payment Screenshot Path");
            
            for (String label : customLabels) {
                header.append(",\"").append(label).append("\"");
            }
            out.println(header.toString());

            String sql = "SELECT r.id, u.name as user_name, u.email as user_email, t.name as team_name, r.custom_answers, r.payment_screenshot_path, t.id as team_id " +
                         "FROM registrations r " +
                         "JOIN users u ON r.user_id = u.id " +
                         "LEFT JOIN teams t ON r.team_id = t.id " +
                         "WHERE r.event_id = ?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(eventIdStr));
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int regId = rs.getInt("id");
                String uName = rs.getString("user_name");
                String uEmail = rs.getString("user_email");
                boolean isTeam = rs.getString("team_name") != null;
                String tName = isTeam ? rs.getString("team_name") : "N/A";
                String customAnswers = rs.getString("custom_answers");
                String pay = rs.getString("payment_screenshot_path") != null ? rs.getString("payment_screenshot_path") : "N/A";
                String role = isTeam ? "Leader" : "Individual";

                StringBuilder row = new StringBuilder();
                row.append("\"").append(regId).append("\"");
                if (isTeamEvent) row.append(",\"").append(role).append("\"");
                row.append(",\"").append(uName).append("\",\"").append(uEmail).append("\"");
                if (isTeamEvent) row.append(",\"").append(tName).append("\"");
                if (isPaidEvent) row.append(",\"").append(pay).append("\"");

                for (String key : customKeys) {
                    row.append(",\"").append(extractJsonValue(customAnswers, key)).append("\"");
                }
                out.println(row.toString());

                // Fetch and Output Roster Members if it's a team
                if (isTeamEvent && isTeam) {
                    int teamId = rs.getInt("team_id");
                    String rosterJson = new com.event.dao.TeamDAO().getRosterByTeamId(teamId);
                    if (rosterJson != null && rosterJson.length() > 2) {
                        try {
                             String data = rosterJson.substring(1, rosterJson.length() - 1);
                             String[] objects = data.split("\\},\\{");
                             for (String obj : objects) {
                                 String cleanObj = "{" + obj.replace("{", "").replace("}", "") + "}";
                                 
                                 String mName = "Team Member";
                                 for (String key : customKeys) {
                                     if (key.toLowerCase().contains("name")) {
                                         String val = extractJsonValue(cleanObj, key);
                                         if (!val.equals("N/A")) {
                                             mName = val;
                                             break;
                                         }
                                     }
                                 }

                                 StringBuilder mRow = new StringBuilder();
                                 mRow.append("\"").append(regId).append("\"");
                                 mRow.append(",\"Member\"");
                                 mRow.append(",\"").append(mName).append("\",\"via Leader\"");
                                 mRow.append(",\"").append(tName).append("\"");
                                 if (isPaidEvent) mRow.append(",\"N/A\"");

                                 for (String key : customKeys) {
                                     mRow.append(",\"").append(extractJsonValue(cleanObj, key)).append("\"");
                                 }
                                 out.println(mRow.toString());
                             }
                        } catch(Exception ex) {}
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private String extractJsonValue(String jsonObject, String key) {
        if (jsonObject == null || jsonObject.isEmpty() || jsonObject.equals("[]")) return "N/A";
        String search1 = "\"" + key + "\":\"";
        int idx = jsonObject.indexOf(search1);
        if (idx != -1) {
            int start = idx + search1.length();
            int end = jsonObject.indexOf("\"", start);
            if (end != -1) return jsonObject.substring(start, end).replace("\"", "'");
        }
        String search2 = "\"" + key + "\":";
        idx = jsonObject.indexOf(search2);
        if (idx != -1) {
            int start = idx + search2.length();
            int end = jsonObject.indexOf(",", start);
            if (end == -1) end = jsonObject.indexOf("}", start);
            if (end != -1) {
                String val = jsonObject.substring(start, end).trim();
                if (val.startsWith("\"") && val.endsWith("\"")) {
                    val = val.substring(1, val.length() - 1);
                }
                return val.replace("\"", "'");
            }
        }
        return "N/A";
    }
}
