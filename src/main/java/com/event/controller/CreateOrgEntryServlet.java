package com.event.controller;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

import com.event.model.User;

public class CreateOrgEntryServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = null;

        if (session != null) {
            user = (User) session.getAttribute("user");
        }

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp?redirect=create-org");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/create-organization.jsp");
        }
    }
}