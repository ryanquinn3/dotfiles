# Jira Attachment Reference

This document provides detailed instructions for adding file attachments to existing Jira tickets using the REST API.

## Overview

Since the `acli` command-line tool doesn't support creating attachments on work items, we use the Jira REST API directly with curl commands.

## Two Approaches

### 1. Inline Curl (Recommended - Portable)

Use curl commands directly for maximum portability across any system:

```bash
# Extract credentials from acli
JIRA_SITE=$(acli jira auth status | grep "Site:" | awk '{print $2}')
JIRA_EMAIL=$(acli jira auth status | grep "Email:" | awk '{print $2}')

# Attach the file
curl -X POST \
  "https://${JIRA_SITE}/rest/api/3/issue/TICKET_ID/attachments" \
  -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@/path/to/file" \
  --silent --show-error
```

**Benefits:**
- Works on any system, any directory
- No dependencies on script location
- Easy to customize inline
- Clear and transparent

### 2. Convenience Script (Optional)

A bash script wrapper is available at `scripts/attach-to-jira.sh` relative to this skill's directory. This provides validation, error handling, and formatted output, but requires knowing the script's location on your system.

## Prerequisites

1. **API Token**: Set your Jira API token as an environment variable:
   ```bash
   export JIRA_API_TOKEN='your-api-token-here'
   ```

2. **Authentication**: Ensure you're authenticated with `acli`:
   ```bash
   acli jira auth status
   ```

3. **Permissions**: User must have attachment permissions on the target ticket

## Inline Curl Usage (Recommended)

### Basic Example

```bash
# Set up variables
TICKET_ID="PROD-4634"
FILE_PATH=".ryanquinn3/schema.json"
JIRA_SITE=$(acli jira auth status | grep "Site:" | awk '{print $2}')
JIRA_EMAIL=$(acli jira auth status | grep "Email:" | awk '{print $2}')

# Attach file
curl -X POST \
  "https://${JIRA_SITE}/rest/api/3/issue/${TICKET_ID}/attachments" \
  -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@${FILE_PATH}" \
  --silent --show-error
```

### Multiple Files Example

```bash
TICKET_ID="PROD-4634"
JIRA_SITE=$(acli jira auth status | grep "Site:" | awk '{print $2}')
JIRA_EMAIL=$(acli jira auth status | grep "Email:" | awk '{print $2}')

# Attach multiple files
for file in wireframes.pdf requirements.md api-spec.yaml; do
  curl -X POST \
    "https://${JIRA_SITE}/rest/api/3/issue/${TICKET_ID}/attachments" \
    -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
    -H "X-Atlassian-Token: no-check" \
    -F "file=@${file}" \
    --silent --show-error
done
```

### Single-Line Quick Attach

```bash
# Quick one-liner for attaching a file
JIRA_SITE=$(acli jira auth status | grep "Site:" | awk '{print $2}') JIRA_EMAIL=$(acli jira auth status | grep "Email:" | awk '{print $2}') && curl -X POST "https://${JIRA_SITE}/rest/api/3/issue/PROD-4634/attachments" -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" -H "X-Atlassian-Token: no-check" -F "file=@schema.json"
```

## Script Usage (Optional)

If you prefer using the convenience script:

### Basic Syntax
```bash
./scripts/attach-to-jira.sh TICKET_ID FILE_PATH [JIRA_BASE_URL] [JIRA_EMAIL]
```

**Note:** You'll need to locate where the script is installed on your system. Common locations:
- `~/.claude/skills/jira-manager/scripts/attach-to-jira.sh`
- Custom skill installation directories

### Parameters

| Parameter | Required | Description | Default |
|-----------|----------|-------------|---------|
| `TICKET_ID` | Yes | Jira ticket ID (e.g., PROD-4634) | - |
| `FILE_PATH` | Yes | Path to file to attach | - |
| `JIRA_BASE_URL` | No | Jira instance URL | From `acli auth status` |
| `JIRA_EMAIL` | No | User email for authentication | From `acli auth status` |

### Script-Based Examples

#### Basic Usage
```bash
# Attach a schema file to ticket PROD-4634
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 .ryanquinn3/schema.json
```

#### Multiple Files
```bash
# Attach multiple files to the same ticket
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./wireframes.pdf
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./requirements.md
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./api-spec.yaml
```

#### Custom Configuration
```bash
# With custom Jira URL and email
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh ENG-123 ./document.pdf https://company.atlassian.net user@company.com
```

#### Common File Types
```bash
# Documentation
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./README.md
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./DESIGN.md

# Code files
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./schema.graphql
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./config.json

# Images and mockups
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./mockup.png
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./flow-diagram.svg

# Documents
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./requirements.pdf
/home/vscode/.claude/skills/jira-manager/scripts/attach-to-jira.sh PROD-4634 ./specifications.docx
```

## Script Features

### Validation
- Checks that the ticket ID and file path are provided
- Verifies the file exists and is readable
- Validates that `JIRA_API_TOKEN` is set
- Confirms email address is available

### Output
- Shows file information (name and size) before upload
- Displays formatted success message with attachment details
- Provides direct link to view the ticket
- Uses `jq` for pretty JSON formatting when available

### Error Handling
- Clear error messages for missing parameters
- File existence validation
- API token validation
- Network error handling with `curl --fail`

