## 📘 Overview

The **coatmaster Flex** supports custom applications built in QML, allowing developers and partners to:
- Create tailored measurement interfaces.
- Connect to external control systems via HTTP.
- Automate process feedback and closed-loop control.
- Access device parameters, configurations, and live data through the Flex API.

This folder provides working code examples, documentation, and guides to support your development.

## ⚙️ Getting Started

### 1. Deploying a Flex Custom App
1. Prepare your application folder (must include `App.qml` at the root).
2. Compress the folder into a `.zip` file.
3. Log into the Coatmaster Flex web interface.
4. Navigate to **settings → Apps→upload**, then select your zip file.
5. Launch the app on the device **settings → FlexApps** and follow on-screen instructions.

![Flex App Store](images/flex_app_store.png)

## Custom App Development for the Coatmaster Flex

This guide provides everything you need to know to create your own QML applications for the **Coatmaster Flex** coating thickness measurement device. These custom apps, which appear as dialogs on the device, allow you to build tailored interfaces for controlling processes like your coating line, enabling a seamless workflow for measuring thickness and adjusting parameters directly on the device.

---

## Deployment

To deploy your custom app, you must package all your files into a single `.zip` archive.

* **Main File:** The main QML file of your application **must be named `App.qml`**.
* **File Structure:** The `App.qml` file must be located at the **root level** of the zip archive, not inside any folders. Other assets like additional QML components or images can be placed in sub-folders (e.g., `/lib`, `/images`).
* **Uploading:** The final `.zip` file is then uploaded to the Coatmaster Flex through its web interface.

---

## I. Core Concepts & API Reference

This section covers the foundational components and their properties.

### Navigation: The Grid System

The user interface is navigated using a simple grid system. Every interactive `FlexQmlItem` must be assigned a `navigationRow` and a `navigationColumn` to place it within this grid. The user can then move between items using the directional keys on the device.

While coordinates for active items must be unique, it is possible to have multiple items assigned to the same `navigationRow` and `navigationColumn`. However, in such cases, it is the **developer's responsibility** to ensure that only one of these items is active (i.e., `visible` and `enabled`) at any given time. Failure to manage this will result in ambiguous navigation paths, where the system cannot determine the correct item to focus on.

A common and powerful pattern for managing different sets of controls is to use a `StackView`. You can define different pages or views as separate `Component` objects and push them onto the stack. This automatically handles the visibility, ensuring that only the navigation items on the top-most view are active. The `measurementStack` example provides a clear demonstration of this advanced pattern.

For example, in `ExampleApp.qml`, you can see a `FlexTextInput` and a `FlexCheckbox` placed on the same row but in different columns, representing a simple layout:

```javascript
FlexTextInput{
    navigationRow: 1
    navigationColumn: 0
    // ...
}

FlexCheckbox{
    navigationRow: 1
    navigationColumn: 1
    // ...
}
```

### The `FlexDialog` Object

The `FlexDialog` is a global object that provides access to system-level properties and functions within your QML app.

**Properties:**

* `unit` (string, read-only): The measurement unit configured on the device (e.g., "µm").
* `foregroundColor` (color, read-only): The primary foreground color for text and icons.
* `backgroundColor` (color, read-only): The dialog's background color.
* `accentColor` (color, read-only): The accent color used for highlighting focused items.

**Invokable Functions:**

* `closeDialog()`: Closes the current dialog.
* `loadQmlDialog(const QUrl& url, QWidget* parentDialog=nullptr, QVariantMap context=QVariantMap())`: Loads and opens a new QML dialog.
    * `url`: The URL to the QML file for the new dialog.
    * `parentDialog`: (Optional) A reference to the parent dialog.
    * `context`: (Optional) A `QVariantMap` to pass properties to the new dialog's context.

### The `FlexQmlItem` Component

Since the Coatmaster Flex does not use a mouse or touchscreen, every interactive element in your app must be a `FlexQmlItem`. This is the foundational component that enables user interaction. Our pre-built components like `FlexButton` already incorporate a `FlexQmlItem`.

**Properties:**

* `navigationRow` (int): The row position of the item in the navigation grid.
* `navigationColumn` (int): The column position of the item in the navigation grid.
* `isFocused` (bool): `true` if the item currently has navigation focus. A highlight frame is automatically shown.
* `visualItem` (QQuickItem*): A reference to the underlying visual QML item.
* `itemId` (string): A unique identifier for the item.
* `foregroundColor`, `backgroundColor`, `accentColor` (color, read-only): Inherited from `FlexDialog` for consistent theming.
* `selectable` (bool): If `true`, the item can receive focus.
* `keyCapture` (bool): If `true`, this item will capture all key events (up, down, left, right, ok, back) until set to `false`. This is useful for components like lists or combo boxes that need to handle navigation internally.
* `visible` (bool): Controls the visibility of the item.
* `enabled` (bool): If `false`, the item is visible but cannot be focused or activated.
* `text` (string): A text property often used for passing data to the underlying visual item or for opening the keyboard with initial text.
* `flexDialog` (QObject*): A reference to the `FlexDialog` object.

**Invokable Functions:**

