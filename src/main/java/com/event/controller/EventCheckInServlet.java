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
import com.event.service.OrganizationService;

public class EventCheckInServlet extends HttpServlet {
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

             // Verify this event belongs to the organizer's organization
             com.event.model.Event event = eventService.getEventById(eventId);
             if (event == null || event.getOrganizationId() != orgId) {
                 response.sendRedirect(request.getContextPath() + "/manage-events");
                 return;
             }

             List<Ticket> tickets = eventService.getTicketsByEvent(eventId);

             // Compute analytics
             int totalTickets = tickets.size();
             int checkedIn = 0;
             int activeRemaining = 0;
             for (Ticket t : tickets) {
                 if ("USED".equals(t.getStatus())) checkedIn++;
                 else if ("ACTIVE".equals(t.getStatus())) activeRemaining++;
             }

             // Load team member roster data for team events
             java.util.Map<Integer, String> rosterMap = new java.util.HashMap<>();
             if ("TEAM".equals(event.getEventType())) {
                 com.event.dao.TeamDAO teamDAO = new com.event.dao.TeamDAO();
                 for (Ticket t : tickets) {
                     if (t.getTeamId() != null && !rosterMap.containsKey(t.getTeamId())) {
                         String roster = teamDAO.getRosterByTeamId(t.getTeamId());
                         rosterMap.put(t.getTeamId(), roster);
                     }
                 }
             }

             String eventTitle = event.getTitle();

             request.setAttribute("tickets", tickets);
             request.setAttribute("eventId", eventId);
             request.setAttribute("eventTitle", eventTitle);
             request.setAttribute("totalTickets", totalTickets);
             request.setAttribute("checkedIn", checkedIn);
             request.setAttribute("activeRemaining", activeRemaining);
             request.setAttribute("cancelled", 0);
             request.setAttribute("rosterMap", rosterMap);
             request.setAttribute("memberSchema", event.getMemberFormSchema());
             request.setAttribute("eventType", event.getEventType());
             request.getRequestDispatcher("/jsp/event-checkin.jsp").forward(request, response);
             return;
        }
        response.sendRedirect(request.getContextPath() + "/manage-events");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String ticketId = request.getParameter("ticketId");
        String eventIdStr = request.getParameter("eventId");

        if (ticketId != null && !ticketId.trim().isEmpty()) {
            boolean success = eventService.markTicketUsed(ticketId);
            if (success) {
                session.setAttribute("adminSuccess", "Ticket checked in successfully.");
            } else {
                session.setAttribute("adminError", "Could not check in this ticket. It may already be used or cancelled.");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/event-checkin?eventId=" + eventIdStr);
    }
}
