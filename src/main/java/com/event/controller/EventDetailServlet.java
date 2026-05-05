package com.event.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.model.Event;
import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;

public class EventDetailServlet extends HttpServlet {

    private EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String eventIdStr = request.getParameter("id");
        if (eventIdStr == null || eventIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/view-events");
            return;
        }

        int eventId = Integer.parseInt(eventIdStr);
        Event event = eventService.getEventById(eventId);

        if (event == null) {
            response.sendRedirect(request.getContextPath() + "/view-events?error=Event+not+found");
            return;
        }

        // Get organizer name for display
        OrganizationService orgService = new OrganizationService();
        String orgName = orgService.getOrgNameById(event.getOrganizationId());

        // Check if user is logged in for registration button state
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        boolean isRegistered = false;
        boolean isWaitlisted = false;
        if (user != null) {
            isRegistered = eventService.isRegistered(user.getId(), eventId);
            isWaitlisted = eventService.isWaitlisted(user.getId(), eventId);
        }

        int registeredCount = event.getCapacity() - event.getAvailableSeats();

        request.setAttribute("event", event);
        request.setAttribute("orgName", orgName != null ? orgName : "Unknown Organization");
        request.setAttribute("registeredCount", registeredCount);
        request.setAttribute("isRegistered", isRegistered);
        request.setAttribute("isWaitlisted", isWaitlisted);
        request.setAttribute("loggedIn", user != null);

        request.getRequestDispatcher("/jsp/event-detail.jsp").forward(request, response);
    }
}
