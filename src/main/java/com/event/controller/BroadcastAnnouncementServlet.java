package com.event.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.model.Event;
import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;

@WebServlet("/broadcast-announcement")
public class BroadcastAnnouncementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        OrganizationService orgService = new OrganizationService();
        Integer orgId = orgService.getOrgByAdmin(user.getId());
        
        if (orgId == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        String message = request.getParameter("message");
        
        if (eventIdStr == null || message == null || message.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/manage-events?error=Message+cannot+be+empty");
            return;
        }

        int eventId = Integer.parseInt(eventIdStr);
        EventService eventService = new EventService();
        
        // Authorization: Verify event belongs to this organization
        Event event = eventService.getEventById(eventId);
        if (event == null || event.getOrganizationId() != orgId) {
            response.sendRedirect(request.getContextPath() + "/manage-events?error=Unauthorized");
            return;
        }

        // Send broadcast
        String formattedMessage = "\uD83D\uDCE2 Announcement from " + event.getTitle() + ": " + message.trim();
        int count = eventService.broadcastAnnouncement(eventId, formattedMessage);

        response.sendRedirect(request.getContextPath() + "/manage-events?success=Broadcast+sent+to+" + count + "+attendees");
    }
}
