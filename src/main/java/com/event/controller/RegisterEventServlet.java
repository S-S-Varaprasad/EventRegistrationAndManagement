package com.event.controller;

import java.io.IOException;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import com.event.model.*;
import com.event.service.*;

public class RegisterEventServlet extends HttpServlet {

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

        if (eventIdParam == null || eventIdParam.trim().isEmpty()) {
            response.sendRedirect(context + "/view-events?error=Invalid+event");
            return;
        }

        int eventId = Integer.parseInt(eventIdParam);

        EventService service = new EventService();

        // Service handles eligibility + duplicate check
        String result = service.register(user, eventId);

        if ("SUCCESS".equals(result)) {
            response.sendRedirect(context + "/view-events?success=Registered+successfully");
        } else if ("JOINED_WAITLIST".equals(result)) {
            response.sendRedirect(context + "/view-events?success=Event+full.+You+have+been+added+to+the+Waitlist");
        } else {
            response.sendRedirect(context + "/view-events?error=" + result.replace(" ", "+"));
        }
    }
}