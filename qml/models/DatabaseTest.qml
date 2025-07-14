/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * SQLite Database Integration Test
 */

import QtQuick 2.7
import "../models"

Item {
    id: dbTest

    property bool testResults: false

    Component.onCompleted: {
        console.log("=== SQLite Database Test Started ===");
        runDatabaseTests();
    }

    function runDatabaseTests() {
        var testsPassed = 0;
        var totalTests = 5;

        // Test 1: Database Manager initialization
        var dbManager = databaseManagerComponent.createObject(null);
        if (dbManager && dbManager.database !== null) {
            console.log("✓ Test 1 PASSED: DatabaseManager initialized successfully");
            testsPassed++;
        } else {
            console.log("✗ Test 1 FAILED: DatabaseManager initialization failed");
        }

        if (!dbManager) {
            console.log("✗ All tests failed - DatabaseManager could not be created");
            return;
        }

        // Test 2: Insert Note
        var noteId = dbManager.insertNote("Test Note", "This is a test note content", false);
        if (noteId > 0) {
            console.log("✓ Test 2 PASSED: Note inserted with ID:", noteId);
            testsPassed++;
        } else {
            console.log("✗ Test 2 FAILED: Note insertion failed");
        }

        // Test 3: Get All Notes
        var allNotes = dbManager.getAllNotes();
        if (allNotes && allNotes.length > 0) {
            console.log("✓ Test 3 PASSED: Retrieved", allNotes.length, "notes");
            testsPassed++;
        } else {
            console.log("✗ Test 3 FAILED: Could not retrieve notes");
        }

        // Test 4: Update Note (if we have a note to update)
        if (noteId > 0) {
            var updateSuccess = dbManager.updateNote(noteId, "Updated Test Note", "Updated content", false);
            if (updateSuccess) {
                console.log("✓ Test 4 PASSED: Note updated successfully");
                testsPassed++;
            } else {
                console.log("✗ Test 4 FAILED: Note update failed");
            }
        } else {
            console.log("✗ Test 4 SKIPPED: No note ID for update test");
        }

        // Test 5: Database Stats
        var stats = dbManager.getDatabaseStats();
        if (stats && stats.notesCount !== undefined) {
            console.log("✓ Test 5 PASSED: Database stats retrieved, notes count:", stats.notesCount);
            testsPassed++;
        } else {
            console.log("✗ Test 5 FAILED: Could not get database stats");
        }

        // Test 6: Delete Note (cleanup)
        if (noteId > 0) {
            var deleteSuccess = dbManager.deleteNote(noteId);
            if (deleteSuccess) {
                console.log("✓ Cleanup PASSED: Test note deleted successfully");
            } else {
                console.log("✗ Cleanup FAILED: Could not delete test note");
            }
        }

        console.log("=== SQLite Database Test Results ===");
        console.log("Tests passed:", testsPassed, "out of", totalTests);
        console.log("Success rate:", Math.round((testsPassed / totalTests) * 100) + "%");

        testResults = (testsPassed === totalTests);

        if (testResults) {
            console.log("🎉 ALL TESTS PASSED! SQLite database is working correctly.");
        } else {
            console.log("❌ Some tests failed. Check the implementation.");
        }

        dbManager.destroy();
    }

    Component {
        id: databaseManagerComponent
        DatabaseManager {}
    }
}
