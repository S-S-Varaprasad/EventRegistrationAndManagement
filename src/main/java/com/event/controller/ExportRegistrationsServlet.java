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

            // Header
            out.println("Registration ID,User Name,User Email,Team Name,Custom Data,Payment Screenshot Path");

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
                String tName = rs.getString("team_name") != null ? rs.getString("team_name") : "Individual";
                String custom = rs.getString("custom_answers") != null ? rs.getString("custom_answers").replace("\"", "'") : "None";
                String pay = rs.getString("payment_screenshot_path") != null ? rs.getString("payment_screenshot_path") : "N/A";

                // Output Leader/Individual
                out.printf("\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", regId, uName, uEmail, tName, custom, pay);

                // Fetch and Output Roster Members if it's a team
                if (rs.getString("team_name") != null) {
                    int teamId = rs.getInt("team_id");
                    String rosterJson = new com.event.dao.TeamDAO().getRosterByTeamId(teamId);
                    if (rosterJson != null && rosterJson.startsWith("[")) {
                        try {
                             // NATIVE PARSE: Since the JSON is a simple array of objects, we parse it manually
                             // to avoid dependency on missing GSON jar.
                             String data = rosterJson.substring(1, rosterJson.length() - 1); // Remove [ ]
                             String[] objects = data.split("\\},\\{");
                             for (String obj : objects) {
                                 String cleanObj = obj.replace("{", "").replace("}", "");
                                 String[] pairs = cleanObj.split(",");
                                 StringBuilder sb = new StringBuilder();
                                 String mName = "N/A";
                                 for (String pair : pairs) {
                                     String[] kv = pair.split(":");
                                     if (kv.length == 2) {
                                         String key = kv[0].replace("\"", "").trim();
                                         String val = kv[1].replace("\"", "").trim();
                                         sb.append(key).append(":").append(val).append("; ");
                                         if (key.equalsIgnoreCase("name")) mName = val;
                                     }
                                 }
                                 out.printf("\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", regId, "Member: " + mName, "via Leader", tName, sb.toString(), "N/A");
                             }
                        } catch(Exception ex) {}
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
