
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window

    visible: true
    width: 1200
    height: 750
    minimumWidth: 950
    minimumHeight: 600

    title: "Titan Task Manager"
    color: "#17191E"

    property string currentPage: "Overview"
    property var selectedProcess: null
    property string actionMessage: ""

    property string sortBy: "cpu"
    property bool sortDescending: true

    property var filteredProcesses: {
        let query = searchInput.text.toLowerCase()

        return systemMonitor.processes.filter(function(p) {
            return p.name.toLowerCase().includes(query) ||
                   String(p.pid).includes(query)
        })
    }

    property var sortedProcesses: {
        let list = window.filteredProcesses.slice()

        list.sort(function(a, b) {
            let result = 0

            if (window.sortBy === "cpu")
                result = a.cpu - b.cpu
            else if (window.sortBy === "memory")
                result = a.memory - b.memory
            else
                result = a.name.localeCompare(b.name)

            return window.sortDescending ? -result : result
        })

        return list
    }

    Connections {
        target: systemMonitor

        function onMetricsUpdated() {
            if (window.selectedProcess !== null) {
                let updated = systemMonitor.processes.find(
                    p => p.pid === window.selectedProcess.pid
                )

                if (updated)
                    window.selectedProcess = updated
                else
                    window.selectedProcess = null
            }
        }
    }

    Dialog {
        id: terminateDialog

        title: "Terminate process?"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.Cancel

        contentItem: Rectangle {
            implicitWidth: 300
            implicitHeight: 75
            color: "#202329"

            Text {
                anchors.fill: parent
                anchors.margins: 15

                text: window.selectedProcess
                      ? "Terminate " + window.selectedProcess.name +
                        " (PID " + window.selectedProcess.pid + ")?"
                      : ""

                color: "#E5E7EB"
                wrapMode: Text.WordWrap
            }
        }

        onAccepted: {
            if (window.selectedProcess) {
                let pid = window.selectedProcess.pid

                if (systemMonitor.terminateProcess(pid)) {
                    window.actionMessage = "Termination requested"
                    window.selectedProcess = null
                } else {
                    window.actionMessage = "Unable to terminate process"
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: "#202329"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 28

                Text {
                    text: "Titan"
                    color: "#FFFFFF"
                    font.pixelSize: 23
                    font.bold: true
                }

                Repeater {
                    model: ["Overview", "Processes", "Workspaces"]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6

                        color: window.currentPage === modelData
                               ? "#343941" : "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData
                            color: "#E5E7EB"
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                window.currentPage = modelData
                                window.actionMessage = ""
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    text: "Titan Task Manager"
                    color: "#777E89"
                    font.pixelSize: 10
                }
            }
        }

        // Main content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 28
            spacing: 22

            Text {
                text: window.currentPage
                color: "#FFFFFF"
                font.pixelSize: 25
                font.bold: true
            }

            // OVERVIEW PAGE
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20

                visible: window.currentPage === "Overview"

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    MetricCard {
                        title: "CPU"
                        value: systemMonitor.cpuUsage.toFixed(1) + "%"
                        progress: systemMonitor.cpuUsage
                        barColor: "#6599D5"
                    }

                    MetricCard {
                        title: "Memory"
                        value: systemMonitor.memoryText
                        progress: systemMonitor.memoryUsage
                        barColor: "#56A98B"
                    }

                    MetricCard {
                        title: "Processes"
                        value: systemMonitor.processCount.toString()
                        progress: 0
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }

            // PROCESSES PAGE
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: window.currentPage === "Processes"

                color: "#202329"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 16

                    // Process list
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 14

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 190
                                height: 35
                                radius: 5
                                color: "#30343B"

                                TextInput {
                                    id: searchInput

                                    anchors.fill: parent
                                    anchors.margins: 9

                                    color: "#FFFFFF"
                                    font.pixelSize: 12
                                    clip: true

                                    Text {
                                        visible: !searchInput.text
                                        text: "Search processes..."
                                        color: "#858B95"
                                        font.pixelSize: 12
                                    }
                                }
                            }

                            ComboBox {
                                Layout.preferredWidth: 110
                                Layout.preferredHeight: 35

                                model: ["CPU", "Memory", "Name"]

                                currentIndex: 0

                                onActivated: function(index) {
                                    window.sortBy =
                                        ["cpu", "memory", "name"][index]
                                }
                            }

                            Button {
                                text: window.sortDescending ? "↓" : "↑"
                                Layout.preferredWidth: 38
                                Layout.preferredHeight: 35

                                onClicked: {
                                    window.sortDescending =
                                        !window.sortDescending
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: window.actionMessage
                            color: "#A0A5AE"
                            font.pixelSize: 11
                        }

                        // Table header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "Process"
                                color: "#858B95"
                                Layout.fillWidth: true
                                font.pixelSize: 12
                            }

                            Text {
                                text: "PID"
                                color: "#858B95"
                                Layout.preferredWidth: 65
                                font.pixelSize: 12
                            }

                            Text {
                                text: "CPU"
                                color: "#858B95"
                                Layout.preferredWidth: 65
                                font.pixelSize: 12
                            }

                            Text {
                                text: "Memory"
                                color: "#858B95"
                                Layout.preferredWidth: 85
                                font.pixelSize: 12
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#383D45"
                        }

                        ListView {
                            id: processList

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            clip: true
                            spacing: 2
                            model: window.sortedProcesses

                            delegate: Rectangle {
                                required property var modelData
                                required property int index

                                width: ListView.view.width
                                height: 38
                                radius: 4

                                color: window.selectedProcess &&
                                       window.selectedProcess.pid === modelData.pid
                                       ? "#3A414B"
                                       : index % 2 === 0
                                         ? "#252930" : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    Text {
                                        text: modelData.name
                                        color: "#E5E7EB"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        text: modelData.pid
                                        color: "#A0A5AE"
                                        Layout.preferredWidth: 65
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        text: modelData.cpu.toFixed(1) + "%"
                                        color: "#A0A5AE"
                                        Layout.preferredWidth: 65
                                        font.pixelSize: 12
                                    }

                                    Text {
                                        text: modelData.memory.toFixed(1) + " MB"
                                        color: "#A0A5AE"
                                        Layout.preferredWidth: 85
                                        font.pixelSize: 12
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        window.selectedProcess = modelData
                                        window.actionMessage = ""
                                    }
                                }
                            }
                        }
                    }

                    // Process details panel
                    Rectangle {
                        Layout.preferredWidth: 230
                        Layout.fillHeight: true

                        radius: 7
                        color: "#252930"
                        visible: window.selectedProcess !== null

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 16

                            Text {
                                text: "Process Details"
                                color: "#FFFFFF"
                                font.pixelSize: 16
                                font.bold: true
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: "#383D45"
                            }

                            Text {
                                text: window.selectedProcess
                                      ? window.selectedProcess.name : ""
                                color: "#E5E7EB"
                                font.pixelSize: 14
                                font.bold: true
                                wrapMode: Text.WrapAnywhere
                                Layout.fillWidth: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Text {
                                    text: "PID"
                                    color: "#858B95"
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: window.selectedProcess
                                          ? String(window.selectedProcess.pid) : ""
                                    color: "#FFFFFF"
                                    font.pixelSize: 13
                                }

                                Text {
                                    text: "CPU Usage"
                                    color: "#858B95"
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: window.selectedProcess
                                          ? window.selectedProcess.cpu.toFixed(1) + "%"
                                          : ""
                                    color: "#FFFFFF"
                                    font.pixelSize: 13
                                }

                                Text {
                                    text: "Memory Usage"
                                    color: "#858B95"
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: window.selectedProcess
                                          ? window.selectedProcess.memory.toFixed(1) + " MB"
                                          : ""
                                    color: "#FFFFFF"
                                    font.pixelSize: 13
                                }

                                Text {
                                    text: "Termination"
                                    color: "#858B95"
                                    font.pixelSize: 11
                                }

                                Text {
                                    text: window.selectedProcess
                                          ? (window.selectedProcess.canTerminate
                                             ? "Available" : "Restricted")
                                          : ""
                                    color: window.selectedProcess &&
                                           window.selectedProcess.canTerminate
                                           ? "#56A98B" : "#D58A75"
                                    font.pixelSize: 13
                                }
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Terminate Process"

                                enabled: window.selectedProcess &&
                                         window.selectedProcess.canTerminate

                                onClicked: terminateDialog.open()
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "Deselect"

                                onClicked: {
                                    window.selectedProcess = null
                                }
                            }
                        }
                    }
                }
            }

            // WORKSPACES PAGE
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: window.currentPage === "Workspaces"

                color: "#202329"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 22

                    Text {
                        text: "Workspace Monitoring"
                        color: "#FFFFFF"
                        font.pixelSize: 19
                        font.bold: true
                    }

                    Text {
                        text: "Monitor applications and workloads across ArchTitan workspaces."
                        color: "#A0A5AE"
                        font.pixelSize: 13
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // THM connection status
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 105

                        color: "#252930"
                        radius: 7
                        border.color: "#383D45"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 16

                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: "#D59A55"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: "Titan Hardware Manager"
                                    color: "#FFFFFF"
                                    font.pixelSize: 15
                                    font.bold: true
                                }

                                Text {
                                    text: "Not connected"
                                    color: "#D59A55"
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: "Waiting for ArchTitan Linux integration"
                                    color: "#858B95"
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }

                    // Workspace status
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        color: "#252930"
                        radius: 7
                        border.color: "#383D45"
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            width: parent.width - 50
                            spacing: 14

                            Text {
                                text: "No workspace data available"
                                color: "#E5E7EB"
                                font.pixelSize: 16
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: "Workspace information will appear here when Titan Task Manager is connected to THM on ArchTitan Linux."
                                color: "#858B95"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Integration information
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "EXPECTED DATA SOURCE"
                            color: "#858B95"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Text {
                            text: "/run/archtitan/thm-state.json"
                            color: "#A0B8D8"
                            font.pixelSize: 12
                            font.family: "monospace"
                        }

                        Text {
                            text: "Live workspace data is not available in this macOS build."
                            color: "#777E89"
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
