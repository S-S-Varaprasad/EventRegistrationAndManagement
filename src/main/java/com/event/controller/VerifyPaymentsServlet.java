package com.event.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;

public class VerifyPaymentsServlet extends HttpServlet {
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

        List<Map<String, String>> pendingList = eventService.getPendingPayments(orgId);
        request.setAttribute("pendingList", pendingList);
        request.getRequestDispatcher("/jsp/verify-payments.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        String action = request.getParameter("action");
        String paymentIdStr = request.getParameter("paymentId");

        if (paymentIdStr != null && !paymentIdStr.trim().isEmpty()) {
            int paymentId = Integer.parseInt(paymentIdStr);
            if ("APPROVE".equalsIgnoreCase(action)) {
                eventService.approvePayment(paymentId);
                session.setAttribute("adminSuccess", "Payment successfully verified! Revenue updated.");
            } else if ("REJECT".equalsIgnoreCase(action)) {
                eventService.rejectPayment(paymentId);
                session.setAttribute("adminSuccess", "Payment rejected! Waitlist auto-promoted in the background.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/verify-payments");
    }
}
