package com.event.model;

import java.sql.Date;

public class Event {

    private int id;
    private String title;
    private String description;
    private Date eventDate;
    private String location;

    private int organizationId;
    private int createdBy;
    private String status;
    private String eligibility;
    
    private int capacity;
    private int availableSeats;
    private double price;
    private String participationMode; // FREE / PAID
    private String eventType; // INDIVIDUAL / TEAM
    private int maxTeamSize;
    private int minTeamSize;
    private String customFormSchema; // JSON String
    private String memberFormSchema; // JSON String for team members
    private int reportCount;
    
    public String getMemberFormSchema() { return memberFormSchema; }
    public void setMemberFormSchema(String memberFormSchema) { this.memberFormSchema = memberFormSchema; }
    
    // Transient fields for display
    private String organizerName;
    private String organizerType;
    
    // QR Code Payment Path
    private String qrCodePath;
    
    public String getQrCodePath() { return qrCodePath; }
    public void setQrCodePath(String qrCodePath) { this.qrCodePath = qrCodePath; }

    public String getOrganizerName() { return organizerName; }
    public void setOrganizerName(String organizerName) { this.organizerName = organizerName; }

    public String getOrganizerType() { return organizerType; }
    public void setOrganizerType(String organizerType) { this.organizerType = organizerType; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public java.sql.Date getEventDate() { return eventDate; }
    public void setEventDate(java.sql.Date eventDate) { this.eventDate = eventDate; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public int getOrganizationId() { return organizationId; }
    public void setOrganizationId(int organizationId) { this.organizationId = organizationId; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getEligibility() { return eligibility; }
    public void setEligibility(String eligibility) { this.eligibility = eligibility; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public int getAvailableSeats() { return availableSeats; }
    public void setAvailableSeats(int availableSeats) { this.availableSeats = availableSeats; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getParticipationMode() { return participationMode; }
    public void setParticipationMode(String participationMode) { this.participationMode = participationMode; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }

    public int getMaxTeamSize() { return maxTeamSize; }
    public void setMaxTeamSize(int maxTeamSize) { this.maxTeamSize = maxTeamSize; }

    public int getMinTeamSize() { return minTeamSize; }
    public void setMinTeamSize(int minTeamSize) { this.minTeamSize = minTeamSize; }

    public String getCustomFormSchema() { return customFormSchema; }
    public void setCustomFormSchema(String customFormSchema) { this.customFormSchema = customFormSchema; }

    public int getReportCount() { return reportCount; }
    public void setReportCount(int reportCount) { this.reportCount = reportCount; }
}