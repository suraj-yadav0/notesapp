/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * Simple test for SQLite functionality
 */

import QtQuick 2.7
import QtQuick.LocalStorage 2.0

Item {
    Component.onCompleted: {
        console.log("Testing SQLite connection...");
        
        try {
            var db = LocalStorage.openDatabaseSync("TestDB", "1.0", "Test Database", 1000000);
            
            db.transaction(function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT)');
                tx.executeSql('INSERT INTO test (name) VALUES (?)', ['Test Entry']);
                
                var result = tx.executeSql('SELECT * FROM test');
                console.log("Test table has", result.rows.length, "rows");
                
                if (result.rows.length > 0) {
                    console.log("First row:", result.rows.item(0).name);
                }
            });
            
            console.log("SQLite test completed successfully!");
        } catch (e) {
            console.error("SQLite test failed:", e);
        }
    }
}
