package com.event.controller;

import java.io.IOException;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import com.event.model.User;
import com.event.service.EventService;

public class CancelRegistrationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String context = request.getContextPath();

        if (user == null) {
            response.sendRedirect(context + "/jsp/login.jsp");
            return;
        }

        String eventIdParam = request.getParameter("eventId");

        if (eventIdParam != null && !eventIdParam.trim().isEmpty()) {
            int eventId = Integer.parseInt(eventIdParam);
            EventService service = new EventService();
            
            // This will cancel the registration and automatically pop the waitlist
            service.cancelRegistration(user.getId(), eventId);
        }

        response.sendRedirect(context + "/my-events?success=Registration+cancelled.");
    }
}
