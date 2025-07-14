/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * notesapp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.LocalStorage 2.0

// SQLite Database Manager for Notes App
QtObject {
    id: databaseManager

    // Database configuration
    property string databaseName: "NotesAppDB"
    property string databaseVersion: "1.0"
    property string databaseDescription: "Notes Application Database"
    property int databaseSize: 1000000 // 1MB

    // Database connection
    property var database: null

    // Initialize database
    function initializeDatabase() {
        try {
            database = LocalStorage.openDatabaseSync(databaseName, databaseVersion, databaseDescription, databaseSize);

            // Create tables if they don't exist
            createTables();
            console.log("Database initialized successfully");
            return true;
        } catch (error) {
            console.error("Failed to initialize database:", error);
            return false;
        }
    }

    // Create necessary tables
    function createTables() {
        database.transaction(function (tx) {
            // Create notes table
            tx.executeSql('CREATE TABLE IF NOT EXISTS notes (' + 'id INTEGER PRIMARY KEY AUTOINCREMENT, ' + 'title TEXT NOT NULL, ' + 'content TEXT, ' + 'isRichText BOOLEAN DEFAULT 0, ' + 'createdAt TEXT NOT NULL, ' + 'updatedAt TEXT NOT NULL' + ')');

            // Create settings table for app preferences
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings (' + 'key TEXT PRIMARY KEY, ' + 'value TEXT' + ')');

            console.log("Database tables created successfully");
        });
    }

    // === NOTES CRUD OPERATIONS ===

    // Insert a new note
    function insertNote(title, content, isRichText) {
        if (!database) {
            console.error("Database not available");
            return -1;
        }

        var noteId = -1;
        var currentDateTime = new Date().toISOString();

        database.transaction(function (tx) {
            var result = tx.executeSql('INSERT INTO notes (title, content, isRichText, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?)', [title, content, isRichText || false, currentDateTime, currentDateTime]);
            noteId = result.insertId;
        });

        console.log("Note inserted with ID:", noteId);
        return noteId;
    }

    // Get all notes
    function getAllNotes() {
        if (!database) {
            console.error("Database not available");
            return [];
        }

        var notes = [];

        database.readTransaction(function (tx) {
            var result = tx.executeSql('SELECT * FROM notes ORDER BY updatedAt DESC');

            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i);
                notes.push({
                    id: row.id,
                    title: row.title,
                    content: row.content,
                    isRichText: row.isRichText === 1,
                    createdAt: row.createdAt,
                    updatedAt: row.updatedAt
                });
            }
        });

        return notes;
    }

    // Get a specific note by ID
    function getNoteById(noteId) {
        if (!database) {
            console.error("Database not available");
            return null;
        }

        var note = null;

        database.readTransaction(function (tx) {
            var result = tx.executeSql('SELECT * FROM notes WHERE id = ?', [noteId]);

            if (result.rows.length > 0) {
                var row = result.rows.item(0);
                note = {
                    id: row.id,
                    title: row.title,
                    content: row.content,
                    isRichText: row.isRichText === 1,
                    createdAt: row.createdAt,
                    updatedAt: row.updatedAt
                };
            }
        });

        return note;
    }

    // Update an existing note
    function updateNote(noteId, title, content, isRichText) {
        if (!database) {
            console.error("Database not available");
            return false;
        }

        var success = false;
        var currentDateTime = new Date().toISOString();

        database.transaction(function (tx) {
            var result = tx.executeSql('UPDATE notes SET title = ?, content = ?, isRichText = ?, updatedAt = ? WHERE id = ?', [title, content, isRichText || false, currentDateTime, noteId]);
            success = result.rowsAffected > 0;
        });

        console.log("Note updated:", success);
        return success;
    }

    // Delete a note
    function deleteNote(noteId) {
        if (!database) {
            console.error("Database not available");
            return false;
        }

        var success = false;

        database.transaction(function (tx) {
            var result = tx.executeSql('DELETE FROM notes WHERE id = ?', [noteId]);
            success = result.rowsAffected > 0;
        });

        console.log("Note deleted:", success);
        return success;
    }

    // Search notes by title or content
    function searchNotes(searchTerm) {
        if (!database) {
            console.error("Database not available");
            return [];
        }

        var notes = [];

        database.readTransaction(function (tx) {
            var result = tx.executeSql('SELECT * FROM notes WHERE title LIKE ? OR content LIKE ? ORDER BY updatedAt DESC', ['%' + searchTerm + '%', '%' + searchTerm + '%']);

            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i);
                notes.push({
                    id: row.id,
                    title: row.title,
                    content: row.content,
                    isRichText: row.isRichText === 1,
                    createdAt: row.createdAt,
                    updatedAt: row.updatedAt
                });
            }
        });

        return notes;
    }

    // === SETTINGS OPERATIONS ===

    // Save a setting
    function saveSetting(key, value) {
        if (!database) {
            console.error("Database not available");
            return;
        }

        database.transaction(function (tx) {
            tx.executeSql('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)', [key, value]);
        });
    }

    // Get a setting
    function getSetting(key, defaultValue) {
        if (!database) {
            console.error("Database not available");
            return defaultValue || null;
        }

        var value = defaultValue || null;

        database.readTransaction(function (tx) {
            var result = tx.executeSql('SELECT value FROM settings WHERE key = ?', [key]);

            if (result.rows.length > 0) {
                value = result.rows.item(0).value;
            }
        });

        return value;
    }

    // === UTILITY FUNCTIONS ===

    // Get database statistics
    function getDatabaseStats() {
        if (!database) {
            console.error("Database not available");
            return {
                notesCount: 0
            };
        }

        var stats = {
            notesCount: 0
        };

        database.readTransaction(function (tx) {
            var result = tx.executeSql('SELECT COUNT(*) as count FROM notes');
            if (result.rows.length > 0) {
                stats.notesCount = result.rows.item(0).count;
            }
        });

        return stats;
    }

    // Clear all notes (use with caution)
    function clearAllNotes() {
        if (!database) {
            console.error("Database not available");
            return false;
        }

        var success = false;

        database.transaction(function (tx) {
            var result = tx.executeSql('DELETE FROM notes');
            success = true;
        });

        console.log("All notes cleared:", success);
        return success;
    }

    // Export notes data (returns JSON string)
    function exportNotes() {
        var notes = getAllNotes();
        return JSON.stringify(notes, null, 2);
    }

    // Component initialization
    Component.onCompleted: {
        initializeDatabase();
    }
}
