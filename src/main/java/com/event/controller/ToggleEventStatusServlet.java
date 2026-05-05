package com.event.controller;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;

public class ToggleEventStatusServlet extends HttpServlet {

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

        if (orgId == null) {
            response.sendRedirect(context + "/home");
            return;
        }

        String eventIdParam = request.getParameter("eventId");
        if (eventIdParam != null && !eventIdParam.trim().isEmpty()) {
            int eventId = Integer.parseInt(eventIdParam);
            EventService service = new EventService();

            // Verify this event belongs to the organizer's organization
            com.event.model.Event event = service.getEventById(eventId);
            if (event == null || event.getOrganizationId() != orgId) {
                response.sendRedirect(context + "/manage-events");
                return;
            }
            
            service.toggleEventStatus(eventId);
        }

        response.sendRedirect(context + "/manage-events?success=Status+updated");
    }
}
