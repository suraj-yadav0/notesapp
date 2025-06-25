# Add Note Navigation Test

## Changes Made

### 1. Updated MainPage.qml Floating Action Button
- **Before**: Used PopupUtils.open() to show AddNoteDialog
- **After**: Emits addNoteRequested() signal

### 2. Connected signal in Main.qml
- Added `onAddNoteRequested: { navigateToAddNote() }` to MainPage connection

### 3. Removed old dialog import
- Removed `import Ubuntu.Components.Popups 1.3` from MainPage.qml since dialog is no longer used

### 4. Navigation Flow
1. User clicks floating action button in MainPage
2. MainPage emits addNoteRequested signal
3. Main.qml receives signal and calls navigateToAddNote()
4. navigateToAddNote() function:
   - Clears other pages
   - Resets AddNotePage fields
   - Adds AddNotePage to layout
   - Sets addNotePageActive = true

### 5. Save Flow
1. User fills out AddNotePage and clicks save
2. AddNotePage emits saveRequested signal with title, content, isRichText
3. Main.qml receives signal and calls notesModel.createNote()
4. Main.qml calls navigateToMainPage() to return to main view

## Testing
- Build succeeds without errors
- No dependency issues with QML imports
- Navigation signals are properly connected
- Old AddNoteDialog has been backed up and removed from use

## Radial Navigation
The radial navigation menu in Main.qml already includes:
```qml
RadialAction {
    iconName: "add"
    label: "New Note"
    onTriggered: {
        navigateToAddNote()
    }
}
```

So both the floating action button and radial menu now navigate to the AddNotePage.
