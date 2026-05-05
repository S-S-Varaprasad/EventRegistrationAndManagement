package com.event.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.event.model.Notification;
import com.event.util.DBConnection;

public class NotificationDAO {

    // Insert notification using an existing connection (for transactional contexts)
    public void addNotification(Connection con, int userId, String message) {
        try {
            insertNotification(con, userId, message);
        } catch (Exception e) { e.printStackTrace(); }
    }

    // Insert notification with its own connection (for non-transactional contexts)
    public void addNotification(int userId, String message) {
        try (Connection con = DBConnection.getConnection()) {
            insertNotification(con, userId, message);
        } catch (Exception e) { e.printStackTrace(); }
    }

    private void insertNotification(Connection con, int userId, String message) throws Exception {
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO user_notifications(user_id, message) VALUES(?,?)");
        ps.setInt(1, userId);
        ps.setString(2, message);
        ps.executeUpdate();
    }

    // Get unread count for badge display
    public int getUnreadCount(int userId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT COUNT(*) FROM user_notifications WHERE user_id=? AND is_read=FALSE");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    // Get all notifications (last 50, newest first)
    public List<Notification> getAllNotifications(int userId) {
        List<Notification> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM user_notifications WHERE user_id=? ORDER BY created_at DESC LIMIT 50");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Notification n = new Notification();
                n.setId(rs.getInt("id"));
                n.setUserId(rs.getInt("user_id"));
                n.setMessage(rs.getString("message"));
                n.setRead(rs.getBoolean("is_read"));
                n.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(n);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Mark all notifications as read for a user
    public void markAllRead(int userId) {
        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE user_notifications SET is_read=TRUE WHERE user_id=? AND is_read=FALSE");
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
}
