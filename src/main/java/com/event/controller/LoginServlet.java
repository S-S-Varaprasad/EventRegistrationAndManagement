package com.event.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import com.event.model.User;
import com.event.service.UserService;
import com.event.service.OrganizationService;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String redirect = request.getParameter("redirect");

        String context = request.getContextPath();

        UserService service = new UserService();
        User user = service.login(email, password);

        if (user != null) {

            HttpSession session = request.getSession();
            session.setAttribute("user", user);

            // If coming from "Become Organizer" flow
            if ("create-org".equals(redirect)) {
                response.sendRedirect(context + "/jsp/create-organization.jsp");
                return;
            }

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

        } else {
            response.sendRedirect(context + "/jsp/login.jsp?error=Invalid+Credentials");
        }
    }
}