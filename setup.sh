#!/bin/bash
# Competitive Intel Setup Wizard
# Interactive setup for automated competitive intelligence reports

set -e

echo "🎯 Competitive Intelligence Report Setup"
echo "========================================"
echo ""

# Check if running in OpenClaw environment
if [ -z "$OPENCLAW_WORKSPACE" ]; then
    export OPENCLAW_WORKSPACE="$HOME/.openclaw/workspace"
fi

# Get company name
echo "Step 1: Target Company"
echo "----------------------"
read -p "What company should I analyze? " COMPANY_NAME

if [ -z "$COMPANY_NAME" ]; then
    echo "❌ Error: Company name is required"
    exit 1
fi

echo "✓ Analyzing: $COMPANY_NAME"
echo ""

# Get recipient email
echo "Step 2: Report Recipient"
echo "------------------------"
read -p "What email should receive the reports? " RECIPIENT_EMAIL

if [ -z "$RECIPIENT_EMAIL" ]; then
    echo "❌ Error: Email is required"
    exit 1
fi

echo "✓ Reports will be sent to: $RECIPIENT_EMAIL"
echo ""

# Get sender email (default to recipient)
echo "Step 3: Sender Email (Gmail)"
echo "----------------------------"
read -p "What Gmail address should send the reports? [$RECIPIENT_EMAIL] " SENDER_EMAIL
SENDER_EMAIL=${SENDER_EMAIL:-$RECIPIENT_EMAIL}

echo "✓ Reports will be sent from: $SENDER_EMAIL"
echo ""

# Check if gog is authenticated
echo "Checking Gmail authentication..."
if ! gog auth list 2>/dev/null | grep -q "$SENDER_EMAIL"; then
    echo "⚠️  Warning: $SENDER_EMAIL is not authenticated with gog"
    echo "Please run: gog auth add $SENDER_EMAIL --services gmail"
    echo ""
    read -p "Continue anyway? (y/n) " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        exit 1
    fi
fi

# Get schedule preferences
echo ""
echo "Step 4: Schedule Preferences"
echo "-----------------------------"
echo "When would you like to receive reports?"
echo ""
echo "1. Weekly (recommended)"
echo "2. Daily"
echo "3. Custom"
echo ""
read -p "Select option (1-3): " SCHEDULE_OPTION

case $SCHEDULE_OPTION in
    1)
        echo ""
        echo "Weekly Schedule Options:"
        echo "1. Tuesday 10:00 AM (default)"
        echo "2. Monday 9:00 AM"
        echo "3. Friday 4:00 PM"
        echo "4. Custom day/time"
        echo ""
        read -p "Select option (1-4): " WEEKLY_OPTION
        
        case $WEEKLY_OPTION in
            1) CRON_EXPR="0 10 * * 2"; SCHEDULE_DESC="Every Tuesday at 10:00 AM" ;;
            2) CRON_EXPR="0 9 * * 1"; SCHEDULE_DESC="Every Monday at 9:00 AM" ;;
            3) CRON_EXPR="0 16 * * 5"; SCHEDULE_DESC="Every Friday at 4:00 PM" ;;
            4)
                read -p "Enter day (0=Sun, 1=Mon, ..., 6=Sat): " DAY
                read -p "Enter hour (0-23): " HOUR
                read -p "Enter minute (0-59): " MINUTE
                CRON_EXPR="$MINUTE $HOUR * * $DAY"
                SCHEDULE_DESC="Custom: Day $DAY at $HOUR:$MINUTE"
                ;;
            *) CRON_EXPR="0 10 * * 2"; SCHEDULE_DESC="Every Tuesday at 10:00 AM" ;;
        esac
        ;;
    2)
        echo ""
        echo "Daily Schedule Options:"
        echo "1. 9:00 AM (start of business day)"
        echo "2. 5:00 PM (end of business day)"
        echo "3. Custom time"
        echo ""
        read -p "Select option (1-3): " DAILY_OPTION
        
        case $DAILY_OPTION in
            1) CRON_EXPR="0 9 * * *"; SCHEDULE_DESC="Daily at 9:00 AM" ;;
            2) CRON_EXPR="0 17 * * *"; SCHEDULE_DESC="Daily at 5:00 PM" ;;
            3)
                read -p "Enter hour (0-23): " HOUR
                read -p "Enter minute (0-59): " MINUTE
                CRON_EXPR="$MINUTE $HOUR * * *"
                SCHEDULE_DESC="Daily at $HOUR:$MINUTE"
                ;;
            *) CRON_EXPR="0 9 * * *"; SCHEDULE_DESC="Daily at 9:00 AM" ;;
        esac
        ;;
    3)
        echo ""
        echo "Custom Cron Expression"
        echo "----------------------"
        echo "Format: minute hour day-of-month month day-of-week"
        echo "Example: 0 10 * * 2 = Tuesday at 10:00 AM"
        echo ""
        read -p "Enter cron expression: " CRON_EXPR
        SCHEDULE_DESC="Custom: $CRON_EXPR"
        ;;
    *)
        CRON_EXPR="0 10 * * 2"
        SCHEDULE_DESC="Every Tuesday at 10:00 AM (default)"
        ;;
