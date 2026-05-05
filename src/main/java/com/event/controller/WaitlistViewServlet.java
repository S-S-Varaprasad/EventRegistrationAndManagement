package com.event.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.model.Event;
import com.event.model.User;
import com.event.dao.EventDAO;
import com.event.service.OrganizationService;

public class WaitlistViewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Authentication
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        // Authorization: must be an organizer
        OrganizationService orgService = new OrganizationService();
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
        EventDAO dao = new EventDAO();

        // Ownership check: event must belong to this organizer's org
        Event event = dao.getEventById(eventId);
        if (event == null || event.getOrganizationId() != orgId) {
            response.sendRedirect(request.getContextPath() + "/manage-events");
            return;
        }

        // Fetch waitlisted users
        List<Map<String, String>> waitlist = dao.getWaitlistByEvent(eventId);

        request.setAttribute("eventTitle", event.getTitle());
        request.setAttribute("eventId", eventId);
        request.setAttribute("waitlist", waitlist);

        request.getRequestDispatcher("/jsp/view-waitlist.jsp").forward(request, response);
    }
}
