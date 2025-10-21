#!/bin/bash

# validate-config.sh
# Validates Config.plist exists and contains required API keys before building
# Add this as a Run Script Phase in Xcode Build Phases

set -e  # Exit on error

CONFIG_FILE="${SRCROOT}/anxietyapp/Config.plist"
CONFIG_TEMPLATE="${SRCROOT}/anxietyapp/Config-Template.plist"

echo "🔍 Validating Config.plist..."

# Check if Config.plist exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ ERROR: Config.plist not found at ${CONFIG_FILE}"
    echo ""
    echo "📝 To fix this:"
    echo "   1. Copy Config-Template.plist to Config.plist"
    echo "   2. Add your RevenueCat API Key and Mixpanel Token"
    echo ""
    echo "   Command: cp \"${CONFIG_TEMPLATE}\" \"${CONFIG_FILE}\""
    echo ""
    exit 1
fi

echo "✅ Config.plist exists"

# Validate Config.plist is valid plist format
if ! plutil -lint "$CONFIG_FILE" > /dev/null 2>&1; then
    echo "❌ ERROR: Config.plist is not a valid plist file"
    exit 1
fi

echo "✅ Config.plist is valid plist format"

# Check for required keys
REVENUECAT_KEY=$(plutil -extract RevenueCatAPIKey raw "$CONFIG_FILE" 2>/dev/null || echo "")
MIXPANEL_TOKEN=$(plutil -extract MixpanelToken raw "$CONFIG_FILE" 2>/dev/null || echo "")

# Validate RevenueCat API Key
if [ -z "$REVENUECAT_KEY" ] || [ "$REVENUECAT_KEY" = "YOUR_REVENUECAT_API_KEY" ]; then
    echo "❌ ERROR: RevenueCat API Key is missing or not configured in Config.plist"
    echo ""
    echo "📝 Get your API key from: https://app.revenuecat.com/"
    echo "   Then update the RevenueCatAPIKey value in ${CONFIG_FILE}"
    echo ""
    exit 1
fi

echo "✅ RevenueCat API Key is configured"

# Validate Mixpanel Token
if [ -z "$MIXPANEL_TOKEN" ] || [ "$MIXPANEL_TOKEN" = "YOUR_MIXPANEL_TOKEN" ]; then
    echo "❌ ERROR: Mixpanel Token is missing or not configured in Config.plist"
    echo ""
    echo "📝 Get your token from: https://mixpanel.com/project/settings"
    echo "   Then update the MixpanelToken value in ${CONFIG_FILE}"
    echo ""
    exit 1
fi

echo "✅ Mixpanel Token is configured"

echo ""
echo "✅ All configuration validations passed!"
echo ""
