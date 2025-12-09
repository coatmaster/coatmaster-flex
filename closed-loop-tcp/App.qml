import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtWebSockets 1.1
import "../lib/utils.js" as Utils
import "../lib"
import FlexUi 1.0

/**
 * WebSocket Client App for Coatmaster Flex
 * This app connects to a WebSocket server for real-time communication
 */
Item {
    id: app
    anchors.fill: parent
    property string appId: "tcp-client"


    ListModel {
        id: dataModel
    }

    function appendMessage(messageText, fromUser) {
        // Only scroll if the view is already at the bottom
        var atEnd = messageListView.atYEnd || messageListView.contentHeight <= messageListView.height;
        var prefix = fromUser ? "→ " : "← ";
        dataModel.append({
            message: prefix + messageText,
            time: new Date().toLocaleTimeString()
        });
        if (atEnd) {
            // Use a timer to scroll after the ListView has been updated
            scrollTimer.start();
        }
    }

    Timer {
        id: scrollTimer
        interval: 50 // ms
        repeat: false
        onTriggered: messageListView.positionViewAtEnd()
    }

    FlexTCP{
        id:tcpHandler
        ipAddress: ipAddressInput.text
        port: Number(portInput.text)
        delimiter: ";"
        onMessageReceived: function(message){
            const prefix = 'DATA:';
            let actualMessage = message.trim();
            // Safely remove the "DATA:" prefix if it exists
            if (actualMessage.startsWith(prefix)) {
                actualMessage = actualMessage.substring(prefix.length);
                appendMessage(actualMessage,false)
            }
        }

        // onCommandReceived: function (cmd, args){
        //     var printMessage = "command: " + cmd;

        //     for (const key of Object.keys(args)) {
        //        printMessage = printMessage +" "+ key +"->" + args[key]
        //     }
        //     appendMessage(printMessage,false)
        // }
    }
    

    // --- Hardware Key Handling (MANDATORY) ---
    Connections {
        target: FlexDialog
        onKeyBackPressed: {
            FlexDialog.closeDialog();
        }
        // onTriggerPressed not used but Connections block is required
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        FlexTextInput {
            id: ipAddressInput
            placeholderText: "ip address"
            text: "192.168.10.105"
            Layout.fillWidth: true
            navigationRow: 0
            navigationColumn: 0
            keyboardType: "full"
        }

        FlexTextInput {
            id: portInput
            placeholderText: "port"
            text: "1234"
            Layout.fillWidth: true
            navigationRow: 1
            navigationColumn: 0
            keyboardType: "numeric"
        }

        // Message List
        FlexList {
            id: messageListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            navigationRow: 2
            navigationColumn: 0
            model: dataModel
            spacing: 5
            width: parent.width

            delegate: Item {
                width: parent.width
                height: msgText.height + 5
                
                Text {
                    id: msgText
                    text: model.time + " " + model.message
                    color: FlexDialog.foregroundColor
                    wrapMode: Text.Wrap
                    width: parent.width - 10
                    font.pixelSize: 14
                }
            }
        }

        // Connection Status
        Text {
            id: connectionStatus
            text: tcpHandler.status
            Layout.fillWidth: true
            font.pixelSize: 16
            font.bold: true
            color: FlexDialog.foregroundColor
        }

        // Debug Info
        Text {
            id: debugInfo
            text: "..."
            Layout.fillWidth: true
            color: FlexDialog.foregroundColor
            font.pixelSize: 12
        }

        // Input Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            FlexTextInput {
                id: messageInput
                placeholderText: "Type message..."
                Layout.fillWidth: true
                navigationRow: 3// Adjusted row
                navigationColumn: 0
                keyboardType: "full"
                // Send on Enter
                onAccepted: {
                    tcpHandler.sendMessage(messageInput.text)
                    appendMessage(messageInput.text,true)
                }
            }
            
            FlexButton {
                id: sendButton
                text: "Send"
                navigationRow: 3
                navigationColumn: 1

                onClicked: {
                    tcpHandler.sendMessage(messageInput.text);
                    appendMessage(messageInput.text,true)
                }
            }
            FlexButton {
                id: sendButton2
                text: "test cmd"
                navigationRow: 3
                navigationColumn: 2

                onClicked: {
                    var tesCmd = "TEST?ARG1=1&ARG2=2&STRING=dlfgkjdflgj&Number=123.3465"
                    tcpHandler.sendMessage(tesCmd);
                    appendMessage(tesCmd,true)
                }
            }
        }

        // Clear button
        FlexButton {
            text: "Clear Messages"
            navigationRow: 4
            navigationColumn: 0
            Layout.fillWidth: true
            
            onClicked: {
                dataModel.clear()
                debugInfo.text = "Messages cleared"
            }
        }
    }
}
