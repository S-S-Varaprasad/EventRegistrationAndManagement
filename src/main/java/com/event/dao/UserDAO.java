package com.event.dao;

import java.sql.*;

import com.event.model.User;
import com.event.util.DBConnection;

public class UserDAO {

    // LOGIN: compare hashed password from DB with hashed input
    public User login(String email, String hashedPassword) {

        User user = null;

        try (Connection con = DBConnection.getConnection()) {

            String sql = "SELECT * FROM users WHERE email=? AND password_hash=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, hashedPassword);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("id"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPasswordHash(rs.getString("password_hash"));
                user.setRole(rs.getString("role"));
                user.setOrgCount(rs.getInt("org_count"));
                user.setUserType(rs.getString("user_type"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    // REGISTER: insert user with user_type
    public boolean registerUser(User user) {

        try (Connection con = DBConnection.getConnection()) {

            String sql = "INSERT INTO users(name, email, password_hash, user_type, role) VALUES(?,?,?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getUserType());
            ps.setString(5, "USER");

            ps.executeUpdate();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // Check if user is admin of any organization
    public Integer getOrganizationIdIfAdmin(int userId) {

        Integer orgId = null;

        try (Connection con = DBConnection.getConnection()) {

            String sql = "SELECT id FROM organizations WHERE admin_user_id=?";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                orgId = rs.getInt("id");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return orgId;
    }

    // Increment org_count when user creates an organization
    public void incrementOrgCount(int userId) {

        try (Connection con = DBConnection.getConnection()) {

            String sql = "UPDATE users SET org_count = org_count + 1 WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, userId);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}