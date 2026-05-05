package com.event.dao;

import java.sql.*;
import java.util.*;
import com.event.model.Event;
import com.event.util.DBConnection;

public class EventDAO {

    // Add a new event
    public boolean createEvent(Event event) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "INSERT INTO events (title, description, event_date, location, organization_id, created_by, status, eligibility, capacity, available_seats, price, participation_mode, event_type, min_team_size, max_team_size, custom_form_schema, member_form_schema, qr_code_path) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, event.getTitle());
            ps.setString(2, event.getDescription());
            ps.setDate(3, event.getEventDate());
            ps.setString(4, event.getLocation());
            ps.setInt(5, event.getOrganizationId());
            ps.setInt(6, event.getCreatedBy());
            ps.setString(7, event.getStatus());
            ps.setString(8, event.getEligibility());
            ps.setInt(9, event.getCapacity());
            ps.setInt(10, event.getCapacity());
            ps.setDouble(11, event.getPrice());
            ps.setString(12, event.getParticipationMode());
            ps.setString(13, event.getEventType());
            ps.setInt(14, event.getMinTeamSize());
            ps.setInt(15, event.getMaxTeamSize());
            ps.setString(16, event.getCustomFormSchema());
            ps.setString(17, event.getMemberFormSchema());
            ps.setString(18, event.getQrCodePath());
            
