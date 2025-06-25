# RichTextEditor - Hybrid Selection + Global Formatting

## New Implementation

I've improved the RichTextEditor to handle both **selected text formatting** and **global formatting for new text**. This provides the best of both worlds:

1. **Selected text**: Gets wrapped with markdown-style indicators 
2. **New text**: Appears with visual formatting applied

## How It Works Now

### For Selected Text:
- Select any text in the editor
- Click formatting buttons (B, I, U, H1)
- The selected text gets wrapped with markdown indicators:
  - **Bold**: `**selected text**`
  - **Italic**: `*selected text*`
  - **Underline**: `_selected text_`
  - **Heading**: `# selected text`

### For New Text (no selection):
- Click formatting buttons without selecting text
- The formatting state toggles on/off (buttons change color)
- Any new text you type appears with that formatting applied

## Testing Instructions

### Test 1: Selected Text Formatting

1. **Launch app and create new note**
2. **Enable Rich Text mode**
3. **Type some text**: "This is a test sentence"
4. **Select part of the text**: e.g., select "test"
5. **Click Bold (B)**: The text should become `"This is a **test** sentence"`
6. **Select "sentence" and click Italic (I)**: Should become `"This is a **test** *sentence*"`
7. **Select "**test**" and click Bold again**: Should remove formatting: `"This is a test *sentence*"`

### Test 2: Global Formatting for New Text

1. **Click Bold (B) without selecting text**: Button should change color
2. **Type new text**: Should appear in bold
3. **Click Bold (B) again**: Button returns to normal, formatting turned off
4. **Type more text**: Should appear normal (not bold)
5. **Try combinations**: Enable Bold + Italic + Underline, then type - text should have all formatting

### Test 3: Mixed Usage

1. **Type some normal text**
2. **Enable bold formatting** (click B button)
3. **Type bold text**
4. **Select some of the normal text** and make it italic
5. **Disable bold formatting** and type more normal text

### Expected Results

✅ **SUCCESS**:
- Selected text gets wrapped with markdown indicators (`**bold**`, `*italic*`, etc.)
- New text appears with visual formatting when formatting modes are active
- Formatting buttons show their state (colored when active)
- You can mix selected text formatting with global formatting

❌ **FAILURE**:
- Selected text doesn't get wrapped with markers
- No visual change when typing with formatting enabled
- Buttons don't show their active state

## Technical Details

### Hybrid Approach:
```qml
function toggleBold() {
    if (hasSelection()) {
        applySelectionFormatting("**", "**") // Markdown for selection
    } else {
        isBold = !isBold // Visual formatting for new text
    }
}
```

### Selection Detection:
```qml
function hasSelection() {
    return textEdit.selectionStart !== textEdit.selectionEnd
}
```

### Markdown Indicators:
- `**text**` for bold
- `*text*` for italic  
- `_text_` for underline
- `# text` for headings

## Benefits

1. **Flexibility**: Can format both existing and new text
2. **Visual feedback**: See formatting immediately as you type
3. **Persistence**: Selected text formatting stays in place
4. **Intuitive**: Works like modern text editors
5. **Reliable**: Uses simple string manipulation that works in all environments

## Limitations

1. **Markdown visible**: You'll see the markdown indicators in the text
2. **No rich rendering**: Text with `**bold**` shows the asterisks
3. **Simple formatting**: Limited to basic markdown-style indicators

This approach prioritizes functionality and reliability over perfect visual rendering, ensuring the formatting features work consistently in the Ubuntu Touch environment.
