package com.event.model;

import java.sql.Timestamp;

public class Team {
    private int id;
    private String name;
    private int eventId;
    private int leaderUserId;
    private Timestamp createdAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public int getEventId() { return eventId; }
    public void setEventId(int eventId) { this.eventId = eventId; }

    public int getLeaderUserId() { return leaderUserId; }
    public void setLeaderUserId(int leaderUserId) { this.leaderUserId = leaderUserId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
