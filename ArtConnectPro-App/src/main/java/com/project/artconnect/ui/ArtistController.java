package com.project.artconnect.ui;

import com.project.artconnect.model.Artist;
import com.project.artconnect.model.Discipline;
import com.project.artconnect.service.ArtistService;
import com.project.artconnect.util.ServiceProvider;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;

public class ArtistController {
    @FXML
    private TextField searchField;
    @FXML
    private ComboBox<Discipline> disciplineFilter;
    @FXML
    private TableView<Artist> artistTable;
    @FXML
    private TableColumn<Artist, String> nameColumn;
    @FXML
    private TableColumn<Artist, String> cityColumn;
    @FXML
    private TableColumn<Artist, String> emailColumn;
    @FXML
    private TableColumn<Artist, Integer> yearColumn;

    // CRUD Form Fields
    @FXML
    private TextField nameInput;
    @FXML
    private TextField cityInput;
    @FXML
    private TextField emailInput;
    @FXML
    private TextField yearInput;

    private final ArtistService artistService = ServiceProvider.getArtistService();

    @FXML
    public void initialize() {
        nameColumn.setCellValueFactory(new PropertyValueFactory<>("name"));
        cityColumn.setCellValueFactory(new PropertyValueFactory<>("city"));
        emailColumn.setCellValueFactory(new PropertyValueFactory<>("contactEmail"));
        yearColumn.setCellValueFactory(new PropertyValueFactory<>("birthYear"));

        disciplineFilter.setItems(FXCollections.observableArrayList(artistService.getAllDisciplines()));
        refreshTable();

        // Listen for selection changes and show the artist details in the form.
        artistTable.getSelectionModel().selectedItemProperty().addListener(
            (observable, oldValue, newValue) -> populateForm(newValue));
    }

    private void populateForm(Artist artist) {
        if (artist != null) {
            nameInput.setText(artist.getName());
            cityInput.setText(artist.getCity() != null ? artist.getCity() : "");
            emailInput.setText(artist.getContactEmail() != null ? artist.getContactEmail() : "");
            yearInput.setText(artist.getBirthYear() != null ? String.valueOf(artist.getBirthYear()) : "");
        } else {
            clearForm();
        }
    }

    private void clearForm() {
        nameInput.clear();
        cityInput.clear();
        emailInput.clear();
        yearInput.clear();
    }

    @FXML
    private void handleSearch() {
        String query = searchField.getText();
        Discipline d = disciplineFilter.getValue();
        String dName = (d != null) ? d.getName() : null;
        artistTable.setItems(FXCollections.observableArrayList(artistService.searchArtists(query, dName, null)));
    }

    @FXML
    private void handleReset() {
        searchField.clear();
        disciplineFilter.setValue(null);
        refreshTable();
        clearForm();
    }

    @FXML
    private void handleAdd() {
        if (nameInput.getText().isEmpty()) return;
        
        Integer year = yearInput.getText().isEmpty() ? null : Integer.parseInt(yearInput.getText());
        Artist newArtist = new Artist(nameInput.getText(), "", year, emailInput.getText(), cityInput.getText());
        
        artistService.createArtist(newArtist);
        refreshTable();
        clearForm();
    }

    @FXML
    private void handleUpdate() {
        Artist selected = artistTable.getSelectionModel().getSelectedItem();
        if (selected == null) return;

        selected.setCity(cityInput.getText());
        selected.setContactEmail(emailInput.getText());
        selected.setBirthYear(yearInput.getText().isEmpty() ? null : Integer.parseInt(yearInput.getText()));
        
        // Note: Primary key (name) usually shouldn't be changed, but we update other fields.
        artistService.updateArtist(selected);
        refreshTable();
    }

    @FXML
    private void handleDelete() {
        Artist selected = artistTable.getSelectionModel().getSelectedItem();
        if (selected == null) return;

        artistService.deleteArtist(selected.getName());
        refreshTable();
        clearForm();
    }

    private void refreshTable() {
        artistTable.setItems(FXCollections.observableArrayList(artistService.getAllArtists()));
    }
}
