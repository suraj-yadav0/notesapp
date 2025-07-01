# SQLite Integration Documentation

## Overview

The Notes App has been successfully upgraded to use SQLite for local storage instead of Qt Settings. This provides better performance, data integrity, and more advanced querying capabilities.

## Architecture

### Database Manager (`DatabaseManager.qml`)
- Standalone component that handles all SQLite operations
- Provides CRUD operations for notes
- Includes settings storage functionality
- Handles database initialization and table creation

### Notes Model (`NotesModel.qml`)
- Hybrid approach supporting both SQLite and fallback to Settings
- Automatically detects SQLite availability and falls back gracefully
- Maintains backward compatibility with existing API
- Provides enhanced functionality with database IDs

## Database Schema

### Notes Table
```sql
CREATE TABLE notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT,
    isRichText BOOLEAN DEFAULT 0,
    createdAt TEXT NOT NULL,
    updatedAt TEXT NOT NULL
)
```

### Settings Table
```sql
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT
)
```

## Key Features

### 1. **Automatic Fallback**
- If SQLite fails to initialize, the app automatically falls back to Qt Settings
- Seamless user experience regardless of storage method

### 2. **Enhanced Data Management**
- Proper database IDs for notes
- Created and updated timestamps
- Rich text support flag
- Better data integrity

### 3. **Search Functionality**
- Built-in search across title and content
- Efficient database queries
- Real-time filtering

### 4. **Performance Improvements**
- Faster data access with SQLite
- Efficient storage for large datasets
- Indexed queries for better performance

## API Changes

### New Properties
```qml
// Database connection status
property bool useDatabase: true

// Enhanced current note with database ID
property var currentNote: {
    id: -1,           // Database ID
    title: "",
    content: "",
    createdAt: "",
    updatedAt: "",    // New timestamp field
    index: -1         // ListModel index
}

// New signal for data changes
signal dataChanged()
```

### New Functions

#### Database-specific Operations
```qml
// Create a new note (returns database ID or false)
function createNote(title, content, isRichText = false)

// Update current note
function updateCurrentNote(title, content, isRichText = null)

// Delete current note
function deleteCurrentNote()

// Search notes
function searchNotes(searchTerm)
```

#### Utility Functions
```qml
// Get database statistics
function getDatabaseStats()

// Export notes as JSON
function exportNotes()

// Clear all notes (with caution)
function clearAllNotes()
```

## Usage Examples

### Creating a Note
```qml
// Create a new note
var noteId = notesModel.createNote("My Title", "My Content", false);
if (noteId) {
    console.log("Note created with ID:", noteId);
}
```

### Updating a Note
```qml
// Set current note and update
notesModel.setCurrentNote(index);
notesModel.updateCurrentNote("Updated Title", "Updated Content");
```

### Searching Notes
```qml
// Search for notes containing "meeting"
notesModel.searchNotes("meeting");

// Clear search (show all notes)
notesModel.searchNotes("");
```

## Migration Strategy

The implementation includes automatic migration:

1. **First Run**: Creates SQLite database and tables
2. **Data Migration**: Existing Settings data is preserved as fallback
3. **Graceful Degradation**: Falls back to Settings if SQLite fails

## Error Handling

- Database initialization errors are caught and logged
- Automatic fallback to Settings storage
- Transaction rollback on database errors
- Comprehensive error logging

## Performance Benefits

1. **Faster Queries**: SQLite indexes provide O(log n) search
2. **Efficient Storage**: Better space utilization than Settings
3. **Concurrent Access**: SQLite handles multiple operations safely
4. **Scalability**: Can handle thousands of notes efficiently

## Testing

The implementation has been tested with:
- ✅ Fresh installation
- ✅ Database creation and table initialization
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Search functionality
- ✅ Fallback to Settings storage
- ✅ App launch and basic functionality

## Future Enhancements

Potential improvements with SQLite:
1. **Full-text Search**: Using SQLite FTS for better search
2. **Tags and Categories**: Additional tables for organization
3. **Attachments**: Binary data storage for images/files
4. **Sync Capabilities**: Export/import for cloud synchronization
5. **Data Analytics**: Query-based insights and statistics

## Troubleshooting

### Common Issues

1. **Database Permission Errors**
   - Check app permissions in manifest
   - Verify storage access rights

2. **Fallback to Settings**
   - Normal behavior when SQLite unavailable
   - Check console logs for initialization errors

3. **Data Not Persisting**
   - Ensure database transactions complete
   - Check for JavaScript errors in console

### Debug Information

Enable debugging by checking console output:
```javascript
console.log("Database initialized:", useDatabase);
console.log("Notes count:", getDatabaseStats().notesCount);
```

## Conclusion

The SQLite integration provides a robust, scalable foundation for the Notes App with significant performance and feature improvements while maintaining full backward compatibility.
