package com.project.artconnect.util;

import com.project.artconnect.service.*;
import com.project.artconnect.service.impl.*;

/**
 * Service Provider to manage singleton instances of services and handle their
 * initialization.
 */
public class ServiceProvider {
    private static final ArtistService artistService = new JdbcArtistService(new com.project.artconnect.persistence.JdbcArtistDao());
    private static final ArtworkService artworkService = new JdbcArtworkService(new com.project.artconnect.persistence.JdbcArtworkDao());
    private static final GalleryService galleryService = new com.project.artconnect.service.impl.InMemoryGalleryService();
    private static final WorkshopService workshopService = new com.project.artconnect.service.impl.InMemoryWorkshopService();
    private static final CommunityService communityService = new com.project.artconnect.service.impl.InMemoryCommunityService();

    static {
        // Initialization not strictly needed for DB since it pulls data directly,
        // but kept to satisfy structure if necessary.
        ((com.project.artconnect.service.impl.InMemoryGalleryService) galleryService).initData(artworkService);
        ((com.project.artconnect.service.impl.InMemoryWorkshopService) workshopService).initData(artistService);
        ((com.project.artconnect.service.impl.InMemoryCommunityService) communityService).initData(artworkService);
    }

    public static ArtistService getArtistService() {
        return artistService;
    }

    public static ArtworkService getArtworkService() {
        return artworkService;
    }

    public static GalleryService getGalleryService() {
        return galleryService;
    }

    public static WorkshopService getWorkshopService() {
        return workshopService;
    }

    public static CommunityService getCommunityService() {
        return communityService;
    }
}