## File Specifications

### Supported File Types
Most common file formats are supported, including:
- **Text**: `.txt`, `.md`, `.json`, `.yaml`, `.xml`, `.csv`
- **Code**: `.js`, `.py`, `.java`, `.go`, `.sql`, `.graphql`
- **Images**: `.png`, `.jpg`, `.gif`, `.svg`, `.bmp`
- **Documents**: `.pdf`, `.docx`, `.xlsx`, `.pptx`
- **Archives**: `.zip`, `.tar.gz`, `.rar`

### Size Limits
- **Default**: Usually 10MB per file
- **Configurable**: Depends on Jira instance settings
- **Check with admin**: If you need larger file support

## Troubleshooting

### Common Issues

#### 1. Authentication Errors
```
Error: JIRA_API_TOKEN environment variable is required
```
**Solution**: Set your API token:
```bash
export JIRA_API_TOKEN='your-token-here'
```

#### 2. File Not Found
```
Error: File not found: ./missing-file.txt
```
**Solution**: Check file path and permissions:
```bash
ls -la ./missing-file.txt
```

#### 3. Permission Denied
```
HTTP 403: Forbidden
```
**Solution**: Verify you have attachment permissions on the ticket

#### 4. File Too Large
```
HTTP 413: Request Entity Too Large
```
**Solution**: Check file size limit with your Jira administrator

#### 5. Invalid Ticket ID
```
HTTP 404: Issue does not exist
```
**Solution**: Verify the ticket ID exists and you have access to it

### API Token Setup

1. **Generate Token**:
   - Go to: https://id.atlassian.com/manage-profile/security/api-tokens
   - Click "Create API token"
   - Copy the generated token

2. **Set Environment Variable**:
   ```bash
   # Add to your shell profile (.zshrc, .bashrc, etc.)
   export JIRA_API_TOKEN='your-token-here'
   
   # Or set temporarily
   export JIRA_API_TOKEN='your-token-here'
   ```

3. **Verify Setup**:
   ```bash
   echo $JIRA_API_TOKEN
   ```

## Integration with Jira Manager Skill

### Workflow Integration

1. **Create Ticket**: Use the main skill workflow to create a ticket
2. **Capture Ticket ID**: Save the returned ticket ID (e.g., PROD-4634)
3. **Attach Files**: Use this script to attach any necessary files
4. **Confirm**: Provide user with ticket URL and attachment confirmations

### Example Workflow
```bash
# 1. Create ticket (from main skill)
acli jira workitem create --from-json "./prod-ticket-create.json"
# Returns: PROD-4634

# 2. Extract credentials once
JIRA_SITE=$(acli jira auth status | grep "Site:" | awk '{print $2}')
JIRA_EMAIL=$(acli jira auth status | grep "Email:" | awk '{print $2}')

# 3. Attach supporting files
curl -X POST "https://${JIRA_SITE}/rest/api/3/issue/PROD-4634/attachments" \
  -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@.ryanquinn3/schema.json" --silent --show-error

curl -X POST "https://${JIRA_SITE}/rest/api/3/issue/PROD-4634/attachments" \
  -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@./wireframes.png" --silent --show-error

# 4. Clean up temp files
rm ./prod-ticket-create.json
```

## REST API Details

For reference, the script uses the Jira REST API v3 endpoint:

**Endpoint**: `POST /rest/api/3/issue/{issueIdOrKey}/attachments`

**Headers**:
- `Accept: application/json`
- `X-Atlassian-Token: no-check` (required for file uploads)

**Authentication**: Basic auth with email and API token

**Request**: Multipart form data with file attachment

**Response**: JSON array with attachment details including ID, filename, and size.

## Advanced Usage

### Batch Attachment Function (Portable)
For attaching multiple files at once:

```bash
#!/bin/bash
# Portable batch attach function
attach_files() {
    local ticket_id="$1"
    shift

    # Extract credentials once
    local jira_site=$(acli jira auth status | grep "Site:" | awk '{print $2}')
    local jira_email=$(acli jira auth status | grep "Email:" | awk '{print $2}')

    # Attach each file
    for file in "$@"; do
        echo "Attaching $file to $ticket_id..."
        curl -X POST \
            "https://${jira_site}/rest/api/3/issue/${ticket_id}/attachments" \
            -u "${jira_email}:${JIRA_API_TOKEN}" \
            -H "X-Atlassian-Token: no-check" \
            -F "file=@${file}" \
            --silent --show-error
    done
}

# Usage
attach_files PROD-4634 file1.txt file2.pdf file3.json
```

### Conditional Attachment (Portable)
Only attach if file exists:

```bash
FILE="./optional-file.txt"
if [[ -f "$FILE" ]]; then
    JIRA_SITE=$(acli jira auth status | grep "Site:" | awk '{print $2}')
    JIRA_EMAIL=$(acli jira auth status | grep "Email:" | awk '{print $2}')
    curl -X POST \
        "https://${JIRA_SITE}/rest/api/3/issue/PROD-4634/attachments" \
        -u "${JIRA_EMAIL}:${JIRA_API_TOKEN}" \
        -H "X-Atlassian-Token: no-check" \
        -F "file=@${FILE}" \
        --silent --show-error
fi
```