* `openKeyboard(string title="", string type="normal")`: Opens the on-screen keyboard.
    * `title`: An optional title to display on the keyboard dialog.
    * `type`: The keyboard type. Can be `"normal"`, `"numeric"`, or `"full"`.

---

## II. Pre-Built UI Components

To make development faster and easier, we provide a set of ready-to-use QML components that are built upon `FlexQmlItem`.

### `FlexTextInput`

A text input field. When activated, it calls `openKeyboard()`.
**properties:**
* `navigationRow` (int): The row position of the item in the navigation grid.
* `navigationColumn` (int): The column position of the item in the navigation grid.
* `keyboardType` (string -> "normal", "numeric" or "full")  
* all properties of QtQuick.Controls TextField

### `FlexButton`

A standard button. Its `onClicked` signal is triggered on activation.
**properties:**
* `navigationRow` (int): The row position of the item in the navigation grid.
* `navigationColumn` (int): The column position of the item in the navigation grid.
* all properties of QtQuick.Controls Button

### `FlexComboBox`

A dropdown menu. It uses `keyCapture` to handle internal navigation of its options. The `model` can be a simple list of strings (e.g., `model: ["a", "b", "c"]`) or a `ListModel`. If a `ListModel` is used, you may need to set the `textRole` property to specify which model property to display.
**properties:**
* `navigationRow` (int): The row position of the item in the navigation grid.
* `navigationColumn` (int): The column position of the item in the navigation grid.
* `model` (list | ListModel): The data model providing the items for the dropdown.
* `textRole` (string): The name of the model role to be used for the display text.
* all properties of QtQuick.Controls ComboBox

### `FlexList`

A list of items. It uses `keyCapture` to allow the user to scroll through its contents.
**properties:**
* `navigationRow` (int): The row position of the item in the navigation grid.
* `navigationColumn` (int): The column position of the item in the navigation grid.
* `keyCapture` (bool): If `true`, this item will capture all key events (up, down, left, right, ok, back) until set to `false`. This is useful for components like lists or combo boxes that need to handle navigation internally.
* all properties of QtQuick.Controls ListView

### `FlexScrollView`

A scrollable area for content that exceeds the screen size. It's based on `Flickable` and integrates with the navigation system to allow scrolling using the hardware keys.

When the component is focused, a border is drawn around it. Pressing the OK button captures the up/down keys, allowing the user to scroll through the content. Pressing OK again or the Back key releases the key capture and returns to normal grid navigation.

**Properties:**
* `navigationRow` (int): The row position of the item in the navigation grid.
* `navigationColumn` (int): The column position of the item in the navigation grid.
* `content` (default property): Assign QML items here to make them part of the scrollable content.

**Signals:**
* `keyBack()`: Fired when the back key is pressed while the view is capturing keys for scrolling.

**Example Usage:**
```qml
FlexScrollView {
    navigationRow: 0
    navigationColumn: 0
    width: parent.width
    height: 200 // Set a fixed height for the scrollable area

    onKeyBack: console.log("Back pressed from scroll view")

    content: [
        Text {
            text: "Very long text that needs to be scrolled..."
            wrapMode: Text.WordWrap
            width: parent.width
        },
        Rectangle {
            width: 50
            height: 50
            color: "red"
            // More items...
        }
    ]
}
```

### `FlexCheckbox`

A simple checkbox that toggles its `checked` state on activation.
**properties:**
* `navigationRow` (int): The row position of the item in the navigation grid.
* `navigationColumn` (int): The column position of the item in the navigation grid.
* all properties of QtQuick.Controls CheckBox

### `FlexPopupDialog`

A modal dialog that appears over the current view to show a message and wait for user confirmation.
**properties:**
* `title` (string): The title displayed at the top of the dialog.
* `text` (string): The main message text of the dialog.
**signals:**
* `onAccepted`: Fired when the user accepts the dialog, typically by pressing the "OK" button.

### `FlexQmlWifi`

A non-visual component that provides information about the device's current Wi-Fi connection status.
**properties:**
* `connected` (bool, read-only): `true` if the device is connected to a Wi-Fi network.
* `signalStrength` (int, read-only): The signal strength of the connection.
* `ssid` (string, read-only): The SSID of the connected network.
* `ipAddress` (string, read-only): The local IP address of the device.
* `macAddress` (string, read-only): The MAC address of the device's Wi-Fi adapter.

### `FlexQmlQrCode`

A component for rendering a QR code from a given text string.
**properties:**
* `text` (string): The text data to be encoded into the QR code.
* `color` (color): The color of the dark modules of the QR code.
* `backgroundColor` (color): The color of the light modules (the background) of the QR code.

### `FlexTCP`

A non-visual component that enables communication with a TCP server. It works by proxying TCP data over a WebSocket connection to the device's backend, which then forwards it to the target server. This is useful for integrating with PLCs or other industrial equipment on the local network. **Note: This component is only available when using the coatmaster local server, not with a cloud interface.**

**Properties:**

*   `ipAddress` (string): The IP address of the target TCP server.
*   `port` (int): The port number of the target TCP server.
*   `status` (string, read-only): The current status of the WebSocket connection (e.g., "Open", "Closed", "Error").
*   `delimiter` (string): A string that is appended to every outgoing message. Defaults to ";".