esac

echo "✓ Schedule: $SCHEDULE_DESC"
echo ""

# Get timezone
echo "Step 5: Timezone"
echo "----------------"
read -p "Enter timezone [Europe/Berlin]: " TIMEZONE
TIMEZONE=${TIMEZONE:-"Europe/Berlin"}

echo "✓ Timezone: $TIMEZONE"
echo ""

# Confirm settings
echo ""
echo "📋 Setup Summary"
echo "================"
echo "Target Company: $COMPANY_NAME"
echo "Recipient: $RECIPIENT_EMAIL"
echo "Sender: $SENDER_EMAIL"
echo "Schedule: $SCHEDULE_DESC"
echo "Timezone: $TIMEZONE"
echo ""
read -p "Create this cron job? (y/n) " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled."
    exit 0
fi

# Create the cron job JSON payload
JOB_PAYLOAD=$(cat <<JSONEOF
{
  "name": "Weekly Competitive Intel: $COMPANY_NAME",
  "schedule": {
    "kind": "cron",
    "expr": "$CRON_EXPR",
    "tz": "$TIMEZONE"
  },
  "payload": {
    "kind": "agentTurn",
    "message": "Generate and send the weekly competitive intelligence report for $COMPANY_NAME.\\n\\nCOMPANY TO ANALYZE: $COMPANY_NAME\\nRECIPIENT: $RECIPIENT_EMAIL\\nSENDER: $SENDER_EMAIL\\n\\nSTEPS:\\n1. Research $COMPANY_NAME and identify its top 10 competitors using web_search\\n2. Research **RECENT** competitive developments from **PAST 7 DAYS ONLY**:\\n   - Use web_search with freshness=\\"pw\\" (past week) parameter\\n   - Search for each competitor: news, product launches, partnerships, pricing changes\\n   - **CRITICAL:** Verify article dates. Reject anything older than 7 days\\n   - If no 7-day results, expand to 14 days maximum\\n3. Select the 3 most significant developments from the past week\\n4. Generate the report using HTML format with proper formatting\\n5. Send to $RECIPIENT_EMAIL using gog with --body-html flag\\n\\nCRITICAL RULES:\\n- **ONLY use news from past 7 days**\\n- Verify article publication dates. Reject anything from last month\\n- Use HTML tags ONLY - NO Markdown asterisks\\n- Include clickable source links using <a href='URL'>Name</a>",
    "model": "moonshot/kimi-k2.5",
    "thinking": "on",
    "timeoutSeconds": 300
  },
  "sessionTarget": "isolated",
  "notify": true
}
JSONEOF
)

# Create the job using openclaw CLI
echo ""
echo "Creating cron job..."
echo "$JOB_PAYLOAD" | openclaw cron add --json -

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Setup Complete!"
    echo "=================="
    echo ""
    echo "Your competitive intelligence report is scheduled:"
    echo "  Company: $COMPANY_NAME"
    echo "  To: $RECIPIENT_EMAIL"
    echo "  Schedule: $SCHEDULE_DESC"
    echo ""
    echo "Next report: Check with 'openclaw cron list'"
    echo ""
    echo "To modify or delete this job:"
    echo "  openclaw cron list"
    echo "  openclaw cron update <job-id> ..."
    echo "  openclaw cron remove <job-id>"
else
    echo ""
    echo "❌ Failed to create cron job. Please check your OpenClaw configuration."
    exit 1
fi