            return ps.executeUpdate() > 0;

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return false;
    }

    // Update Event safely without dropping associations
    public boolean updateEvent(Event e) {
        try (Connection con = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("UPDATE events SET title=?, description=?, location=?, capacity=?, available_seats=?, event_date=?, participation_mode=?, price=?, eligibility=?, event_type=?, custom_form_schema=?, member_form_schema=?");
            if (e.getQrCodePath() != null && !e.getQrCodePath().isEmpty()) {
                sql.append(", qr_code_path=?");
            }
            sql.append(" WHERE id=?");
            PreparedStatement ps = con.prepareStatement(sql.toString());
            ps.setString(1, e.getTitle());
            ps.setString(2, e.getDescription());
            ps.setString(3, e.getLocation());
            ps.setInt(4, e.getCapacity());
            ps.setInt(5, e.getAvailableSeats());
            ps.setDate(6, e.getEventDate());
            ps.setString(7, e.getParticipationMode());
            ps.setDouble(8, e.getPrice());
            ps.setString(9, e.getEligibility());
            ps.setString(10, e.getEventType());
            ps.setString(11, e.getCustomFormSchema());
            ps.setString(12, e.getMemberFormSchema());
            int pIndex = 13;
            if (e.getQrCodePath() != null && !e.getQrCodePath().isEmpty()) {
                ps.setString(pIndex++, e.getQrCodePath());
            }
            ps.setInt(pIndex, e.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception ex) { ex.printStackTrace(); }
        return false;
    }

    // Filtered Events
    public List<Event> getFilteredEvents(String query, String date, String location, String eligibility, String eventType) {
        List<Event> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("SELECT e.*, o.name AS org_name, o.type AS org_type FROM events e JOIN organizations o ON e.organization_id = o.id WHERE e.status='ACTIVE' AND e.event_date >= CURDATE()");
            
            if (query != null && !query.trim().isEmpty()) sql.append(" AND e.title LIKE ?");
            if (date != null && !date.trim().isEmpty()) sql.append(" AND e.event_date = ?");
            if (location != null && !location.trim().isEmpty()) sql.append(" AND e.location LIKE ?");
            if (eligibility != null && !eligibility.trim().isEmpty()) sql.append(" AND e.eligibility = ?");
            if (eventType != null && !eventType.trim().isEmpty()) sql.append(" AND e.event_type = ?");
            
            sql.append(" ORDER BY e.event_date ASC");

            PreparedStatement ps = con.prepareStatement(sql.toString());
            int index = 1;
            
            if (query != null && !query.trim().isEmpty()) ps.setString(index++, "%" + query.trim() + "%");
            if (date != null && !date.trim().isEmpty()) ps.setDate(index++, java.sql.Date.valueOf(date));
            if (location != null && !location.trim().isEmpty()) ps.setString(index++, "%" + location.trim() + "%");
            if (eligibility != null && !eligibility.trim().isEmpty()) ps.setString(index++, eligibility);
            if (eventType != null && !eventType.trim().isEmpty()) ps.setString(index++, eventType);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractEvent(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Get all ACTIVE events
    public List<Event> getAllEvents() {
        List<Event> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT e.*, o.name AS org_name, o.type AS org_type FROM events e JOIN organizations o ON e.organization_id = o.id WHERE e.status='ACTIVE' AND e.event_date >= CURDATE()";
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Event e = extractEvent(rs);
                list.add(e);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Get single event by ID
    public Event getEventById(int eventId) {
        Event event = null;

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT e.*, o.name AS org_name, o.type AS org_type FROM events e JOIN organizations o ON e.organization_id = o.id WHERE e.id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, eventId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                event = extractEvent(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return event;
    }

    // Check if user is already registered for an event
    public boolean isRegistered(int userId, int eventId) {
        try (Connection con = DBConnection.getConnection()) {

            String sql = "SELECT 1 FROM registrations WHERE user_id=? AND event_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, eventId);

            return ps.executeQuery().next();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Register user for an event
    public boolean registerEvent(int userId, int eventId) {
        try (Connection con = DBConnection.getConnection()) {

            String sql = "INSERT INTO registrations(user_id, event_id) VALUES(?,?)";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.setInt(2, eventId);

            ps.executeUpdate();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get events that a user has registered for
    public List<Event> getRegisteredEvents(int userId) {
        List<Event> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT e.*, o.name AS org_name, o.type AS org_type FROM events e JOIN registrations r ON e.id=r.event_id JOIN organizations o ON e.organization_id = o.id WHERE r.user_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Event e = extractEvent(rs);
                list.add(e);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Check if user already reported this event
    public boolean hasReported(int userId, int eventId) {
        try (Connection con = DBConnection.getConnection()) {

            String sql = "SELECT 1 FROM reports WHERE user_id=? AND event_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, eventId);

            return ps.executeQuery().next();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Report an event and auto-hide if reports >= 3
    public void reportEvent(int eventId, int userId) {
        try (Connection con = DBConnection.getConnection()) {

            // Insert the report
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO reports(event_id, user_id, reason) VALUES(?,?,?)");
            ps.setInt(1, eventId);
            ps.setInt(2, userId);
            ps.setString(3, "User Report");
            ps.executeUpdate();

            // Count total reports for this event
            PreparedStatement cps = con.prepareStatement(
                "SELECT COUNT(*) FROM reports WHERE event_id=?");
            cps.setInt(1, eventId);

            ResultSet rs = cps.executeQuery();
            rs.next();

            // Auto-hide if 3 or more reports
            if (rs.getInt(1) >= 3) {
                PreparedStatement ups = con.prepareStatement(
                    "UPDATE events SET status='HIDDEN' WHERE id=?");
                ups.setInt(1, eventId);
                ups.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Get events for a specific organization (For Admin/Organizer dashboard)
    public List<Event> getEventsByOrganization(int orgId) {
        List<Event> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT e.*, o.name AS org_name, o.type AS org_type FROM events e JOIN organizations o ON e.organization_id = o.id WHERE e.organization_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, orgId);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(extractEvent(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // Helper: extract Event from ResultSet
    private Event extractEvent(ResultSet rs) throws SQLException {
        Event e = new Event();
        e.setId(rs.getInt("id"));
        e.setTitle(rs.getString("title"));
        e.setDescription(rs.getString("description"));
        e.setEventDate(rs.getDate("event_date"));
        e.setLocation(rs.getString("location"));
        e.setOrganizationId(rs.getInt("organization_id"));
        e.setCreatedBy(rs.getInt("created_by"));
        e.setStatus(rs.getString("status"));
        e.setEligibility(rs.getString("eligibility"));
        e.setCapacity(rs.getInt("capacity"));
        e.setAvailableSeats(rs.getInt("available_seats"));
        e.setPrice(rs.getDouble("price"));
        e.setParticipationMode(rs.getString("participation_mode"));
        e.setEventType(rs.getString("event_type"));
        e.setMaxTeamSize(rs.getInt("max_team_size"));
        e.setMinTeamSize(rs.getInt("min_team_size"));
        e.setCustomFormSchema(rs.getString("custom_form_schema"));
        e.setMemberFormSchema(rs.getString("member_form_schema"));
        e.setReportCount(rs.getInt("report_count"));
        
        try { e.setQrCodePath(rs.getString("qr_code_path")); } catch (SQLException ignore) {}

        try {
            e.setOrganizerName(rs.getString("org_name"));
            e.setOrganizerType(rs.getString("org_type"));
        } catch (SQLException ignore) {
            // org_name and org_type might not be present in all queries
        }
        
        return e;
    }

    // Advanced Registration Payload Handling
    public String registerWithAdvancedPayload(int userId, int eventId, Integer teamId, String teamName, String rosterJson, String customAnswers, String paymentPath) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Check if already registered
            String chkSql = "SELECT id FROM registrations WHERE user_id=? AND event_id=?";
            PreparedStatement chk = con.prepareStatement(chkSql);
            chk.setInt(1, userId);
            chk.setInt(2, eventId);
            ResultSet rs = chk.executeQuery();
            if (rs.next()) return "ALREADY_REGISTERED";

            // Check capacity and price
            String capSql = "SELECT available_seats, price, participation_mode, event_type FROM events WHERE id=? FOR UPDATE";
            PreparedStatement capPs = con.prepareStatement(capSql);
            capPs.setInt(1, eventId);
            ResultSet capRs = capPs.executeQuery();
            
            int seats = 0;
            double price = 0.0;
            String partMode = "FREE";
            String eventType = "INDIVIDUAL";
            
            if (capRs.next()) {
                seats = capRs.getInt("available_seats");
                price = capRs.getDouble("price");
                partMode = capRs.getString("participation_mode");
                eventType = capRs.getString("event_type");
            }

            boolean isNewSlot = true; 
            if ("TEAM".equals(eventType) && teamId != null) {
                // Check if user is leader - only leader consumes a team slot
                PreparedStatement lps = con.prepareStatement("SELECT leader_user_id FROM teams WHERE id=?");
                lps.setInt(1, teamId);
                ResultSet lrs = lps.executeQuery();
                if (lrs.next()) {
                    int leaderId = lrs.getInt("leader_user_id");
                    if (userId != leaderId) {
                        isNewSlot = false; // Member joining existing team slot already accounted for
                    }
                }
            }

            // A new slot requires an available seat. Existing team members don't consume new slots.
            if (seats > 0 || !isNewSlot) {
                // Register User normally
                String insSql = "INSERT INTO registrations(user_id, event_id, team_id, custom_answers, payment_screenshot_path) VALUES(?,?,?,?,?)";
                PreparedStatement insPs = con.prepareStatement(insSql);
                insPs.setInt(1, userId);
                insPs.setInt(2, eventId);
                if (teamId != null) insPs.setInt(3, teamId); else insPs.setNull(3, java.sql.Types.INTEGER);
                insPs.setString(4, customAnswers);
                insPs.setString(5, paymentPath);
                insPs.executeUpdate();

                // Advanced Gateway: Insert PENDING payment block if PAID
                if ("PAID".equals(partMode) && price > 0) {
                    String paySql = "INSERT INTO payments(user_id, event_id, amount, status, payment_screenshot_path) VALUES(?,?,?,?,?)";
                    PreparedStatement payPs = con.prepareStatement(paySql);
                    payPs.setInt(1, userId);
                    payPs.setInt(2, eventId);
                    payPs.setDouble(3, price);
                    payPs.setString(4, "PENDING");
                    payPs.setString(5, paymentPath);
                    payPs.executeUpdate();
                }

                // Decrement Capacity ONLY for new slots (individual or team leader)
                if (isNewSlot) {
                    String decSql = "UPDATE events SET available_seats = available_seats - 1 WHERE id=?";
                    PreparedStatement decPs = con.prepareStatement(decSql);
                    decPs.setInt(1, eventId);
                    decPs.executeUpdate();
                }

                // Advanced Ticketing: Generate Ticket instantly if FREE
                if ("FREE".equals(partMode) || price <= 0) {
                    new TicketDAO().generateTicket(con, eventId, userId, teamId);
                }
                
                con.commit();
                return "SUCCESS";
            } else {
                // Waitlist User WITH DATA ESCROW
                String waitSql = "INSERT INTO waitlist(user_id, event_id, payment_screenshot_path, team_name, member_data) VALUES(?,?,?,?,?)";
                PreparedStatement waitPs = con.prepareStatement(waitSql);
                waitPs.setInt(1, userId);
                waitPs.setInt(2, eventId);
                waitPs.setString(3, paymentPath);
                waitPs.setString(4, teamName);
                waitPs.setString(5, rosterJson);
                waitPs.executeUpdate();
                
                con.commit();
                return "WAITLIST";
            }
        } catch (Exception ex) {
            try { if (con != null) con.rollback(); } catch (Exception e) {}
            return "ERROR";
        } finally {
            try { if (con != null) { con.setAutoCommit(true); con.close(); } } catch (Exception e) {}
        }
    }

    // Fraud/Duplicate Check
    public boolean isEventDuplicate(String title, java.sql.Date date) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT 1 FROM events WHERE title=? AND event_date=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, title);
            ps.setDate(2, date);
            return ps.executeQuery().next();
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // Capacity management
    public void decrementSeats(int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("UPDATE events SET available_seats = available_seats - 1 WHERE id=? AND available_seats > 0");
            ps.setInt(1, eventId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    public void incrementSeats(int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("UPDATE events SET available_seats = available_seats + 1 WHERE id=?");
            ps.setInt(1, eventId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Waitlist System
    public boolean joinWaitlist(int userId, int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("INSERT INTO waitlist(user_id, event_id) VALUES(?,?)");
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean isWaitlisted(int userId, int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("SELECT 1 FROM waitlist WHERE user_id=? AND event_id=?");
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            return ps.executeQuery().next();
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public Integer popWaitlist(int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("SELECT user_id FROM waitlist WHERE event_id=? ORDER BY waitlisted_at ASC LIMIT 1");
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("user_id");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null; // Nobody on waitlist
    }

    public void removeFromWaitlist(int userId, int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("DELETE FROM waitlist WHERE user_id=? AND event_id=?");
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Payment System
    public void recordPayment(int userId, int eventId, double amount, String status) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("INSERT INTO payments(user_id, event_id, amount, status) VALUES(?,?,?,?)");
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ps.setDouble(3, amount);
            ps.setString(4, status);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Advanced Cancel Registration with Auto-Waitlist Promotion
    public void cancelRegistration(int userId, int eventId) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // 1. Determine if Team Leader or Individual
            Integer teamIdToDrop = null;
            String chkSql = "SELECT team_id FROM registrations WHERE user_id=? AND event_id=?";
            PreparedStatement chkPs = con.prepareStatement(chkSql);
            chkPs.setInt(1, userId);
            chkPs.setInt(2, eventId);
            ResultSet rs = chkPs.executeQuery();
            
            if (rs.next()) {
                teamIdToDrop = rs.getObject("team_id", Integer.class);
            }

            int freedSeats = 0;

            if (teamIdToDrop != null) {
                // Team Cancellation -> Check if user is Leader
                String tSql = "SELECT leader_user_id FROM teams WHERE id=?";
                PreparedStatement tPs = con.prepareStatement(tSql);
                tPs.setInt(1, teamIdToDrop);
                ResultSet tRs = tPs.executeQuery();
                if (tRs.next() && tRs.getInt("leader_user_id") == userId) {
                    // Leader is canceling -> Drop ALL registrations for this team
                    // Freed seats is 1 because 1 team slot is freed
                    freedSeats = 1; 
                    
                    // Mark TEAM ticket as CANCELLED before the team constraints cascade delete it
                    new TicketDAO().cancelTicket(con, eventId, null, teamIdToDrop);
                    
                    // Cascade constraints take care of registrations if we delete team
                    PreparedStatement delTPs = con.prepareStatement("DELETE FROM teams WHERE id=?");
                    delTPs.setInt(1, teamIdToDrop);
                    delTPs.executeUpdate();
                } else {
                    // Individual member dropping out of team
                    // Slot is NOT freed because the team still exists
                    freedSeats = 0;
                    PreparedStatement psDrop = con.prepareStatement("DELETE FROM registrations WHERE user_id=? AND event_id=?");
                    psDrop.setInt(1, userId);
                    psDrop.setInt(2, eventId);
                    psDrop.executeUpdate();
                }
            } else {
                // Standard Individual Drop
                freedSeats = 1;
                
                // Mark INDIVIDUAL ticket as CANCELLED BEFORE standard individual drop
                new TicketDAO().cancelTicket(con, eventId, userId, null);
                
                PreparedStatement psDrop = con.prepareStatement("DELETE FROM registrations WHERE user_id=? AND event_id=?");
                psDrop.setInt(1, userId);
                psDrop.setInt(2, eventId);
                psDrop.executeUpdate();
            }

            // 2. Restore Capacity
            if (freedSeats > 0) {
                // Fetch price, part mode and title
                double price = 0.0;
                String partMode = "FREE";
                String eventTitle = "an event";
                PreparedStatement pcm = con.prepareStatement("SELECT price, participation_mode, title FROM events WHERE id=?");
                pcm.setInt(1, eventId);
                ResultSet pmrs = pcm.executeQuery();
                if(pmrs.next()) {
                     price = pmrs.getDouble("price");
                     partMode = pmrs.getString("participation_mode");
                     eventTitle = pmrs.getString("title");
                }

                PreparedStatement incPs = con.prepareStatement("UPDATE events SET available_seats = available_seats + ? WHERE id=?");
                incPs.setInt(1, freedSeats);
                incPs.setInt(2, eventId);
                incPs.executeUpdate();
                
                // 3. Auto-promote from Waitlist sequentially
                for (int i = 0; i < freedSeats; i++) {
                    String wqSql = "SELECT id, user_id, payment_screenshot_path, team_name, member_data FROM waitlist WHERE event_id=? ORDER BY waitlisted_at ASC LIMIT 1 FOR UPDATE";
                    PreparedStatement wqPs = con.prepareStatement(wqSql);
                    wqPs.setInt(1, eventId);
                    ResultSet wqRs = wqPs.executeQuery();
                    
                    if (wqRs.next()) {
                        int wId = wqRs.getInt("id");
                        int wUserId = wqRs.getInt("user_id");
                        String wPaymentPath = wqRs.getString("payment_screenshot_path");
                        String wTeamName = wqRs.getString("team_name");
                        String wRoster = wqRs.getString("member_data");

                        Integer wTeamId = null;
                        if (wTeamName != null && !wTeamName.isEmpty()) {
                            // Recover Team from Escrow
                            PreparedStatement insTPs = con.prepareStatement("INSERT INTO teams(name, event_id, leader_user_id) VALUES(?,?,?)", java.sql.Statement.RETURN_GENERATED_KEYS);
                            insTPs.setString(1, wTeamName);
                            insTPs.setInt(2, eventId);
                            insTPs.setInt(3, wUserId);
                            insTPs.executeUpdate();
                            ResultSet tKeys = insTPs.getGeneratedKeys();
                            if (tKeys.next()) {
                                wTeamId = tKeys.getInt(1);
                                // Recover Roster from Escrow
                                if (wRoster != null) {
                                    new TeamDAO().saveTeamRoster(wTeamId, wRoster);
                                }
                            }
                        }

                        // Insert to registrations retaining escrow image and recovered teamId
                        PreparedStatement insRegPs = con.prepareStatement("INSERT INTO registrations(user_id, event_id, team_id, payment_screenshot_path) VALUES(?,?,?,?)");
                        insRegPs.setInt(1, wUserId);
                        insRegPs.setInt(2, eventId);
                        if (wTeamId != null) insRegPs.setInt(3, wTeamId); else insRegPs.setNull(3, java.sql.Types.INTEGER);
                        insRegPs.setString(4, wPaymentPath);
                        insRegPs.executeUpdate();
                        
                        // Advanced Gateway: Insert PENDING payment block if PAID
                        if ("PAID".equals(partMode) && price > 0) {
                            String paySql = "INSERT INTO payments(user_id, event_id, amount, status, payment_screenshot_path) VALUES(?,?,?,?,?)";
                            PreparedStatement payPs = con.prepareStatement(paySql);
                            payPs.setInt(1, wUserId);
                            payPs.setInt(2, eventId);
                            payPs.setDouble(3, price);
                            payPs.setString(4, "PENDING");
                            payPs.setString(5, wPaymentPath);
                            payPs.executeUpdate();
                        }

                        // Decrement seat
                        PreparedStatement decPs = con.prepareStatement("UPDATE events SET available_seats = available_seats - 1 WHERE id=?");
                        decPs.setInt(1, eventId);
                        decPs.executeUpdate();

                        // Advanced Ticketing: Generate Ticket for promoted waitlist user if FREE
                        if ("FREE".equals(partMode) || price <= 0) {
                            new TicketDAO().generateTicket(con, eventId, wUserId, wTeamId);
                        }

                        // Notify promoted user
                        new NotificationDAO().addNotification(con, wUserId,
                            "A spot opened up for '" + eventTitle + "' and you have been registered from the waitlist.");

                        // Remove from waitlist queue
                        PreparedStatement rmPs = con.prepareStatement("DELETE FROM waitlist WHERE id=?");
                        rmPs.setInt(1, wId);
                        rmPs.executeUpdate();
                    } else {
                        break; // Queue empty
                    }
                }
            }
            
            con.commit();
        } catch (Exception ex) {
            try { if (con != null) con.rollback(); } catch (Exception e) {}
            ex.printStackTrace();
        } finally {
            try { if (con != null) { con.setAutoCommit(true); con.close(); } } catch (Exception e) {}
        }
    }

    // Toggle event status (HIDE / UNHIDE)
    public void toggleEventStatus(int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            // First get current status
            String currentStatus = "ACTIVE";
            PreparedStatement fetchPs = con.prepareStatement("SELECT status FROM events WHERE id=?");
            fetchPs.setInt(1, eventId);
            ResultSet rs = fetchPs.executeQuery();
            if (rs.next()) {
                 currentStatus = rs.getString("status");
            }
            
            String newStatus = "ACTIVE".equals(currentStatus) ? "HIDDEN" : "ACTIVE";

            PreparedStatement ps = con.prepareStatement("UPDATE events SET status=? WHERE id=?");
            ps.setString(1, newStatus);
            ps.setInt(2, eventId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Analytics: Total Revenue
    public double getEventRevenue(int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("SELECT SUM(amount) FROM payments WHERE event_id=? AND status='SUCCESS'");
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0.0;
    }

    // Get all registered User IDs for Broadcast Announcements
    public java.util.List<Integer> getRegisteredUserIds(int eventId) {
        java.util.List<Integer> userIds = new java.util.ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("SELECT user_id FROM registrations WHERE event_id=?");
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                userIds.add(rs.getInt("user_id"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return userIds;
    }

    // Payment Verification Module
    public java.util.List<java.util.Map<String, String>> getPendingPayments(int orgId) {
        java.util.List<java.util.Map<String, String>> list = new java.util.ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT p.id, e.title, u.name, u.email, p.amount, p.payment_screenshot_path " +
                         "FROM payments p " +
                         "JOIN events e ON p.event_id = e.id " +
                         "JOIN users u ON p.user_id = u.id " +
                         "WHERE e.organization_id = ? AND p.status = 'PENDING'";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, orgId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String, String> map = new java.util.HashMap<>();
                map.put("paymentId", String.valueOf(rs.getInt("id")));
                map.put("eventTitle", rs.getString("title"));
                map.put("userName", rs.getString("name"));
                map.put("userEmail", rs.getString("email"));
                map.put("amount", String.format("%.0f", rs.getDouble("amount")));
                map.put("screenshot", rs.getString("payment_screenshot_path"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean approvePayment(int paymentId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("UPDATE payments SET status='SUCCESS' WHERE id=?");
            ps.setInt(1, paymentId);
            if(ps.executeUpdate() > 0) {
                // Advanced Ticketing: Payment successful -> cut the ticket natively
                PreparedStatement ps2 = con.prepareStatement("SELECT user_id, event_id FROM payments WHERE id=?");
                ps2.setInt(1, paymentId);
                ResultSet rs = ps2.executeQuery();
                if(rs.next()) {
                     int uId = rs.getInt("user_id");
                     int eId = rs.getInt("event_id");
                     Integer teamId = null;
                     PreparedStatement rs3 = con.prepareStatement("SELECT team_id FROM registrations WHERE user_id=? AND event_id=?");
                     rs3.setInt(1, uId); rs3.setInt(2, eId);
                     ResultSet trs = rs3.executeQuery();
                     if(trs.next()) {
                          teamId = trs.getObject("team_id") != null ? trs.getInt("team_id") : null;
                     }
                     new TicketDAO().generateTicket(con, eId, uId, teamId);

                     // Notify user of successful payment verification
                     PreparedStatement titlePs = con.prepareStatement("SELECT title FROM events WHERE id=?");
                     titlePs.setInt(1, eId);
                     ResultSet titleRs = titlePs.executeQuery();
                     String evTitle = titleRs.next() ? titleRs.getString("title") : "an event";
                     new NotificationDAO().addNotification(con, uId,
                         "Payment verified for '" + evTitle + "'. Your ticket is now available in My Tickets.");
                }
                return true;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public int[] rejectPaymentAndGetDetails(int paymentId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps1 = con.prepareStatement("SELECT p.user_id, p.event_id, e.title FROM payments p JOIN events e ON p.event_id = e.id WHERE p.id=?");
            ps1.setInt(1, paymentId);
            ResultSet rs = ps1.executeQuery();
            if (rs.next()) {
                int[] data = new int[]{rs.getInt("user_id"), rs.getInt("event_id")};
                String evTitle = rs.getString("title");
                PreparedStatement ps2 = con.prepareStatement("UPDATE payments SET status='FAILED' WHERE id=?");
                ps2.setInt(1, paymentId);
                ps2.executeUpdate();

                // Notify user of rejected payment
                new NotificationDAO().addNotification(con, data[0],
                    "Payment for '" + evTitle + "' could not be verified. Please contact the organizer.");
                return data;
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // Waitlist Viewer: Get waitlisted users for an event
    public java.util.List<java.util.Map<String, String>> getWaitlistByEvent(int eventId) {
        java.util.List<java.util.Map<String, String>> list = new java.util.ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT w.id, u.name, u.email, w.waitlisted_at " +
                         "FROM waitlist w " +
                         "JOIN users u ON w.user_id = u.id " +
                         "WHERE w.event_id = ? " +
                         "ORDER BY w.waitlisted_at ASC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            int position = 1;
            while (rs.next()) {
                java.util.Map<String, String> map = new java.util.HashMap<>();
                map.put("position", String.valueOf(position++));
                map.put("name", rs.getString("name"));
                map.put("email", rs.getString("email"));
                map.put("waitlistedAt", rs.getTimestamp("waitlisted_at").toString());
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int getRegistrationCountForTeam(int teamId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM registrations WHERE team_id=?");
            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}