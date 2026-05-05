package com.event.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import com.event.model.*;
import com.event.dao.EventDAO;
import com.event.service.OrganizationService;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@WebServlet("/edit-event")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 10)
public class EditEventServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String context = request.getContextPath();

        if (user == null) {
            response.sendRedirect(context + "/jsp/login.jsp");
            return;
        }

        OrganizationService orgService = new OrganizationService();
        Integer orgId = orgService.getOrgByAdmin(user.getId());

        if (orgId == null) {
            response.sendRedirect(context + "/home");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String capacityStr = request.getParameter("capacity");
        
        // Extended Fields
        String eventDate = request.getParameter("eventDate");
        String participationMode = request.getParameter("participationMode");
        String priceStr = request.getParameter("price");
        String eligibility = request.getParameter("eligibility");
        String eventType = request.getParameter("eventType");
        String customFormSchema = request.getParameter("custom_form_schema");
        String memberFormSchema = request.getParameter("member_form_schema");

        if (eventIdStr == null || title == null || location == null || capacityStr == null || eventDate == null) {
            response.sendRedirect(context + "/manage-events?error=Invalid+Input");
            return;
        }

        try {
            int eventId = Integer.parseInt(eventIdStr);
            int newCapacity = Integer.parseInt(capacityStr);
            
            // DATE VALIDATION
            java.sql.Date sqlDate = java.sql.Date.valueOf(eventDate);
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            if (sqlDate.before(today)) {
                response.sendRedirect(context + "/jsp/edit-event.jsp?eventId=" + eventId + "&error=Event+date+cannot+be+in+the+past.");
                return;
            }
            
            double price = 0.0;
            if ("PAID".equals(participationMode) && priceStr != null && !priceStr.trim().isEmpty()) {
                price = Double.parseDouble(priceStr);
            }
            
            EventDAO dao = new EventDAO();
            Event current = dao.getEventById(eventId);
            
            if (current == null || current.getOrganizationId() != orgId) {
                response.sendRedirect(context + "/manage-events?error=Unauthorized");
                return;
            }

            int registeredUsers = current.getCapacity() - current.getAvailableSeats();
            if (newCapacity < registeredUsers) {
                response.sendRedirect(context + "/jsp/edit-event.jsp?eventId=" + eventId + "&error=Capacity+cannot+be+less+than+registered+users");
                return;
            }

            int diff = newCapacity - current.getCapacity();
            int newAvailable = current.getAvailableSeats() + diff;

            Event e = new Event();
            e.setId(eventId);
            e.setTitle(title.trim());
            e.setDescription(description != null ? description.trim() : "");
            e.setLocation(location.trim());
            e.setCapacity(newCapacity);
            e.setAvailableSeats(newAvailable);
            
            // Set Extended
            e.setEventDate(sqlDate);
            e.setParticipationMode(participationMode != null ? participationMode : "FREE");
            e.setPrice(price);
            e.setEligibility(eligibility != null ? eligibility : "OPEN");
            e.setEventType(eventType != null ? eventType : "INDIVIDUAL");
            e.setCustomFormSchema(customFormSchema != null ? customFormSchema : "[]");
            e.setMemberFormSchema(memberFormSchema != null ? memberFormSchema : "[]");
            
            String customSchema = request.getParameter("custom_form_schema");
            e.setCustomFormSchema(customSchema != null ? customSchema.trim() : "");
            
            // QR Code Upload (Optional on Edit)
            if ("PAID".equals(participationMode)) {
                Part filePart = request.getPart("qr_code");
                if (filePart != null && filePart.getSize() > 0) {
                    String uploadDir = getServletContext().getRealPath("/") + "uploads";
                    File uploadDirFile = new File(uploadDir);
                    if (!uploadDirFile.exists()) uploadDirFile.mkdir();
                    
                    String fileName = "qr_" + UUID.randomUUID().toString() + ".jpg";
                    File file = new File(uploadDirFile, fileName);
                    
                    try (InputStream input = filePart.getInputStream()) {
                        Files.copy(input, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                        e.setQrCodePath("uploads/" + fileName);
                    }
                }
            }

            boolean success = dao.updateEvent(e);
            if (success) {
                response.sendRedirect(context + "/manage-events?success=Event+Updated");
            } else {
                response.sendRedirect(context + "/jsp/edit-event.jsp?eventId=" + eventId + "&error=Database+Update+Failed");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(context + "/manage-events?error=Invalid+Format");
        }
    }
}
