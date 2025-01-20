#!/bin/bash

WEBHOOK_URL="https://api-cwe-dev.staging.serviligne.fr/api/v1/hl7/webhook/upload"
WATCH_BASE_DIR="/sftp"

# Function to set up watches dynamically
setup_inotify() {
    echo "Setting up inotify watches for existing directories..."

    inotifywait -m -e create --format '%w%f' "$WATCH_BASE_DIR"/*/uploads -r 2>/dev/null |
    while read filepath; do
        echo "File detected: $filepath"

        # Add a small delay to ensure the file is fully written
        sleep 2

        # Check if the file exists and is non-empty
        if [ -f "$filepath" ]; then
            echo "File found, checking content..."

            # Extract the username from the file path
            username=$(echo "$filepath" | awk -F'/' '{print $(NF-2)}')

            # Check if file is empty
            if [ ! -s "$filepath" ]; then
                echo "File is empty: $filepath"
            else
                echo "File content found for: $filepath"

                # Send the file and username as a multipart form submission
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Sending file and username to webhook..."
                curl --location "$WEBHOOK_URL" --form "username=$username" --form "file=@$filepath"

                if [ $? -eq 0 ]; then
                    echo "File sent successfully!"
                else
                    echo "Error sending file."
                fi
            fi
        else
            echo "File not found or is not a regular file: $filepath"
        fi
    done
}

# Ensure the base directory exists
if [ ! -d "$WATCH_BASE_DIR" ]; then
    echo "Base watch directory $WATCH_BASE_DIR does not exist. Creating..."
    mkdir -p "$WATCH_BASE_DIR"
    chmod 755 "$WATCH_BASE_DIR"
fi

# Start watching
setup_inotify
