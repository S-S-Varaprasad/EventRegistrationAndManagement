package com.event.controller;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.event.model.Ticket;
import com.event.model.User;
import com.event.service.EventService;

public class MyTicketsServlet extends HttpServlet {
    private EventService eventService = new EventService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        List<Ticket> tickets = eventService.getTicketsByUser(user.getId());
        request.setAttribute("tickets", tickets);
        request.getRequestDispatcher("/jsp/my-tickets.jsp").forward(request, response);
    }
}