**Signals:**

*   `commandReceived(var cmd, var args)`: Fired when a message is received that follows the format `COMMAND?ARG1=VAL1&ARG2=VAL2`. The signal provides the command string and an object with the parsed arguments.
*   `messageReceived(var message)`: Fired for every raw message received from the TCP server.
*   `error(var message)`: Fired when a connection error occurs.

**Invokable Functions:**

*   `sendMessage(string message)`: Sends the given message string to the target TCP server.

---

## III. Measurements and Device Interaction

Your app can directly interact with the device's measurement capabilities and hardware buttons.

### Taking a Measurement with `FlexQmlMeasure`

The `FlexQmlMeasure` component is your primary tool for handling measurements.

1.  **Initiate a Measurement**: Call the `measure()` function on your `FlexQmlMeasure` item.
2.  **Displaying Results**: The `onNewMeasurement` signal is emitted when a measurement is complete. It returns a `measurement` object with the data.
3.  **Handling Busy State**: The `busy` property of `FlexQmlMeasure` is `true` while a measurement is in progress.

### The `measurement` Object

The `onNewMeasurement` signal provides a `measurement` object with the following structure:

* `configId` (int): The ID of the measurement configuration used.
* `displayStatus` (object): An object containing display information.
    * `category` (string): The status category (e.g., "OK").
    * `colourCode` (string): A hex color code for displaying the result.
    * `icon` (string): The name of an icon related to the status.
    * `showThickness` (bool): Whether the thickness value should be displayed.
    * `text` (string): Additional status text to display.
* `error` (int): An error code (0 if no error).
* `evaluateState` (string): The evaluation state (e.g., "OK").
* `fit` (double): The fit value of the measurement.
* `fitState` (string): The state of the fit calculation.
* `id` (int): The unique ID of the measurement record.
* `sampleId` (int): The ID of the sample.
* `snr` (double): The signal-to-noise ratio.
* `snrState` (string): The state of the signal-to-noise ratio.
* `thickness` (double): The raw thickness value.
* `thicknessString` (string): The thickness value formatted as a string.
* `timeStamp` (string): The timestamp of the measurement.

### Responding to Hardware Buttons

The `FlexDialog` object allows you to listen for hardware button presses.

* **`onTriggerPressed`**: Fired when the main measurement trigger is pressed.
* **`onKeyBackPressed`**: Fired when the back key is pressed. A common use is to close the custom app dialog by calling `FlexDialog.closeDialog()`.
* **Emergency Exit**: If a QML app is unresponsive, a **long press of the back button** will force-close the dialog and return to the main menu. This is a safety feature to prevent getting stuck in a broken app.

---

## IV. Fetching Data from a Server

Your app can retrieve data from the Coatmaster server using HTTP requests.

### Using the `utils.js` Library

We provide a utility library, `utils.js`, for making asynchronous network requests. You must import it in your QML file: `import "../lib/utils.js" as Utils`.

**Security Note**: For security reasons, QML apps can only make HTTP calls to the Coatmaster server they are running on. The base URL is selected automatically. You only need to provide the path to the endpoint (e.g., `/configurations`).

The library provides the following functions:

* `Utils.httpRequest(method, path, requestData)`
* Convenience Functions: `Utils.get(path)`, `Utils.post(path, data)`, `Utils.put(path, data)`, `Utils.patch(path, data)`, `Utils.del(path)`.

---

### Accessing a Remote Server

It is also possible to access any remote server through a built-in proxy. To do this, you must construct the URL in the following format:

`"http://localhost:9883/proxy?target=<your_full_remote_url>"`

The host part of the URL is automatically replaced with the Coatmaster server's address, so you only need to specify the `proxy?target=<your_full_remote_url>` path.

For example, to access `https://jsonplaceholder.typicode.com/posts/1`, you would use the URL:

`"http://localhost:9883/proxy?target=https://jsonplaceholder.typicode.com/posts/1"`

You can use the standard `XMLHttpRequest` object for this purpose.


**Remote Server Example:**

```javascript

Component.onCompleted: {
	Utils.httpRequest("GET", "/proxy?target=https://jsonplaceholder.typicode.com/posts/1").then(function (data) {
		responseText.text = "Title: " + data.title; // Extracting the title
	}).catch(function (error) {
		responseText.text = "Error: " + error.message;
	});
}

Text {
	id: responseText
	text: "Loading..."
}


```
---
## V. Examples

### Hello World

This is the simplest possible app. It displays "Hello World" and ensures the dialog can be closed with the back button.

[Link to Hello World example code](helloWorld)

![Hello World](images/flex_hello_world.png)

### Closed-Loop Example

This example demonstrates how to create a closed-loop feedback system between a Coatmaster Flex custom app and an external control system, simulated by a simple Python server.

[Link to Closed-Loop example code](closed-loop-example)

![Flex Demo App](images/flex_demo_app.png)

### Example App

This example demonstrates a more complex application with various UI components and data fetching from the Coatmaster Flex server.

[Link to Example App code](exampleApp)
