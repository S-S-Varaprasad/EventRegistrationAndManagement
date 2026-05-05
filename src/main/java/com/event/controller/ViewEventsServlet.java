package com.event.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import com.event.model.Event;
import com.event.service.EventService;

public class ViewEventsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String query = request.getParameter("search");
        String date = request.getParameter("date");
        String location = request.getParameter("location");
        String eligibility = request.getParameter("eligibility");
        String eventType = request.getParameter("event_type");

        EventService service = new EventService();
        List<Event> events;

        if (query != null || date != null || location != null || eligibility != null || eventType != null) {
            events = service.getFilteredEvents(query, date, location, eligibility, eventType);
        } else {
            events = service.getAllEvents();
        }

        request.setAttribute("events", events);
        request.getRequestDispatcher("/jsp/events.jsp").forward(request, response);
    }
}