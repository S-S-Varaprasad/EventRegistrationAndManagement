package com.event.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.dao.NotificationDAO;
import com.event.model.User;

public class NotificationCountServlet extends HttpServlet {

    private NotificationDAO notifDao = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        if (user == null) {
            response.getWriter().write("0");
            return;
        }

        int count = notifDao.getUnreadCount(user.getId());
        response.getWriter().write(String.valueOf(count));
    }
}
