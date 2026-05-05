package com.event.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import com.event.model.User;
import com.event.service.OrganizationService;

public class HomeServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String context = request.getContextPath();

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(context + "/index.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        // STATE-BASED ADMIN: check if user owns an organization
        OrganizationService orgService = new OrganizationService();
        Integer orgId = orgService.getOrgByAdmin(user.getId());

        if (orgId != null) {
            // User is an organizer
            response.sendRedirect(context + "/jsp/admin-dashboard.jsp");
        } else {
            // Normal user
            response.sendRedirect(context + "/jsp/user-dashboard.jsp");
        }
    }
}
