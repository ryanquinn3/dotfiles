#!/bin/bash

# attach-to-jira.sh
# Add file attachments to existing Jira tickets using REST API
# Usage: ./attach-to-jira.sh TICKET_ID FILE_PATH [JIRA_BASE_URL] [JIRA_EMAIL]

set -e

# Extract authentication info from acli
ACLI_AUTH_OUTPUT=$(acli jira auth status 2>/dev/null || echo "")
ACLI_SITE=$(echo "$ACLI_AUTH_OUTPUT" | grep "Site:" | awk '{print $2}' | sed 's/^/https:\/\//')
ACLI_EMAIL=$(echo "$ACLI_AUTH_OUTPUT" | grep "Email:" | awk '{print $2}')

# Configuration with dynamic defaults
JIRA_BASE_URL="${3:-${ACLI_SITE}}"
JIRA_EMAIL="${4:-${ACLI_EMAIL}}"

# Function to display usage
usage() {
    echo "Usage: $0 TICKET_ID FILE_PATH [JIRA_BASE_URL] [JIRA_EMAIL]"
    echo ""
    echo "Arguments:"
    echo "  TICKET_ID     Jira ticket ID (e.g., PROD-4634)"
    echo "  FILE_PATH     Path to file to attach"
    echo "  JIRA_BASE_URL Optional base URL (default: from acli auth status)"
    echo "  JIRA_EMAIL    Optional email (default: from acli auth status)"
    echo ""
    echo "Environment Variables:"
    echo "  JIRA_API_TOKEN Required API token for authentication"
    echo ""
    echo "Examples:"
    echo "  $0 PROD-4634 ./schema.json"
    echo "  $0 ENG-123 /path/to/document.pdf user@company.com"
    exit 1
}

# Validate arguments
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments"
    usage
fi

TICKET_ID="$1"
FILE_PATH="$2"

# Validate inputs
if [[ -z "$TICKET_ID" ]]; then
    echo "Error: TICKET_ID cannot be empty"
    exit 1
fi

if [[ -z "$FILE_PATH" ]]; then
    echo "Error: FILE_PATH cannot be empty"
    exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
    echo "Error: File not found: $FILE_PATH"
    exit 1
fi

if [[ -z "$JIRA_API_TOKEN" ]]; then
    echo "Error: JIRA_API_TOKEN environment variable is required"
    echo "Set it with: export JIRA_API_TOKEN='your-api-token'"
    exit 1
fi

if [[ -z "$JIRA_BASE_URL" ]]; then
    echo "Error: Could not determine JIRA base URL"
    echo "Either run 'acli jira auth' first or provide base URL as 3rd argument"
    exit 1
fi

if [[ -z "$JIRA_EMAIL" ]]; then
    echo "Error: Could not determine JIRA email address"
    echo "Either run 'acli jira auth' first or provide email as 4th argument"
    exit 1
fi

# Get file info for display
FILE_NAME=$(basename "$FILE_PATH")
FILE_SIZE=$(du -h "$FILE_PATH" | cut -f1)

echo "Attaching file to Jira ticket..."
echo "  Ticket: $TICKET_ID"
echo "  File: $FILE_NAME ($FILE_SIZE)"
echo "  Jira: $JIRA_BASE_URL"
echo "  User: $JIRA_EMAIL"
echo ""

# Make the API call
RESPONSE=$(curl -X POST \
    "$JIRA_BASE_URL/rest/api/3/issue/$TICKET_ID/attachments" \
    -H "Accept: application/json" \
    -H "X-Atlassian-Token: no-check" \
    -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
    -F "file=@$FILE_PATH" \
    --silent \
    --show-error \
    --fail)

# Check if jq is available for pretty output
if command -v jq >/dev/null 2>&1; then
    echo "✅ Successfully attached:"
    echo "$RESPONSE" | jq -r '.[] | "  📎 \(.filename) (ID: \(.id), Size: \(.size) bytes)"'
    echo ""
    echo "View ticket: $JIRA_BASE_URL/browse/$TICKET_ID"
else
    echo "✅ Attachment successful!"
    echo "Response: $RESPONSE"
    echo ""
    echo "View ticket: $JIRA_BASE_URL/browse/$TICKET_ID"
fi