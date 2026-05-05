package com.event.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import com.event.model.User;
import com.event.dao.EventDAO;
import com.event.service.OrganizationService;

import jakarta.servlet.annotation.WebServlet;

@WebServlet("/delete-event")
public class DeleteEventServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String eventIdParam = request.getParameter("eventId");
        if (eventIdParam != null && orgId != null) {
            int eventId = Integer.parseInt(eventIdParam);
            EventDAO dao = new EventDAO();
            
            // Delete physically via cascade from tables
            try (java.sql.Connection con = com.event.util.DBConnection.getConnection()) {
                java.sql.PreparedStatement ps = con.prepareStatement("DELETE FROM events WHERE id=? AND organization_id=?");
                ps.setInt(1, eventId);
                ps.setInt(2, orgId);
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(context + "/manage-events?success=Event+Permanently+Deleted");
    }
}
