package com.event.dao;

import com.event.model.Team;
import com.event.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class TeamDAO {
    
    public Integer createTeam(Team team) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "INSERT INTO teams (name, event_id, leader_user_id) VALUES (?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, team.getName());
            ps.setInt(2, team.getEventId());
            ps.setInt(3, team.getLeaderUserId());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) return null;
            
            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1; // -1 on unique constraint fail / collision
    }
    public java.util.List<Team> getTeamsByEventId(int eventId) {
        java.util.List<Team> list = new java.util.ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM teams WHERE event_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Team t = new Team();
                t.setId(rs.getInt("id"));
                t.setName(rs.getString("name"));
                t.setEventId(rs.getInt("event_id"));
                t.setLeaderUserId(rs.getInt("leader_user_id"));
                // Add member count safety checking for UI dropdowns
                String cSql = "SELECT COUNT(*) FROM registrations WHERE team_id=?";
                PreparedStatement cps = con.prepareStatement(cSql);
                cps.setInt(1, t.getId());
                ResultSet crs = cps.executeQuery();
                if (crs.next()) {
                    // Temporarily storing member count locally? We don't have a field in Team class.
                    // We'll just append it to the name in UI via a different method, or we just return all.
                }
                list.add(t);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
    public void saveTeamRoster(int teamId, String rosterJson) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "INSERT INTO team_member_data (team_id, member_index, member_data, leader_included) VALUES (?, ?, ?, 1)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, teamId);
            ps.setInt(2, 0);
            ps.setString(3, rosterJson);
            ps.executeUpdate();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public Integer getTeamIdByLeaderAndEvent(int userId, int eventId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT id FROM teams WHERE leader_user_id=? AND event_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");
        } catch (Exception ex) { ex.printStackTrace(); }
        return null;
    }

    public String getRosterByTeamId(int teamId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT member_data FROM team_member_data WHERE team_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("member_data");
        } catch (Exception ex) { ex.printStackTrace(); }
        return "[]";
    }

    public boolean isLeaderIncluded(int teamId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT leader_included FROM team_member_data WHERE team_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("leader_included") == 1;
        } catch (Exception ex) { ex.printStackTrace(); }
        return false;
    }

    public void updateTeamRoster(int teamId, String rosterJson) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "UPDATE team_member_data SET member_data=?, leader_included=1 WHERE team_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, rosterJson);
            ps.setInt(2, teamId);
            ps.executeUpdate();
        } catch (Exception ex) { ex.printStackTrace(); }
    }
    public Integer getLeaderIdByTeamId(int teamId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT leader_user_id FROM teams WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception ex) { ex.printStackTrace(); }
        return null;
    }

    public Integer getEventIdByTeamId(int teamId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT event_id FROM teams WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("event_id");
        } catch (Exception ex) { ex.printStackTrace(); }
        return null;
    }
    public int getMemberCount(int teamId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT JSON_LENGTH(member_data) FROM team_member_data WHERE team_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception ex) { ex.printStackTrace(); }
        return 0;
    }

    public String getTeamNameById(int teamId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT name FROM teams WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, teamId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("name");
        } catch (Exception ex) { ex.printStackTrace(); }
        return "Unknown Team";
    }
}
