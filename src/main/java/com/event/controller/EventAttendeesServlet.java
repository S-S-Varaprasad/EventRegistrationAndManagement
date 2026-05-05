package com.event.controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.event.model.Event;
import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;
import com.event.util.DBConnection;

/**
 * EventAttendeesServlet - Single Responsibility: Display Waitlist and
 * Cancellations for a specific FREE event.
 */
public class EventAttendeesServlet extends HttpServlet {

    private EventService eventService = new EventService();
    private OrganizationService orgService = new OrganizationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        Integer orgId = orgService.getOrgByAdmin(user.getId());
        if (orgId == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        if (eventIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/manage-events");
            return;
        }

        int eventId = Integer.parseInt(eventIdStr);
        Event event = eventService.getEventById(eventId);
        if (event == null || event.getOrganizationId() != orgId) {
            response.sendRedirect(request.getContextPath() + "/manage-events");
            return;
        }

        List<Map<String, String>> waitlist = new ArrayList<>();
        List<Map<String, String>> cancellations = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            // Waitlist
            String wSql =
                "SELECT u.name, u.email, w.waitlisted_at, w.team_name " +
                "FROM waitlist w JOIN users u ON w.user_id = u.id " +
                "WHERE w.event_id = ? ORDER BY w.waitlisted_at ASC";
            PreparedStatement wPs = con.prepareStatement(wSql);
            wPs.setInt(1, eventId);
            ResultSet wRs = wPs.executeQuery();
            while (wRs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("name", wRs.getString("name"));
                row.put("email", wRs.getString("email"));
                row.put("teamName", wRs.getString("team_name"));
                row.put("waitlistedAt", wRs.getTimestamp("waitlisted_at").toString());
                waitlist.add(row);
            }

            // Cancellations
            String cSql =
                "SELECT t.id AS ticket_id, u.name, u.email, t.created_at AS cancelled_at " +
                "FROM tickets t JOIN users u ON t.user_id = u.id " +
                "WHERE t.event_id = ? AND t.status = 'CANCELLED' " +
                "ORDER BY t.created_at DESC";
            PreparedStatement cPs = con.prepareStatement(cSql);
            cPs.setInt(1, eventId);
            ResultSet cRs = cPs.executeQuery();
            while (cRs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("ticketId", cRs.getString("ticket_id"));
                row.put("name", cRs.getString("name"));
                row.put("email", cRs.getString("email"));
                row.put("cancelledAt", cRs.getTimestamp("cancelled_at").toString());
                cancellations.add(row);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        request.setAttribute("event", event);
        request.setAttribute("waitlist", waitlist);
        request.setAttribute("cancellations", cancellations);
        request.getRequestDispatcher("/jsp/event-attendees.jsp").forward(request, response);
    }
}
