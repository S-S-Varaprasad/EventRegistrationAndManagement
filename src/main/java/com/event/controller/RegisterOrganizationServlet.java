package com.event.controller;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

import com.event.model.*;
import com.event.service.*;
import com.event.dao.UserDAO;

public class RegisterOrganizationServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        String context = request.getContextPath();

        if (user == null) {
            response.sendRedirect(context + "/jsp/login.jsp");
            return;
        }

        // Check organization limit
        if (user.getOrgCount() >= 2) {
            response.sendRedirect(context + "/jsp/create-organization.jsp?error=Organization+limit+reached+(max+2)");
            return;
        }

        String orgName = request.getParameter("orgName");
        String type = request.getParameter("type");

        if (orgName == null || type == null || orgName.trim().isEmpty() || type.trim().isEmpty()) {
            response.sendRedirect(context + "/jsp/create-organization.jsp?error=All+fields+are+required");
            return;
        }

        Organization org = new Organization();
        org.setName(orgName.trim());
        org.setType(type);
        org.setAdminUserId(user.getId());

        OrganizationService service = new OrganizationService();
        boolean success = service.create(org);

        if (success) {
            // Increment org count
            new UserDAO().incrementOrgCount(user.getId());
            user.setOrgCount(user.getOrgCount() + 1);
            session.setAttribute("user", user);

            response.sendRedirect(context + "/jsp/admin-dashboard.jsp");
        } else {
            response.sendRedirect(context + "/jsp/create-organization.jsp?error=Organization+name+already+exists");
        }
    }
}