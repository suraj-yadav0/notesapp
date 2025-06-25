# RichTextEditor Testing Guide

## What Should Work Now

### ✅ **Fixed Issues**
1. **Simplified Architecture**: Replaced complex TextEdit with standard TextArea from Lomiri Components
2. **Better HTML Handling**: Uses string manipulation instead of unreliable TextEdit methods
3. **Improved UI**: Better toolbar layout with ScrollView for horizontal scrolling
4. **Keyboard Shortcuts**: Added Ctrl+B, Ctrl+I, Ctrl+U for formatting
5. **Focus Management**: Proper focus handling after operations

### ✅ **Available Formatting Options**
- **Bold (B)**: Wraps selected text or inserts `<b></b>` tags
- **Italic (I)**: Wraps selected text or inserts `<i></i>` tags
- **Underline (U)**: Wraps selected text or inserts `<u></u>` tags
- **Heading (H1)**: Wraps selected text or inserts `<h2></h2>` tags
- **Bullet List**: Creates an HTML unordered list
- **Clear Formatting**: Removes all HTML tags from text

## How to Test the RichTextEditor

### 1. **Access Rich Text Mode**
- Open the app
- Click the floating action button OR use radial navigation to "New Note"
- Toggle the "Rich Text Format" switch to ON
- You should see the formatting toolbar appear

### 2. **Test Basic Formatting**
- Type some text
- Select a portion of text
- Click the **B** button - text should be wrapped with bold tags
- Click the **I** button - text should be wrapped with italic tags
- Try other formatting buttons

### 3. **Test Without Selection**
- Place cursor in empty area
- Click any formatting button
- Empty tags should be inserted at cursor position
- Type between the tags to see formatting applied

### 4. **Test List Creation**
- Click the "List" button
- Should insert a template HTML list with 3 items
- Edit the list items as needed

### 5. **Test Clear Formatting**
- Select formatted text
- Click "Clear" button
- All HTML tags should be removed

### 6. **Test Keyboard Shortcuts**
- Select text and press Ctrl+B for bold
- Select text and press Ctrl+I for italic
- Select text and press Ctrl+U for underline

### 7. **Test in Edit Mode**
- Create a note with rich text formatting
- Save and close
- Reopen the note for editing
- Rich text should load properly in edit mode

## Expected Behavior

### ✅ **When Working Correctly**
- Toolbar buttons respond to clicks
- Console shows button click messages
- HTML tags are inserted into text
- Text appears formatted in the TextArea
- Cursor position is maintained after formatting
- Selection is preserved when wrapping text

### ❌ **If Still Not Working**
- Buttons don't respond to clicks
- No HTML tags appear in text
- Console doesn't show button messages
- Text doesn't appear formatted

## Technical Implementation

### **New Approach**
- Uses `TextArea` instead of `TextEdit` for better Lomiri integration
- Uses string manipulation with `substring()` for reliable text handling
- Simplified formatting functions that work with cursor positions
- Better integration with Lomiri Components theme system

### **Key Functions**
- `insertHtmlTags(tag)`: Core function for wrapping text with HTML tags
- `applyBold()`, `applyItalic()`, `applyUnderline()`: Specific formatting functions
- `insertBulletList()`: Creates HTML unordered lists
- `clearAllFormatting()`: Removes all HTML formatting

## Troubleshooting

### **If Buttons Don't Work**
1. Check console for JavaScript errors
2. Verify that `textEdit.text` property is accessible
3. Test with simple text insertion first

### **If Formatting Doesn't Display**
1. Verify `textFormat: TextEdit.RichText` is set
2. Check that HTML tags are actually being inserted
3. Test with simple HTML like `<b>test</b>`

### **If Integration Issues Persist**
1. Check that `initialText` property is being set correctly
2. Verify `onLoaded` handlers in AddNotePage/NoteEditPage
3. Test with plain text mode first to isolate issues

## Testing Commands

```bash
# Build the app
cd /home/suraj/notesapp
clickable build

# Install and test on device (if available)
clickable install
clickable launch

# Check for QML errors
clickable logs
```

The RichTextEditor should now provide a functional rich text editing experience with proper HTML formatting capabilities.
