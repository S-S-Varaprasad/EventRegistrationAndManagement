package com.event.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.model.User;
import com.event.service.EventService;

public class ReportEventServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String eventIdStr = request.getParameter("eventId");

        if (eventIdStr != null) {
            int eventId = Integer.parseInt(eventIdStr);
            EventService service = new EventService();

            // Delegates to service layer which handles:
            // 1. Duplicate check  2. Insert report  3. Auto-hide at 3 reports
            String result = service.reportEvent(eventId, user.getId());

            if ("Already reported".equals(result)) {
                response.sendRedirect(request.getContextPath() + "/view-events?error=You+already+reported+this+event");
            } else {
                response.sendRedirect(request.getContextPath() + "/view-events?success=Event+Reported+Successfully");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/view-events");
        }
    }
}