
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string value: "0"
    property real progress: 0
    property color barColor: "#6599D5"

    Layout.fillWidth: true
    Layout.preferredHeight: 135

    color: "#202329"
    radius: 8

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        Text {
            text: root.title
            color: "#A0A5AE"
            font.pixelSize: 14
        }

        Text {
            text: root.value
            color: "#FFFFFF"
            font.pixelSize: 25
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 5

            radius: 3
            color: "#383D45"

            Rectangle {
                width: parent.width * Math.max(0, Math.min(100, root.progress)) / 100
                height: parent.height
                radius: 3
                color: root.barColor
            }
        }
    }
}
