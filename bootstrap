#!/bin/bash

set -euo pipefail

# Setup for AWS Lambda
# SEE: https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html

# Install git if not already available
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    yum install -y git
fi

# Set up private key permissions
chmod 600 /var/task/id_ed25519
export GIT_SSH_COMMAND="ssh -i /var/task/id_ed25519 -o StrictHostKeyChecking=no"

function handler () {
    EVENT_DATA="$1"
    
    # Process the event
    echo "Processing event: $EVENT_DATA"
    
    # Create a temporary directory to work in
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR
    
    echo "Working in temporary directory: $TEMP_DIR"
    
    # Clone the repository
    echo "Cloning repository: $REPO_URL"
    git clone $REPO_URL repo
    cd repo
    
    # Generate a random change
    TIMESTAMP=$(date +%s)
    RANDOM_FILE="fake-commit-$TIMESTAMP.txt"
    echo "Creating random file: $RANDOM_FILE"
    echo "This is a fake commit created at $(date)" > $RANDOM_FILE
    
    # Add, commit and push the change
    git add $RANDOM_FILE
    git config --local user.name "$GIT_COMMITTER_NAME"
    git config --local user.email "$GIT_COMMITTER_EMAIL"
    COMMIT_MSG="Daily update ($(date))"
    git commit -m "$COMMIT_MSG"
    git push origin HEAD
    
    echo "Fake commit pushed successfully"
    
    # Clean up
    cd /tmp
    rm -rf $TEMP_DIR
    
    # Return response
    echo "{ \"statusCode\": 200, \"body\": \"Fake commit created successfully at $(date)\" }"
}

# Process Lambda requests
if [ "$#" -ge 1 ] && [ "$1" == "invoke" ]; then
    # Local invocation
    handler "${2:-{}}"
else
    # Lambda runtime invocation
    while true; do
        # Get an event
        HEADERS="$(mktemp)"
        EVENT_DATA=$(curl -sS -LD "$HEADERS" "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next")
        REQUEST_ID=$(grep -Fi Lambda-Runtime-Aws-Request-Id "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)
        
        # Process the event
        RESPONSE=$(handler "$EVENT_DATA")
        
        # Send the response
        curl -s -X POST "http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/$REQUEST_ID/response" -d "$RESPONSE"
    done
fi