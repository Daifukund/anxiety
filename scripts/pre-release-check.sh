#!/bin/bash
#
# Pre-Release Verification Script for Nuvin v1.2.0
# Validates all critical checks before App Store submission
#

set -e

echo "🔍 Starting Pre-Release Verification for v1.2.0..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to print success
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

# Function to print error
error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

echo "📋 Checking Critical Configuration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check 1: Config.plist not tracked in git
echo -n "Checking Config.plist git status... "
if git check-ignore -q anxietyapp/Config.plist; then
    success "Config.plist is properly ignored"
else
    error "Config.plist is NOT in .gitignore or is tracked"
fi

# Check 2: Config.plist exists
echo -n "Checking Config.plist exists... "
if [ -f "anxietyapp/Config.plist" ]; then
    success "Config.plist found"

    # Check 3: Config.plist has real API keys (not placeholders)
    echo -n "Validating API keys are not placeholders... "
    if grep -q "YOUR_" anxietyapp/Config.plist; then
        error "Config.plist contains placeholder keys"
    else
        success "API keys appear to be configured"
    fi
else
    error "Config.plist NOT FOUND - required for build"
fi

# Check 4: Version numbers match
echo -n "Checking version consistency... "
MAIN_VERSION=$(grep -A1 "MARKETING_VERSION" anxietyapp.xcodeproj/project.pbxproj | grep "1.2.0" | head -1)
WIDGET_VERSION=$(grep -A1 "533527AD2EA7870E002E095A" anxietyapp.xcodeproj/project.pbxproj | grep "MARKETING_VERSION = 1.2.0")

if [ -n "$MAIN_VERSION" ] && [ -n "$WIDGET_VERSION" ]; then
    success "All targets set to v1.2.0"
else
    error "Version mismatch detected between targets"
fi

# Check 5: Build numbers incremented
echo -n "Checking build numbers... "
BUILD_COUNT=$(grep "CURRENT_PROJECT_VERSION = 2" anxietyapp.xcodeproj/project.pbxproj | wc -l | tr -d ' ')
if [ "$BUILD_COUNT" -ge "4" ]; then
    success "Build numbers incremented to 2"
else
    error "Build numbers not properly incremented (found $BUILD_COUNT/4)"
fi

# Check 6: LaunchScreen.storyboard exists
echo -n "Checking LaunchScreen.storyboard... "
if [ -f "anxietyapp/LaunchScreen.storyboard" ]; then
    success "Launch screen found"
else
    error "LaunchScreen.storyboard missing"
fi

# Check 7: App Icons present
echo -n "Checking app icons... "
ICON_COUNT=$(ls anxietyapp/Assets.xcassets/AppIcon.appiconset/*.png 2>/dev/null | wc -l | tr -d ' ')
if [ "$ICON_COUNT" -ge "10" ]; then
    success "App icons present ($ICON_COUNT files)"
else
    warning "App icons may be incomplete ($ICON_COUNT files found)"
fi

# Check 8: Entitlements configured
echo -n "Checking entitlements... "
if [ -f "anxietyapp/anxietyapp.entitlements" ] && [ -f "SOSWidgetExtension.entitlements" ]; then
    success "Entitlements configured"
else
    error "Entitlements missing"
fi

# Check 9: Info.plist exists
echo -n "Checking Info.plist... "
if [ -f "anxietyapp/Info.plist" ]; then
    success "Info.plist found"
else
    error "Info.plist missing"
fi

# Check 10: PrivacyInfo.xcprivacy exists
echo -n "Checking privacy manifest... "
if [ -f "anxietyapp/PrivacyInfo.xcprivacy" ]; then
    success "Privacy manifest found"
else
    error "PrivacyInfo.xcprivacy missing"
fi

# Check 11: StoreKit configuration
echo -n "Checking StoreKit configuration... "
if [ -f "anxietyapp/Configuration.storekit" ]; then
    success "StoreKit configuration found"
else
    warning "Configuration.storekit not found (optional for testing)"
fi

# Check 12: Widget implementation
echo -n "Checking widget extension... "
if [ -f "SOSWidget/SOSWidget.swift" ]; then
    success "Widget extension implemented"
else
    error "Widget implementation missing"
fi

# Check 13: Legal documents published
echo -n "Checking legal documents... "
if [ -f "docs/privacy.html" ] && [ -f "docs/terms.html" ]; then
    success "Legal documents present"
else
    error "Privacy Policy or Terms missing from docs/"
fi

echo ""
echo "🔐 Checking Security..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check 14: No hardcoded API keys in Swift files
echo -n "Scanning for hardcoded secrets... "
if grep -r "appl_\|sk_\|pk_\|AIza" --include="*.swift" anxietyapp/ >/dev/null 2>&1; then
    error "Potential hardcoded API keys found in Swift files"
else
    success "No hardcoded secrets detected"
fi

# Check 15: Debug statements wrapped
echo -n "Checking for unwrapped print statements... "
UNWRAPPED_PRINTS=$(grep -r "print(" --include="*.swift" anxietyapp/ | grep -v "#if DEBUG" | grep -v "//.*print(" | wc -l | tr -d ' ')
if [ "$UNWRAPPED_PRINTS" -gt "10" ]; then
    warning "$UNWRAPPED_PRINTS print statements may not be wrapped in DEBUG"
else
    success "Print statements appear properly wrapped"
fi

echo ""
echo "📦 Checking Dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check 16: Package.resolved exists
echo -n "Checking Package.resolved... "
if [ -f "anxietyapp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    success "Dependencies resolved"

    # Check versions
    echo -n "Checking RevenueCat version... "
    if grep -q "5.40.0" anxietyapp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved; then
        success "RevenueCat 5.40.0"
    else
        warning "RevenueCat version mismatch"
    fi

    echo -n "Checking AppsFlyer version... "
    if grep -q "6.17" anxietyapp.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved; then
        success "AppsFlyer 6.17.x"
    else
        warning "AppsFlyer version mismatch"
    fi
else
    error "Package.resolved missing - dependencies not resolved"
fi

echo ""
echo "📊 Final Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL CHECKS PASSED!${NC}"
    echo ""
    echo "✅ Ready for App Store submission"
    echo ""
    echo "Next steps:"
    echo "  1. Archive in Xcode: Product → Archive"
    echo "  2. Validate archive before uploading"
    echo "  3. Upload to App Store Connect"
    echo "  4. Submit for review"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS WARNINGS${NC}"
    echo ""
    echo "Build may proceed, but review warnings above"
    exit 0
else
    echo -e "${RED}❌ $ERRORS ERRORS, $WARNINGS WARNINGS${NC}"
    echo ""
    echo "🛑 DO NOT SUBMIT until errors are fixed"
    echo ""
    echo "Review errors above and fix before archiving"
    exit 1
fi
