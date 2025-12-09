# TCP Client Example

This example demonstrates how to create a TCP client on the Coatmaster Flex to communicate with a TCP server.

## Overview

The application allows a user to:
1.  Connect to a TCP server with a specified IP address and port.
2.  Send messages to the server.
3.  Receive and display messages from the server in real-time.

This showcases how to use the `FlexTCP` component for direct TCP socket communication.

## Components

-   **`App.qml`**: A QML application for the Coatmaster Flex. It provides the user interface for connecting to the server, sending messages, and viewing the conversation.
-   **`tcpEchoServer.py`**: A simple Python TCP server that echoes back any message it receives. It's a useful tool for testing the QML app.

## How to Run the Example

### 1. Start the Python TCP Server

First, run the Python server on a computer that is on the same network as your Coatmaster Flex.

```bash
python tcpEchoServer.py
```

The server will start on port 1234. Note the IP address of the computer running the server.

### 2. Deploy the QML App

Package the `closed-loop-tcp` directory into a `.zip` file and upload it to your Coatmaster Flex via the web interface, as described in the main documentation.

### 3. Configure and Use the App

1.  Launch the "TCP Client" app on your Coatmaster Flex.
2.  Enter the IP address of your Python server in the "ip address" field (e.g., `192.168.10.105`).
3.  Enter the port number in the "port" field (the default is `1234`).
4.  The app will attempt to connect automatically. The status of the connection is displayed at the bottom.
5.  Type a message in the input field and press "Send" to send it to the server.
6.  The server's response (an echo of your message) will appear in the message list.
