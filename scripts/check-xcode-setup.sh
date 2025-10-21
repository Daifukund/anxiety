#!/bin/bash

# check-xcode-setup.sh
# Verifies if the build script has been properly added to Xcode

echo "🔍 Checking Xcode Build Script Setup..."
echo ""

PROJECT_FILE="anxietyapp.xcodeproj/project.pbxproj"

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ ERROR: Can't find Xcode project file"
    echo "   Make sure you're in the project root directory"
    exit 1
fi

# Check if script is in project file
if grep -q "validate-config.sh" "$PROJECT_FILE"; then
    echo "✅ Build script is referenced in Xcode project"

    # Check if it's properly configured (not just the default placeholder)
    if grep -q '"${SRCROOT}/scripts/validate-config.sh"' "$PROJECT_FILE"; then
        echo "✅ Build script is properly configured"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🎉 SUCCESS! Xcode build script is set up correctly!"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Next steps:"
        echo "  1. Build your app in Xcode (Cmd + B)"
        echo "  2. Check build log (Cmd + 9) for green checkmarks ✅"
        echo ""
        exit 0
    else
        echo "⚠️  Build script exists but might not be configured correctly"
        echo ""
        echo "Expected to find: \"\${SRCROOT}/scripts/validate-config.sh\""
        echo ""
        echo "Please check that you pasted the correct script content in Xcode."
        echo "See XCODE_SETUP_SIMPLE.md for detailed instructions."
        exit 1
    fi
else
    echo "❌ Build script NOT found in Xcode project"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 You need to add the build script to Xcode"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Quick steps:"
    echo "  1. Open anxietyapp.xcodeproj in Xcode"
    echo "  2. Select target → Build Phases tab"
    echo "  3. Add New Run Script Phase"
    echo "  4. Paste: \"\${SRCROOT}/scripts/validate-config.sh\""
    echo ""
    echo "📖 See XCODE_SETUP_SIMPLE.md for detailed step-by-step guide"
    echo ""
    exit 1
fi
