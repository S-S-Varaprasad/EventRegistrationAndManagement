package com.event.model;

public class User {
    private int id;
    private String name;
    private String email;
    private String passwordHash;

    // keep if already exists, but do NOT use for logic
    private String role;

    private int orgCount;
    private String userType;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public int getOrgCount() { return orgCount; }
    public void setOrgCount(int orgCount) { this.orgCount = orgCount; }

    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }
}