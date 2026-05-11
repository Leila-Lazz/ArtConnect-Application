package com.project.artconnect.persistence;

import com.project.artconnect.dao.ArtworkDao;
import com.project.artconnect.model.Artwork;
import java.util.List;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import com.project.artconnect.util.ConnectionManager;
import com.project.artconnect.model.Artist;

/**
 * JDBC implementation for ArtworkDao.
 */
public class JdbcArtworkDao implements ArtworkDao {

    @Override
    public List<Artwork> findAll() {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT aw.*, a.name AS artist_name FROM artworks aw JOIN artists a ON aw.artist_id = a.artist_id";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                artworks.add(mapResultSetToArtwork(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artworks;
    }

    @Override
    public void save(Artwork artwork) {
        String sql = "INSERT INTO artworks (title, creation_year, type, medium, dimensions, description, price, status, artist_id) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, (SELECT artist_id FROM artists WHERE name = ? LIMIT 1))";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, artwork.getTitle());
            pstmt.setObject(2, artwork.getCreationYear());
            pstmt.setString(3, artwork.getType());
            pstmt.setString(4, artwork.getMedium());
            pstmt.setString(5, artwork.getDimensions());
            pstmt.setString(6, artwork.getDescription());
            pstmt.setDouble(7, artwork.getPrice());
            pstmt.setString(8, artwork.getStatus() != null ? artwork.getStatus().name() : "FOR_SALE");
            pstmt.setString(9, artwork.getArtist() != null ? artwork.getArtist().getName() : "");
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void update(Artwork artwork) {
        String sql = "UPDATE artworks SET creation_year = ?, type = ?, medium = ?, dimensions = ?, description = ?, price = ?, status = ?, " +
                     "artist_id = (SELECT artist_id FROM artists WHERE name = ? LIMIT 1) WHERE title = ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setObject(1, artwork.getCreationYear());
            pstmt.setString(2, artwork.getType());
            pstmt.setString(3, artwork.getMedium());
            pstmt.setString(4, artwork.getDimensions());
            pstmt.setString(5, artwork.getDescription());
            pstmt.setDouble(6, artwork.getPrice());
            pstmt.setString(7, artwork.getStatus() != null ? artwork.getStatus().name() : "FOR_SALE");
            pstmt.setString(8, artwork.getArtist() != null ? artwork.getArtist().getName() : "");
            pstmt.setString(9, artwork.getTitle());
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void delete(String title) {
        String sql = "DELETE FROM artworks WHERE title = ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, title);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<Artwork> findByArtistName(String artistName) {
        List<Artwork> artworks = new ArrayList<>();
        String sql = "SELECT aw.*, a.name AS artist_name FROM artworks aw JOIN artists a ON aw.artist_id = a.artist_id WHERE a.name = ?";
        try (Connection conn = ConnectionManager.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, artistName);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    artworks.add(mapResultSetToArtwork(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return artworks;
    }

    private Artwork mapResultSetToArtwork(ResultSet rs) throws SQLException {
        Artwork artwork = new Artwork();
        artwork.setTitle(rs.getString("title"));
        artwork.setCreationYear(rs.getObject("creation_year", Integer.class));
        artwork.setType(rs.getString("type"));
        artwork.setMedium(rs.getString("medium"));
        artwork.setDimensions(rs.getString("dimensions"));
        artwork.setDescription(rs.getString("description"));
        artwork.setPrice(rs.getDouble("price"));
        
        String statusStr = rs.getString("status");
        if (statusStr != null) {
            try {
                artwork.setStatus(Artwork.Status.valueOf(statusStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
                artwork.setStatus(Artwork.Status.FOR_SALE);
            }
        }

        Artist artist = new Artist();
        artist.setName(rs.getString("artist_name"));
        artwork.setArtist(artist);
        
        return artwork;
    }
}
