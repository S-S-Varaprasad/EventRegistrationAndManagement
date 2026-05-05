package com.event.controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.event.model.User;
import com.event.service.OrganizationService;
import com.event.util.DBConnection;

/**
 * ManageRefundsServlet - Single Responsibility: Display all pending refunds
 * across all PAID events for the organizer.
 */
public class ManageRefundsServlet extends HttpServlet {

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

        // Fetch ALL cancelled tickets for PAID events belonging to this org
        List<Map<String, Object>> refunds = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql =
                "SELECT t.id AS ticket_id, u.name AS user_name, u.email AS user_email, u.phone AS user_phone, " +
                "e.title AS event_title, e.price AS event_price, e.id AS event_id, " +
                "t.created_at AS cancelled_at " +
                "FROM tickets t " +
                "JOIN events e ON t.event_id = e.id " +
                "JOIN users u ON t.user_id = u.id " +
                "WHERE e.organization_id = ? " +
                "AND e.participation_mode = 'PAID' " +
                "AND t.status = 'CANCELLED' " +
                "ORDER BY t.created_at DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, orgId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("ticketId", rs.getString("ticket_id"));
                row.put("userName", rs.getString("user_name"));
                row.put("userEmail", rs.getString("user_email"));
                row.put("userPhone", rs.getString("user_phone"));
                row.put("eventTitle", rs.getString("event_title"));
                row.put("eventPrice", rs.getDouble("event_price"));
                row.put("eventId", rs.getInt("event_id"));
                row.put("cancelledAt", rs.getTimestamp("cancelled_at"));
                refunds.add(row);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        request.setAttribute("refunds", refunds);
        request.getRequestDispatcher("/jsp/manage-refunds.jsp").forward(request, response);
    }
}
