#!/bin/bash

response=$(curl -s http://beeheim.buzz:2407/status | jq '.players')
echo "Online players: $response"