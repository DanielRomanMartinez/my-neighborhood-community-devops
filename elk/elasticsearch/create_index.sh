#!/usr/bin/env bash
echo "Creating mappings and indexes..."
curl -X DELETE "http://localhost:9200/action_logs"
curl -X DELETE "http://localhost:9200/commercegate_notification_logs"
curl -X DELETE "http://localhost:9200/commercegate_v1_notification_logs"
curl -X PUT "http://localhost:9200/action_logs" -H "Content-Type: application/json" -d @"action_logs.json"
curl -X PUT "http://localhost:9200/commercegate_notification_logs" -H "Content-Type: application/json" -d @"commercegate_notification_logs.json"
curl -X PUT "http://localhost:9200/commercegate_v1_notification_logs" -H "Content-Type: application/json" -d @"commercegate_v1_notification_logs.json"
echo "\nDone"
