# Webhook Configuration

## GitHub Repository Dispatch Webhook

This GitHub Action is configured to receive webhook calls via GitHub's `repository_dispatch` event. This allows external services to trigger the workflow and log their data.

### Setup Instructions

1. **Create a GitHub Personal Access Token**
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Generate a new token with `repo` scope
   - Copy the token (starts with `ghp_`)

2. **Configure Repository**
   - Ensure the repository has Actions enabled
   - The workflow will automatically be available after pushing

3. **Test the Webhook**
   ```bash
   # Using the trigger script
   ./trigger-webhook.sh -t YOUR_TOKEN -o YOUR_USERNAME -r YOUR_REPO -d '{"test": "data"}'
   
   # Or using curl directly
   curl -X POST \
     -H "Accept: application/vnd.github+json" \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "X-GitHub-Api-Version: 2022-11-28" \
     -H "Content-Type: application/json" \
     -d '{"event_type":"webhook-log","client_payload":{"message":"test data","timestamp":"2024-01-01T00:00:00Z"}}' \
     https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/dispatches
   ```

### Webhook Payload Structure

The webhook expects a JSON payload with:
- `event_type`: Must be "webhook-log" (or any type you configure)
- `client_payload`: Your custom data (query params, body, etc.)

Example payload:
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

### Integration Examples

#### From Another GitHub Action
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

#### From External Service (Node.js)
```javascript
const axios = require('axios');

async function triggerWebhookLogger(data) {
  try {
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
    console.log('Webhook triggered successfully');
  } catch (error) {
    console.error('Failed to trigger webhook:', error.message);
  }
}
```

#### From External Service (Python)
```python
import requests
import json
from datetime import datetime

def trigger_webhook_logger(data):
    url = "https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/dispatches"
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
        "X-GitHub-Api-Version": "2022-11-28",
        "Content-Type": "application/json"
    }
    
    payload = {
        "event_type": "webhook-log",
        "client_payload": {
            "query_params": data.get("query_params", {}),
            "body": data.get("body", {}),
            "headers": data.get("headers", {}),
            "timestamp": datetime.utcnow().isoformat()
        }
    }
    
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 204:
        print("Webhook triggered successfully")
    else:
        print(f"Failed to trigger webhook: {response.status_code}")
```

### Security Considerations

1. **Token Security**: Keep your GitHub token secure and never commit it to code
2. **Repository Access**: Only repositories you have access to can trigger the webhook
3. **Rate Limits**: GitHub API has rate limits (5000 requests/hour for authenticated users)
4. **Payload Size**: Keep payloads reasonable in size

### Monitoring and Debugging

1. **Check Actions Tab**: View triggered workflows in your repository's Actions tab
2. **Download Artifacts**: Each run creates a log artifact you can download
3. **View Logs**: Check the workflow logs for detailed information about received data
4. **Manual Testing**: Use the manual trigger option to test the workflow
