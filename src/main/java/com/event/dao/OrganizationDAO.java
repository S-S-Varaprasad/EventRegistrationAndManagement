package com.event.dao;

import java.sql.*;
import com.event.model.Organization;
import com.event.util.DBConnection;

public class OrganizationDAO {

    public boolean createOrganization(Organization org) {
        try (Connection con = DBConnection.getConnection()) {

            String sql = "INSERT INTO organizations(name,type,admin_user_id) VALUES(?,?,?)";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, org.getName());
            ps.setString(2, org.getType());
            ps.setInt(3, org.getAdminUserId());

            ps.executeUpdate();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public Integer getOrganizationIdByAdmin(int userId) {
        try (Connection con = DBConnection.getConnection()) {

            String sql = "SELECT id FROM organizations WHERE admin_user_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("id");

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Get organization name by ID
    public String getOrgNameById(int orgId) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT name FROM organizations WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, orgId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("name");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}