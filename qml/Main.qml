
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 1200
    height: 750
    minimumWidth: 950
    minimumHeight: 600

    title: "Titan Task Manager"
    color: "#17191E"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        Rectangle {
            Layout.preferredWidth: 210
            Layout.fillHeight: true
            color: "#202329"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 25

                Text {
                    text: "Titan"
                    color: "#FFFFFF"
                    font.pixelSize: 23
                    font.bold: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: ["Overview", "Processes", "Workspaces"]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: 6
                            color: index === 0 ? "#343941" : "transparent"

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                color: "#E5E7EB"
                                font.pixelSize: 14
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    text: "Titan Task Manager"
                    color: "#777D87"
                    font.pixelSize: 11
                }
            }
        }

        // Main dashboard
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 28
            spacing: 24

            Text {
                text: "Overview"
                color: "#FFFFFF"
                font.pixelSize: 25
                font.bold: true
            }

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
    barColor: "#C69B60"
}

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#202329"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    Text {
                        text: "System"
                        color: "#FFFFFF"
                        font.pixelSize: 17
                        font.bold: true
                    }

                    Text {
                        text: "Process monitoring will appear here."
                        color: "#858B95"
                        font.pixelSize: 13
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
