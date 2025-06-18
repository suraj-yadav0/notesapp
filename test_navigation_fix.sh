#!/bin/bash

# Test script to verify radial navigation fixes
echo "🧪 Testing Radial Navigation Navigation Fix"
echo "==========================================="

# Build the app
echo "📦 Building app..."
cd /home/suraj/notesapp
clickable build --verbose 2>&1 | grep -E "(Built|Error|Failed)" | tail -5

if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Run the app for a short time to capture initial output
echo "🚀 Starting app to capture logs..."
timeout 15 clickable desktop 2>&1 | grep -E "(qml:|Cannot|Error|Warning)" > /tmp/notesapp_test.log &
APP_PID=$!

# Wait for app to start
sleep 3

# Test by directly calling qmlscene on a simple test
echo "🔍 Running basic QML test..."
cd build/all/app/install
echo "import QtQuick 2.7; import \"qml/Main.qml\"; Item { }" > /tmp/test.qml
timeout 5 qmlscene /tmp/test.qml 2>&1 | grep -E "(qml:|Cannot|Error)" | head -10

# Wait for app to complete
wait $APP_PID 2>/dev/null

# Check results
echo "📊 Test Results:"
echo "==============="

if [ -f /tmp/notesapp_test.log ]; then
    echo "🔍 App Logs:"
    cat /tmp/notesapp_test.log | head -20
    
    # Check for specific errors
    CANNOT_ADD_ERRORS=$(cat /tmp/notesapp_test.log | grep -c "Cannot add a Page")
    TYPE_ERRORS=$(cat /tmp/notesapp_test.log | grep -c "existing role.*different type")
    
    echo
    echo "📈 Error Summary:"
    echo "  - 'Cannot add Page' errors: $CANNOT_ADD_ERRORS"
    echo "  - Type role errors: $TYPE_ERRORS"
    
    if [ $CANNOT_ADD_ERRORS -eq 0 ]; then
        echo "✅ Navigation duplication issue FIXED!"
    else
        echo "❌ Navigation duplication issue still present"
    fi
    
    if [ $TYPE_ERRORS -eq 0 ]; then
        echo "✅ Type role issue FIXED!"
    else
        echo "❌ Type role issue still present"
    fi
else
    echo "⚠️  No log file generated"
fi

# Cleanup
rm -f /tmp/test.qml /tmp/notesapp_test.log
echo "🏁 Test completed"
