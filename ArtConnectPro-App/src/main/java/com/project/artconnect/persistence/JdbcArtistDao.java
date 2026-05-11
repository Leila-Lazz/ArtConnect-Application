package com.project.artconnect.persistence;

import com.project.artconnect.dao.ArtistDao;
import com.project.artconnect.model.Artist;
import java.util.List;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import com.project.artconnect.util.ConnectionManager;

/**
 * JDBC implementation for ArtistDao.
 */
public class JdbcArtistDao implements ArtistDao {

    @Override
    public List<Artist> findAll() {
        List<Artist> artists = new ArrayList<>();
        String sql = "SELECT * FROM artists";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                artists.add(mapResultSetToArtist(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artists;
    }

    @Override
    public void save(Artist artist) {
        String sql = "INSERT INTO artists (name, bio, birth_year, contact_email, phone, city, website, social_media, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, artist.getName());
            pstmt.setString(2, artist.getBio());
            pstmt.setObject(3, artist.getBirthYear());
            pstmt.setString(4, artist.getContactEmail());
            pstmt.setString(5, artist.getPhone());
            pstmt.setString(6, artist.getCity());
            pstmt.setString(7, artist.getWebsite());
            pstmt.setString(8, artist.getSocialMedia());
            pstmt.setBoolean(9, artist.isActive());
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Artist artist) {
        String sql = "UPDATE artists SET bio = ?, birth_year = ?, contact_email = ?, phone = ?, city = ?, website = ?, social_media = ?, is_active = ? WHERE name = ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, artist.getBio());
            pstmt.setObject(2, artist.getBirthYear());
            pstmt.setString(3, artist.getContactEmail());
            pstmt.setString(4, artist.getPhone());
            pstmt.setString(5, artist.getCity());
            pstmt.setString(6, artist.getWebsite());
            pstmt.setString(7, artist.getSocialMedia());
            pstmt.setBoolean(8, artist.isActive());
            pstmt.setString(9, artist.getName());
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String artistName) {
        String sql = "DELETE FROM artists WHERE name = ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, artistName);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Artist> findByCity(String city) {
        List<Artist> artists = new ArrayList<>();
        String sql = "SELECT * FROM artists WHERE city = ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, city);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    artists.add(mapResultSetToArtist(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artists;
    }

    private Artist mapResultSetToArtist(ResultSet rs) throws SQLException {
        Artist artist = new Artist();
        artist.setName(rs.getString("name"));
        artist.setBio(rs.getString("bio"));
        artist.setBirthYear(rs.getObject("birth_year", Integer.class));
        artist.setContactEmail(rs.getString("contact_email"));
        artist.setPhone(rs.getString("phone"));
        artist.setCity(rs.getString("city"));
        artist.setWebsite(rs.getString("website"));
        artist.setSocialMedia(rs.getString("social_media"));
        artist.setActive(rs.getBoolean("is_active"));
        return artist;
    }
}
