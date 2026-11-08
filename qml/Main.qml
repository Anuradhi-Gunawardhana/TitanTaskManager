
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 1200
    height: 750
    minimumWidth: 900
    minimumHeight: 600

    title: "Titan Task Manager"
    color: "#10141D"

    Rectangle {
        anchors.fill: parent
        color: "#10141D"

        Text {
            anchors.centerIn: parent
            text: "TITAN TASK MANAGER"
            color: "#FFFFFF"
            font.pixelSize: 30
            font.bold: true
        }
    }
}
