package com.event.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.model.Event;
import com.event.model.Ticket;
import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;
import com.event.dao.TicketDAO;

public class ViewCancellationsServlet extends HttpServlet {

    private EventService eventService = new EventService();
    private OrganizationService orgService = new OrganizationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        Integer orgId = orgService.getOrgByAdmin(user.getId());
        if (orgId == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        if(eventIdStr != null) {
             int eventId = Integer.parseInt(eventIdStr);

             // Verify ownership
             Event event = eventService.getEventById(eventId);
             if (event == null || event.getOrganizationId() != orgId) {
                 response.sendRedirect(request.getContextPath() + "/manage-events");
                 return;
             }

             // Fetch Cancelled Tickets
             TicketDAO ticketDAO = new TicketDAO();
             List<Ticket> cancelledTickets = ticketDAO.getCancelledTicketsByEvent(eventId);

             boolean isPaid = "PAID".equals(event.getParticipationMode());

             request.setAttribute("cancelledTickets", cancelledTickets);
             request.setAttribute("eventId", eventId);
             request.setAttribute("eventTitle", event.getTitle());
             request.setAttribute("isPaid", isPaid);
             request.setAttribute("eventPrice", event.getPrice());
             
             request.getRequestDispatcher("/jsp/view-cancellations.jsp").forward(request, response);
             return;
        }
        
        response.sendRedirect(request.getContextPath() + "/manage-events");
    }
}
