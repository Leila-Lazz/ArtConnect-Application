package com.project.artconnect.util;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * Utility class to manage JDBC connections.
 * TODO: Students must implementation the getConnection logic.
 */
public class ConnectionManager {

    /**
     * Provides a connection to the MySQL database.
     * 
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Ensure the JDBC driver is loaded (optional for modern JDBC, but good practice)
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found.");
            e.printStackTrace();
        }
        return java.sql.DriverManager.getConnection(
            com.project.artconnect.config.DatabaseConfig.URL, 
            com.project.artconnect.config.DatabaseConfig.USER,
            com.project.artconnect.config.DatabaseConfig.PASSWORD
        );
    }
}
