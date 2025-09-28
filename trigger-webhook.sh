#!/bin/bash

# GitHub Webhook Trigger Script
# This script sends a repository_dispatch event to trigger the webhook logger

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_OWNER="${REPO_OWNER:-}"
REPO_NAME="${REPO_NAME:-}"
ACTION_TYPE="${ACTION_TYPE:-webhook-log}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --token TOKEN     GitHub personal access token"
    echo "  -o, --owner OWNER     Repository owner (username or org)"
    echo "  -r, --repo REPO       Repository name"
    echo "  -a, --action ACTION   Action type (default: webhook-log)"
    echo "  -d, --data DATA       JSON data to send in client_payload"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  GITHUB_TOKEN         GitHub personal access token"
    echo "  REPO_OWNER           Repository owner"
    echo "  REPO_NAME            Repository name"
    echo ""
    echo "Examples:"
    echo "  $0 -t ghp_xxx -o myuser -r myrepo"
    echo "  $0 -t ghp_xxx -o myuser -r myrepo -d '{\"message\":\"test\"}'"
    echo "  GITHUB_TOKEN=ghp_xxx REPO_OWNER=myuser REPO_NAME=myrepo $0"
}

# Parse command line arguments
CLIENT_PAYLOAD="{}"

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--token)
            GITHUB_TOKEN="$2"
            shift 2
            ;;
        -o|--owner)
            REPO_OWNER="$2"
            shift 2
            ;;
        -r|--repo)
            REPO_NAME="$2"
            shift 2
            ;;
        -a|--action)
            ACTION_TYPE="$2"
            shift 2
            ;;
        -d|--data)
            CLIENT_PAYLOAD="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$GITHUB_TOKEN" ]]; then
    print_error "GitHub token is required. Use -t option or set GITHUB_TOKEN environment variable."
    exit 1
fi

if [[ -z "$REPO_OWNER" ]]; then
    print_error "Repository owner is required. Use -o option or set REPO_OWNER environment variable."
    exit 1
fi

if [[ -z "$REPO_NAME" ]]; then
    print_error "Repository name is required. Use -r option or set REPO_NAME environment variable."
    exit 1
fi

# Validate JSON payload
if ! echo "$CLIENT_PAYLOAD" | jq . >/dev/null 2>&1; then
    print_error "Invalid JSON in client payload: $CLIENT_PAYLOAD"
    exit 1
fi

# Prepare the API request
API_URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/dispatches"
REQUEST_BODY=$(jq -n \
    --arg action_type "$ACTION_TYPE" \
    --argjson client_payload "$CLIENT_PAYLOAD" \
    '{
        event_type: $action_type,
        client_payload: $client_payload
    }')

print_status "Sending webhook to: $REPO_OWNER/$REPO_NAME"
print_status "Action type: $ACTION_TYPE"
print_status "Payload: $CLIENT_PAYLOAD"

# Send the request
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_BODY" \
    "$API_URL")

# Extract response body and status code
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

# Check response
if [[ "$HTTP_CODE" == "204" ]]; then
    print_status "✅ Webhook sent successfully!"
    print_status "Check the Actions tab in your repository to see the triggered workflow."
elif [[ "$HTTP_CODE" == "401" ]]; then
    print_error "❌ Authentication failed. Check your GitHub token."
    echo "Response: $RESPONSE_BODY"
elif [[ "$HTTP_CODE" == "404" ]]; then
    print_error "❌ Repository not found or access denied."
    echo "Response: $RESPONSE_BODY"
else
    print_error "❌ Request failed with HTTP $HTTP_CODE"
    echo "Response: $RESPONSE_BODY"
fi

exit 0
