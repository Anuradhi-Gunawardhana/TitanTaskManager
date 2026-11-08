
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

    property var filteredProcesses: {
        let query = searchInput.text.toLowerCase()

        return systemMonitor.processes.filter(function(p) {
            return p.name.toLowerCase().includes(query) ||
                   String(p.pid).includes(query)
        })
    }

    Connections {
        target: systemMonitor

        function onMetricsUpdated() {
            if (window.selectedProcess !== null) {
                let exists = systemMonitor.processes.some(
                    p => p.pid === window.selectedProcess.pid
                )

                if (!exists)
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

        contentItem: Text {
            text: window.selectedProcess
                  ? "Terminate " + window.selectedProcess.name +
                    " (PID " + window.selectedProcess.pid + ")?"
                  : ""
            color: "#E5E7EB"
            wrapMode: Text.WordWrap
            width: 280
            padding: 15
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
                    model: ["Overview", "Processes"]

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

            // Overview
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

            // Processes
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                visible: window.currentPage === "Processes"

                color: "#202329"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    // Search and actions
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 230
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

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 100
                            height: 35
                            radius: 5

                            color: window.selectedProcess &&
                                   window.selectedProcess.canTerminate
                                   ? "#9D4545" : "#383D45"

                            Text {
                                anchors.centerIn: parent
                                text: "Terminate"
                                color: "#FFFFFF"
                                font.pixelSize: 12
                            }

                            MouseArea {
                                anchors.fill: parent

                                enabled: window.selectedProcess &&
                                         window.selectedProcess.canTerminate

                                cursorShape: enabled
                                              ? Qt.PointingHandCursor
                                              : Qt.ArrowCursor

                                onClicked: terminateDialog.open()
                            }
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
                            Layout.preferredWidth: 75
                            font.pixelSize: 12
                        }

                        Text {
                            text: "CPU"
                            color: "#858B95"
                            Layout.preferredWidth: 85
                            font.pixelSize: 12
                        }

                        Text {
                            text: "Memory"
                            color: "#858B95"
                            Layout.preferredWidth: 100
                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#383D45"
                    }

                    // Process list
                    ListView {
                        id: processList

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        clip: true
                        spacing: 2

                        model: window.filteredProcesses

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
                                    Layout.preferredWidth: 75
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: modelData.cpu.toFixed(1) + "%"
                                    color: "#A0A5AE"
                                    Layout.preferredWidth: 85
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: modelData.memory.toFixed(1) + " MB"
                                    color: "#A0A5AE"
                                    Layout.preferredWidth: 100
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
            }
        }
    }
}
