# GitHub Action Webhook Logger

A GitHub Action that **receives** API calls via GitHub's repository dispatch webhook system and logs query parameters and request body for debugging and monitoring purposes.

## Features

- 🎯 **Webhook Receiver**: Receives external API calls via GitHub repository dispatch
- 📝 **Comprehensive Logging**: Logs query parameters, request body, headers, and metadata
- 🔍 **GitHub Actions Integration**: Native GitHub Actions workflow
- 📦 **Artifact Storage**: Saves logs as downloadable artifacts
- 🛡️ **Error Handling**: Graceful error handling and response formatting
- 🚀 **Easy Integration**: Simple trigger script for external services

## Quick Start

### 1. Setup Repository

```bash
git clone <your-repo-url>
cd github-action-webhook-logger
git push origin main
```

### 2. Create GitHub Token

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate a new token with `repo` scope
3. Copy the token (starts with `ghp_`)

### 3. Test the Webhook

```bash
# Using the provided trigger script
./trigger-webhook.sh -t YOUR_TOKEN -o YOUR_USERNAME -r YOUR_REPO -d '{"test": "data"}'

# Or using curl directly
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/json" \
  -d '{"event_type":"webhook-log","client_payload":{"query_params":{"param1":"value1"},"body":{"test":"data"}}}' \
  https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/dispatches
```

## GitHub Actions Usage

### Automatic Trigger (Repository Dispatch)

The workflow automatically triggers when external services send webhook calls via GitHub's repository dispatch API.

### Manual Trigger

1. Go to your repository's **Actions** tab
2. Select **Webhook Logger** workflow
3. Click **Run workflow**
4. Enter test data to log

### Workflow Configuration

The workflow includes:
- Repository dispatch trigger for external webhooks
- Manual trigger for testing
- Comprehensive logging of all webhook data
- Artifact creation for log storage

## Webhook Payload Structure

External services should send data in this format:

```json
{
  "event_type": "webhook-log",
  "client_payload": {
    "query_params": {
      "param1": "value1",
      "param2": "value2"
    },
    "body": {
      "message": "Hello from external service",
      "timestamp": "2024-01-01T00:00:00Z"
    },
    "headers": {
      "user-agent": "my-service/1.0",
      "content-type": "application/json"
    }
  }
}
```

## Integration Examples

### From Another GitHub Action
```yaml
- name: Trigger webhook logger
  run: |
    curl -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -H "Content-Type: application/json" \
      -d '{"event_type":"webhook-log","client_payload":{"source":"github-action","data":"test"}}' \
      https://api.github.com/repos/${{ github.repository }}/dispatches
```

### From External Service (Node.js)
```javascript
const axios = require('axios');

async function triggerWebhookLogger(data) {
  const response = await axios.post(
    'https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/dispatches',
    {
      event_type: 'webhook-log',
      client_payload: {
        query_params: data.queryParams,
        body: data.body,
        headers: data.headers,
        timestamp: new Date().toISOString()
      }
    },
    {
      headers: {
        'Accept': 'application/vnd.github+json',
        'Authorization': `Bearer ${process.env.GITHUB_TOKEN}`,
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json'
      }
    }
  );
}
```

## Logging Output

The GitHub Action logs detailed information for each webhook received:

```
=== Webhook Received ===
Event Type: repository_dispatch
Repository: username/repo-name
Ref: refs/heads/main
SHA: abc123def456
Actor: username
Workflow: Webhook Logger
Run ID: 1234567890
Run Number: 42

=== Repository Dispatch Payload ===
Action Type: webhook-log
Client Payload:
{
  "query_params": {
    "param1": "value1",
    "param2": "value2"
  },
  "body": {
    "test": "data",
    "timestamp": "2024-01-01T00:00:00Z"
  },
  "headers": {
    "user-agent": "my-service/1.0",
    "content-type": "application/json"
  }
}
```

## Configuration

### GitHub Token Setup

1. Create a Personal Access Token with `repo` scope
2. Store it securely (environment variable, secrets, etc.)
3. Use it to authenticate webhook calls

### Customization

You can modify the workflow behavior by editing `.github/workflows/webhook-logger.yml`:

- Add additional logging steps
- Implement data validation
- Add database storage
- Customize artifact retention
- Add notification steps

## Development

### Testing Locally

```bash
# Test the trigger script
./trigger-webhook.sh -t YOUR_TOKEN -o YOUR_USERNAME -r YOUR_REPO -d '{"test": "data"}'

# Test manual workflow trigger
# Go to Actions tab → Run workflow manually
```

### Files Structure

- `.github/workflows/webhook-logger.yml` - Main workflow file
- `trigger-webhook.sh` - Script to trigger webhooks from external services
- `WEBHOOK_CONFIG.md` - Detailed configuration guide
- `package.json` - Node.js dependencies (for local development)

## Use Cases

- **API Testing**: Log incoming webhook calls during development
- **Debugging**: Inspect request payloads and parameters
- **Monitoring**: Track webhook activity and performance
- **Integration Testing**: Verify webhook integrations work correctly
- **Documentation**: Generate examples of webhook payloads

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details.
