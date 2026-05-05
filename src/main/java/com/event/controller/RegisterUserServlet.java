package com.event.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import com.event.model.User;
import com.event.service.UserService;

public class RegisterUserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String userType = request.getParameter("user_type");

        // Validate inputs
        if (name == null || email == null || password == null || userType == null
            || name.trim().isEmpty() || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/jsp/register.jsp?error=All+fields+are+required");
            return;
        }

        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim());
        user.setPasswordHash(password); // Service layer will hash it
        user.setUserType(userType);

        UserService service = new UserService();
        boolean success = service.register(user);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp?success=Registration+successful.+Please+login.");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/register.jsp?error=Email+already+exists");
        }
    }
}