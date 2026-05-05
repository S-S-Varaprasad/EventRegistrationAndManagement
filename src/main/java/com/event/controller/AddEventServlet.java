package com.event.controller;

import java.io.IOException;
import com.event.model.Event;
import com.event.model.Organization;
import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 1024 * 1024 * 5, maxRequestSize = 1024 * 1024 * 10)
public class AddEventServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String context = request.getContextPath();
        
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(context + "/jsp/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        OrganizationService orgService = new OrganizationService();
        Integer orgId = orgService.getOrgByAdmin(user.getId());

        if (orgId == null) {
            response.sendRedirect(context + "/jsp/add-event.jsp?error=You+are+not+an+organizer.");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String eventDate = request.getParameter("date");
        String location = request.getParameter("location");
        String eligibility = request.getParameter("eligibility");
        String capacityStr = request.getParameter("capacity");

        String participationMode = request.getParameter("participation_mode");
        String priceStr = request.getParameter("price");
        
        String eventType = request.getParameter("event_type");
        String minTeamStr = request.getParameter("min_team_size");
        String maxTeamStr = request.getParameter("max_team_size");
        
        String customFormSchema = request.getParameter("custom_form_schema");
        String memberFormSchema = request.getParameter("member_form_schema");

        if (title == null || eventDate == null || location == null || capacityStr == null) {
            response.sendRedirect(context + "/jsp/add-event.jsp?error=Missing+required+fields");
            return;
        }

        try {
            int capacity = Integer.parseInt(capacityStr);
            
            // DATE VALIDATION (Point 8)
            java.sql.Date sqlDate = java.sql.Date.valueOf(eventDate);
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            if (sqlDate.before(today)) {
                response.sendRedirect(context + "/jsp/add-event.jsp?error=Event+date+cannot+be+in+the+past.");
                return;
            }
            
            double price = 0.0;
            if ("PAID".equals(participationMode) && priceStr != null && !priceStr.trim().isEmpty()) {
                price = Double.parseDouble(priceStr);
            }

            int minTeam = 1;
            int maxTeam = 1;
            if ("TEAM".equals(eventType)) {
                if (minTeamStr != null && !minTeamStr.isEmpty()) minTeam = Integer.parseInt(minTeamStr);
                if (maxTeamStr != null && !maxTeamStr.isEmpty()) maxTeam = Integer.parseInt(maxTeamStr);
            }

            Event e = new Event();
            e.setTitle(title.trim());
            e.setDescription(description != null ? description.trim() : "");
            e.setEventDate(java.sql.Date.valueOf(eventDate));
            e.setLocation(location.trim());
            e.setOrganizationId(orgId);
            e.setCreatedBy(user.getId());
            e.setStatus("ACTIVE");
            e.setEligibility(eligibility != null ? eligibility : "OPEN");
            e.setCapacity(capacity);
            e.setAvailableSeats(capacity);
            e.setParticipationMode(participationMode != null ? participationMode : "FREE");
            e.setPrice(price);
            e.setEventType(eventType != null ? eventType : "INDIVIDUAL");
            e.setMinTeamSize(minTeam);
            e.setMaxTeamSize(maxTeam);
            
            // Clean up custom schema logic
            if (customFormSchema != null && customFormSchema.trim().length() > 2) {
                e.setCustomFormSchema(customFormSchema.trim());
            }
            if (memberFormSchema != null && memberFormSchema.trim().length() > 2) {
                e.setMemberFormSchema(memberFormSchema.trim());
            }

            // QR Code Upload
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

            EventService service = new EventService();
            boolean success = service.createEvent(e);

            if (success) {
                response.sendRedirect(context + "/manage-events");
            } else {
                response.sendRedirect(context + "/jsp/add-event.jsp?error=Event+with+same+title+and+date+already+exists");
            }
        } catch (Exception ex) {
            response.sendRedirect(context + "/jsp/add-event.jsp?error=Invalid+number+format");
        }
    }
}