# GitHub Action Webhook Logger

A simple GitHub Action that receives API calls and logs query parameters and body.

## Usage

Send a webhook to trigger the action:

```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/json" \
  -d '{"event_type":"webhook-log","client_payload":{"query_params":{"param1":"value1"},"body":{"test":"data"}}}' \
  https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/dispatches
```

## Payload Format

```json
{
  "event_type": "webhook-log",
  "client_payload": {
    "query_params": {
      "param1": "value1",
      "param2": "value2"
    },
    "body": {
      "message": "test data"
    }
  }
}
```

The action will log the query parameters and body in the GitHub Actions output.