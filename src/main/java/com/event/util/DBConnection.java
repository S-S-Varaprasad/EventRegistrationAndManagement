package com.event.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {

    public static Connection getConnection() {

        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/event_system?useSSL=false&allowPublicKeyRetrieval=true",
                "event_user",
                "Event@123"
            );

            System.out.println("DB Connected Successfully");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return con;
    }
}