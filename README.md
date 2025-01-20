# sftp-server
Sftp-server with Docker 
This project implements a custom SFTP server using the openssh . This server holds commands to create user to access sftp connection.

## Features

- **User-specific folders**: Each user is restricted to their own folder within the base directory.
- **Custom authentication**: Users authenticate via username and password, which are loaded from a credentials file.
- **File upload**: Users can upload files, with the filename prepended by their username for easy identification.
- **Directory restriction**: Users can only access and interact with files within their specific folder. Attempts to list or access other folders will be denied.
- **Secure communication**: Uses openssh for secure SSH connections.
- **Webhook**:Webhook to get file on upload.

## Requirements

- Docker

## Installation

1.  Clone this repository or download the project files.

2.  Change your webhook url variable _WEBHOOK_URL_ in sftp-webhook.sh

3.  Docker build:
    ```bash
    docker build -t sftp-webhook-server .
    ```
4.  Start Docker:
    ```bash
    docker run -d --name sftp-server -p 2222:22 sftp-webhook-server
    ```
5.  Create sftp user:
    ```bash
    docker exec -it sftp-server /usr/local/bin/add-sftp-user.sh <username>
    ```
6.  Start webhook service:
    ```bash
    docker exec -it sftp-server /usr/local/bin/sftp-webhook.sh
    ```
