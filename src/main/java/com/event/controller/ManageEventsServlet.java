package com.event.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import com.event.model.*;
import com.event.service.*;

public class ManageEventsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String context = request.getContextPath();

        if (user == null) {
            response.sendRedirect(context + "/jsp/login.jsp");
            return;
        }

        OrganizationService orgService = new OrganizationService();
        Integer orgId = orgService.getOrgByAdmin(user.getId());

        if (orgId == null) {
            // Not an organizer
            response.sendRedirect(context + "/home");
            return;
        }

        EventService eventService = new EventService();
        List<Event> orgEvents = eventService.getEventsByOrganization(orgId);

        // Fetch Analytics
        java.util.Map<Integer, Double> revenueMap = new java.util.HashMap<>();
        java.util.Map<Integer, Integer> waitlistMap = new java.util.HashMap<>();
        java.util.Map<Integer, Integer> cancelMap = new java.util.HashMap<>();
        int totalRegistrations = 0;
        int totalParticipants = 0;
        int totalWaitlistNetwork = 0;
        int totalEvents = orgEvents.size();

        try (java.sql.Connection con = com.event.util.DBConnection.getConnection()) {
            // 1. Total Registrations (Slots/Tickets)
            java.sql.PreparedStatement ps = con.prepareStatement(
                "SELECT COUNT(*) FROM tickets WHERE status IN ('ACTIVE','USED') " +
                "AND event_id IN (SELECT id FROM events WHERE organization_id = ?)");
            ps.setInt(1, orgId);
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                totalRegistrations = rs.getInt(1);
            }

            // 2. Total Participants (Headcount/People)
            // Headcount = Registered Leaders/Individuals + Members in Team Rosters
            java.sql.PreparedStatement psHead = con.prepareStatement(
                "SELECT (" +
                "  SELECT COUNT(*) FROM registrations r " +
                "  WHERE r.event_id IN (SELECT id FROM events WHERE organization_id = ?) " +
                "  AND EXISTS (SELECT 1 FROM tickets t " +
                "    WHERE (t.team_id = r.team_id OR (t.user_id = r.user_id AND r.team_id IS NULL)) " +
                "    AND t.status IN ('ACTIVE','USED') AND t.event_id = r.event_id)" +
                ") + (" +
                "  SELECT COALESCE(SUM(JSON_LENGTH(member_data)), 0) FROM team_member_data " +
                "  WHERE team_id IN (" +
                "    SELECT id FROM teams WHERE event_id IN (SELECT id FROM events WHERE organization_id = ?) " +
                "    AND id IN (SELECT team_id FROM tickets WHERE status IN ('ACTIVE','USED'))" +
                "  )" +
                ") AS total_headcount");
            psHead.setInt(1, orgId);
            psHead.setInt(2, orgId);
            java.sql.ResultSet rsHead = psHead.executeQuery();
            if (rsHead.next()) {
                totalParticipants = rsHead.getInt(1);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        for (Event e : orgEvents) {
            
            if ("PAID".equals(e.getEventType())) {
                revenueMap.put(e.getId(), eventService.getEventRevenue(e.getId()));
            }

            // Get waitlist count for each event
            int waitCount = 0;
            int cancelCount = 0;
            try (java.sql.Connection con = com.event.util.DBConnection.getConnection()) {
                java.sql.PreparedStatement wps = con.prepareStatement("SELECT COUNT(*) FROM waitlist WHERE event_id=?");
                wps.setInt(1, e.getId());
                java.sql.ResultSet wrs = wps.executeQuery();
                if (wrs.next()) {
                    waitCount = wrs.getInt(1);
                    totalWaitlistNetwork += waitCount;
                }

                java.sql.PreparedStatement cps = con.prepareStatement("SELECT COUNT(*) FROM tickets WHERE event_id=? AND status='CANCELLED'");
                cps.setInt(1, e.getId());
                java.sql.ResultSet crs = cps.executeQuery();
                if (crs.next()) {
                    cancelCount = crs.getInt(1);
                }
            } catch (Exception ex) { ex.printStackTrace(); }
            
            waitlistMap.put(e.getId(), waitCount);
            cancelMap.put(e.getId(), cancelCount);
        }

        request.setAttribute("orgEvents", orgEvents);
        request.setAttribute("revenueMap", revenueMap);
        request.setAttribute("waitlistMap", waitlistMap);
        request.setAttribute("cancelMap", cancelMap);
        request.setAttribute("totalRegistrations", totalRegistrations);
        request.setAttribute("totalParticipants", totalParticipants);
        request.setAttribute("totalWaitlistNetwork", totalWaitlistNetwork);
        request.setAttribute("totalEvents", totalEvents);

        request.getRequestDispatcher("/jsp/manage-events.jsp").forward(request, response);
    }
}
