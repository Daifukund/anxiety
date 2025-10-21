#!/bin/bash

# Mixpanel Lexicon Schema Upload Script
# This script uploads missing event schemas to your Mixpanel Lexicon

# ============================================
# CONFIGURATION - Fill these in:
# ============================================
PROJECT_ID="YOUR_PROJECT_ID"  # Find in Mixpanel Project Settings
SERVICE_ACCOUNT_USER="YOUR_SERVICE_ACCOUNT_USERNAME"
SERVICE_ACCOUNT_SECRET="YOUR_SERVICE_ACCOUNT_SECRET"
REGION_DOMAIN="mixpanel.com"  # or "eu.mixpanel.com" for EU

# ============================================
# Event Schemas - Missing from Lexicon
# ============================================

read -r -d '' PAYLOAD << 'EOF'
{
  "entries": [
    {
      "entityType": "event",
      "name": "Onboarding Started",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User begins the onboarding flow"
      }
    },
    {
      "entityType": "event",
      "name": "Onboarding Step Viewed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User views a specific onboarding step",
        "properties": {
          "step_name": {
            "type": "string",
            "description": "Name of the onboarding step"
          },
          "step_number": {
            "type": "number",
            "description": "Step number in the flow"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Goals Set",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User selects their personal goals during onboarding",
        "properties": {
          "goals": {
            "type": "array",
            "description": "List of selected goals"
          },
          "goal_count": {
            "type": "number",
            "description": "Number of goals selected"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Commitment Signed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User signs the commitment contract"
      }
    },
    {
      "entityType": "event",
      "name": "Notification Permission Result",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "iOS notification permission granted or denied",
        "properties": {
          "granted": {
            "type": "boolean",
            "description": "Whether permission was granted"
          },
          "context": {
            "type": "string",
            "description": "Context where permission was requested"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Paywall Viewed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User views the subscription paywall",
        "properties": {
          "source": {
            "type": "string",
            "description": "Where the paywall was triggered from"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Onboarding Completed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User completes the entire onboarding flow",
        "properties": {
          "time_spent_seconds": {
            "type": "number",
            "description": "Total time spent in onboarding"
          },
          "time_spent_minutes": {
            "type": "number",
            "description": "Total time in minutes"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Relief Experience Started",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User begins the relief experience"
      }
    },
    {
      "entityType": "event",
      "name": "Relief Experience Mood Check In",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User rates anxiety level before relief exercise",
        "properties": {
          "anxiety_before": {
            "type": "number",
            "description": "Anxiety rating before exercise"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Relief Experience SOS Breathing Completed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User completes the SOS breathing exercise"
      }
    },
    {
      "entityType": "event",
      "name": "Relief Experience Technique Chosen",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User selects a relief technique",
        "properties": {
          "technique": {
            "type": "string",
            "description": "Name of the chosen technique"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Relief Experience Technique Completed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User completes the chosen relief technique",
        "properties": {
          "technique": {
            "type": "string",
            "description": "Name of the completed technique"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Relief Experience Mood Check Out",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User rates anxiety level after relief exercise",
        "properties": {
          "anxiety_after": {
            "type": "number",
            "description": "Anxiety rating after exercise"
          },
          "improvement_points": {
            "type": "number",
            "description": "Points of improvement"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Informative Cards Completed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User finishes viewing informative cards",
        "properties": {
          "time_spent_seconds": {
            "type": "number",
            "description": "Time spent on cards"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Quiz Question Answered",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User answers an individual quiz question",
        "properties": {
          "question": {
            "type": "string",
            "description": "The question text"
          },
          "answer": {
            "type": "string",
            "description": "User's answer"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Purchase Cancelled",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User cancels the purchase flow",
        "properties": {
          "plan_type": {
            "type": "string",
            "description": "Subscription plan type"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Restore Purchase Success",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User successfully restores previous purchase",
        "properties": {
          "plan_type": {
            "type": "string",
            "description": "Restored subscription plan"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "SOS Button Tapped",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User taps the emergency SOS button"
      }
    },
    {
      "entityType": "event",
      "name": "Technique Started",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User starts an anxiety relief technique",
        "properties": {
          "technique_name": {
            "type": "string",
            "description": "Name of the technique"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Technique Completed",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User completes an anxiety relief technique",
        "properties": {
          "technique_name": {
            "type": "string",
            "description": "Name of the technique"
          },
          "duration_seconds": {
            "type": "number",
            "description": "Time spent on technique"
          }
        }
      }
    },
    {
      "entityType": "event",
      "name": "Mood Checkin",
      "schemaJson": {
        "$schema": "http://json-schema.org/draft-07/schema",
        "description": "User logs their current mood",
        "properties": {
          "mood": {
            "type": "string",
            "description": "User's mood state"
          }
        }
      }
    }
  ],
  "truncate": false
}
EOF

# ============================================
# Execute Upload
# ============================================

echo "🚀 Uploading 21 missing events to Mixpanel Lexicon..."
echo ""

# Check if credentials are set
if [ "$PROJECT_ID" = "YOUR_PROJECT_ID" ]; then
    echo "❌ ERROR: Please configure PROJECT_ID in this script first"
    echo ""
    echo "To find your Project ID:"
    echo "1. Go to Mixpanel → Project Settings"
    echo "2. Copy the Project ID"
    echo ""
    exit 1
fi

if [ "$SERVICE_ACCOUNT_USER" = "YOUR_SERVICE_ACCOUNT_USERNAME" ]; then
    echo "❌ ERROR: Please configure SERVICE_ACCOUNT credentials"
    echo ""
    echo "To create a Service Account:"
    echo "1. Go to Mixpanel → Organization Settings → Service Accounts"
    echo "2. Create a new service account with 'Admin' role"
    echo "3. Copy the Username and Secret"
    echo ""
    exit 1
fi

# Make API request
RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -u "$SERVICE_ACCOUNT_USER:$SERVICE_ACCOUNT_SECRET" \
  -d "$PAYLOAD" \
  "https://$REGION_DOMAIN/api/app/projects/$PROJECT_ID/schemas")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Successfully uploaded 21 events to Mixpanel Lexicon!"
    echo ""
    echo "Response:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
    echo ""
    echo "🎉 Check your Mixpanel Lexicon - all events should now be visible!"
else
    echo "❌ Upload failed with HTTP code: $HTTP_CODE"
    echo ""
    echo "Response:"
    echo "$BODY"
    echo ""
    echo "Common issues:"
    echo "- Check your Service Account credentials"
    echo "- Verify Project ID is correct"
    echo "- Ensure Service Account has Admin role"
fi
