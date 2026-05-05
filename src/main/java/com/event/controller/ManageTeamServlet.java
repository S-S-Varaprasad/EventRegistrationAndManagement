package com.event.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.dao.TeamDAO;
import com.event.dao.EventDAO;
import com.event.model.Team;
import com.event.model.Event;
import com.event.model.User;

@WebServlet("/manage-team")
public class ManageTeamServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String teamIdStr = request.getParameter("teamId");
        if (teamIdStr == null) {
            response.sendRedirect(request.getContextPath() + "/my-events");
            return;
        }

        try {
            int teamId = Integer.parseInt(teamIdStr);
            TeamDAO teamDAO = new TeamDAO();
            
            // SECURITY CHECK: Verify user is the leader
            Integer actualLeaderId = teamDAO.getLeaderIdByTeamId(teamId);
            if (actualLeaderId == null || !actualLeaderId.equals(user.getId())) {
                response.sendRedirect(request.getContextPath() + "/my-events?error=Unauthorized+Access");
                return;
            }

            EventDAO eventDAO = new EventDAO();
            Integer eventId = teamDAO.getEventIdByTeamId(teamId);
            Event event = (eventId != null) ? eventDAO.getEventById(eventId) : null;
            String roster = teamDAO.getRosterByTeamId(teamId);
            boolean leaderInRoster = teamDAO.isLeaderIncluded(teamId);

            request.setAttribute("event", event);
            request.setAttribute("rosterJson", roster);
            request.setAttribute("teamId", teamId);
            request.setAttribute("leaderInRoster", leaderInRoster);
            request.getRequestDispatcher("/jsp/manage-team.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/my-events");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String teamIdStr = request.getParameter("teamId");
        String rosterJson = request.getParameter("roster_json");

        if (teamIdStr != null && rosterJson != null) {
            new TeamDAO().updateTeamRoster(Integer.parseInt(teamIdStr), rosterJson);
            response.sendRedirect(request.getContextPath() + "/my-events?success=Team+Roster+Updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/my-events?error=Update+Failed");
        }
    }
}
