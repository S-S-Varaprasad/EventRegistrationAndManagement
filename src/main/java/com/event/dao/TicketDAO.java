package com.event.dao;

import com.event.model.Ticket;
import com.event.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class TicketDAO {

    public void generateTicket(Connection con, int eventId, Integer userId, Integer teamId) {
        try {
            String type = (teamId != null) ? "TEAM" : "INDIVIDUAL";
            
            String sql;
            PreparedStatement ps;
            if ("TEAM".equals(type)) {
                // Team ticket -> Ignore user_id
                sql = "INSERT IGNORE INTO tickets (id, event_id, team_id, ticket_type) VALUES (?, ?, ?, ?)";
                ps = con.prepareStatement(sql);
                ps.setString(1, "TKT-" + UUID.randomUUID().toString().substring(0,8).toUpperCase());
                ps.setInt(2, eventId);
                ps.setInt(3, teamId);
                ps.setString(4, type);
            } else {
                sql = "INSERT IGNORE INTO tickets (id, event_id, user_id, ticket_type) VALUES (?, ?, ?, ?)";
                ps = con.prepareStatement(sql);
                ps.setString(1, "TKT-" + UUID.randomUUID().toString().substring(0,8).toUpperCase());
                ps.setInt(2, eventId);
                ps.setInt(3, userId);
                ps.setString(4, type);
            }
            ps.executeUpdate();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    public List<Ticket> getTicketsByUser(int userId) {
        List<Ticket> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT t.*, e.title as eventTitle, e.event_date as eventDate " +
                         "FROM tickets t JOIN events e ON t.event_id = e.id " +
                         "WHERE (t.user_id = ? OR t.team_id IN (SELECT team_id FROM registrations WHERE user_id = ?)) " +
                         "AND t.status != 'CANCELLED' " +
                         "ORDER BY t.created_at DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                Ticket t = new Ticket();
                t.setId(rs.getString("id"));
                t.setEventId(rs.getInt("event_id"));
                if(rs.getObject("user_id") != null) t.setUserId(rs.getInt("user_id"));
                if(rs.getObject("team_id") != null) t.setTeamId(rs.getInt("team_id"));
                t.setTicketType(rs.getString("ticket_type"));
                t.setStatus(rs.getString("status"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                t.setEventTitle(rs.getString("eventTitle"));
                t.setEventDate(rs.getString("eventDate"));
                list.add(t);
            }
        }catch(Exception e){e.printStackTrace();}
        return list;
    }

    public List<Ticket> getTicketsByEvent(int eventId) {
        List<Ticket> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT t.*, u.name as userName, tm.name as teamName " +
                         "FROM tickets t " +
                         "LEFT JOIN users u ON t.user_id = u.id " +
                         "LEFT JOIN teams tm ON t.team_id = tm.id " +
                         "WHERE t.event_id = ? AND t.status != 'CANCELLED' ORDER BY t.created_at DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                Ticket t = new Ticket();
                t.setId(rs.getString("id"));
                t.setEventId(rs.getInt("event_id"));
                if(rs.getObject("user_id") != null) t.setUserId(rs.getInt("user_id"));
                if(rs.getObject("team_id") != null) t.setTeamId(rs.getInt("team_id"));
                t.setTicketType(rs.getString("ticket_type"));
                t.setStatus(rs.getString("status"));
                t.setUserName(rs.getString("userName"));
                t.setTeamName(rs.getString("teamName"));
                list.add(t);
            }
        }catch(Exception e){e.printStackTrace();}
        return list;
    }

    public List<Ticket> getCancelledTicketsByEvent(int eventId) {
        List<Ticket> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT t.*, u.name as userName, tm.name as teamName " +
                         "FROM tickets t " +
                         "LEFT JOIN users u ON t.user_id = u.id " +
                         "LEFT JOIN teams tm ON t.team_id = tm.id " +
                         "WHERE t.event_id = ? AND t.status = 'CANCELLED' ORDER BY t.created_at DESC";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                Ticket t = new Ticket();
                t.setId(rs.getString("id"));
                t.setEventId(rs.getInt("event_id"));
                if(rs.getObject("user_id") != null) t.setUserId(rs.getInt("user_id"));
                if(rs.getObject("team_id") != null) t.setTeamId(rs.getInt("team_id"));
                t.setTicketType(rs.getString("ticket_type"));
                t.setStatus(rs.getString("status"));
                t.setUserName(rs.getString("userName"));
                t.setTeamName(rs.getString("teamName"));
                list.add(t);
            }
        }catch(Exception e){e.printStackTrace();}
        return list;
    }

    public boolean markTicketUsed(String ticketId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement("UPDATE tickets SET status='USED' WHERE id=? AND status='ACTIVE'");
            ps.setString(1, ticketId);
            return ps.executeUpdate() > 0;
        }catch(Exception e){e.printStackTrace();}
        return false;
    }
    
    public void cancelTicket(Connection con, int eventId, Integer userId, Integer teamId) {
        try {
            if (teamId != null) {
                PreparedStatement ps = con.prepareStatement("UPDATE tickets SET status='CANCELLED' WHERE event_id=? AND team_id=?");
                ps.setInt(1, eventId);
                ps.setInt(2, teamId);
                ps.executeUpdate();
            } else {
                PreparedStatement ps = con.prepareStatement("UPDATE tickets SET status='CANCELLED' WHERE event_id=? AND user_id=?");
                ps.setInt(1, eventId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }
        } catch(Exception e) { e.printStackTrace(); }
    }
}
