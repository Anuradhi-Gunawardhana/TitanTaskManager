

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

    property var filteredProcesses: {
        let query = searchInput.text.toLowerCase()

        return systemMonitor.processes.filter(function(p) {
            return p.name.toLowerCase().includes(query) ||
                   String(p.pid).includes(query)
        })
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

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

                            onClicked: window.currentPage = modelData
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

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

            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                visible: window.currentPage === "Overview"

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

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#202329"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Processes"
                            color: "#FFFFFF"
                            font.pixelSize: 17
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 210
                            height: 34
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
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "Process"
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "PID"
                            width: 75
                        }

                        Text {
                            text: "CPU"
                            width: 85
                        }

                        Text {
                            text: "Memory"
                            width: 100
                        }

                        Repeater {
                            model: 4

                            delegate: Item {
                                visible: false
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        clip: true
                        spacing: 2
                        model: window.filteredProcesses

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 38
                            radius: 4
                            color: index % 2 === 0
                                   ? "#252930" : "transparent"

                            
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

                        }
                    }
                }
            }
        }
    }
}
