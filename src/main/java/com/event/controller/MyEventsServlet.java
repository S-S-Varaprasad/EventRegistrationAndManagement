package com.event.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import com.event.model.*;
import com.event.service.EventService;

public class MyEventsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        EventService service = new EventService();
        List<Event> list = service.getRegisteredEvents(user.getId());

        request.setAttribute("events", list);
        request.getRequestDispatcher("/jsp/my-events.jsp").forward(request, response);
    }
}