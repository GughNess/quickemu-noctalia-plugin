import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    readonly property var mainInstance: pluginApi?.mainInstance

    property real contentPreferredWidth: 500 * Style.uiScaleRatio
    property real contentPreferredHeight: 500 * Style.uiScaleRatio

    anchors.fill: parent

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "#1e1e2e" // Catppuccin Mocha base

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginM

            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Quickemu Manager"
                    color: "#cdd6f4"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }
                
                NButton {
                    icon: "refresh-cw"
                    text: "Refresh"
                    backgroundColor: "#313244" // Surface0
                    textColor: "#cdd6f4" // Text
                    onClicked: {
                        if (mainInstance) mainInstance.refreshVmList();
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#45475a" // Surface1
            }

            // Existing VMs List
            Text {
                text: "Existing VMs"
                color: "#89b4fa" // Blue
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#181825" // Mantle
                radius: 8

                ListView {
                    id: vmList
                    anchors.fill: parent
                    anchors.margins: 8
                    model: mainInstance ? mainInstance.vmListModel : null
                    clip: true
                    spacing: 8

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        color: "#313244" // Surface0
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8

                            Text {
                                text: model.vmName
                                color: "#cdd6f4" // Text
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }

                            NButton {
                                text: "Start"
                                icon: "play"
                                backgroundColor: "#a6e3a1" // Green
                                textColor: "#11111b" // Crust
                                onClicked: {
                                    if (mainInstance) mainInstance.startVm(model.vmName);
                                    PanelService.closeContextMenu(root.screen);
                                }
                            }
                            NButton {
                                text: "Edit"
                                icon: "edit-2"
                                backgroundColor: "#89b4fa" // Blue
                                textColor: "#11111b" // Crust
                                onClicked: {
                                    if (mainInstance) mainInstance.editVm(model.vmName);
                                }
                            }
                            NButton {
                                text: "Delete"
                                icon: "trash-2"
                                backgroundColor: "#f38ba8" // Red
                                textColor: "#11111b" // Crust
                                onClicked: {
                                    if (mainInstance) mainInstance.deleteVm(model.vmName);
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "No VMs found."
                        color: "#6c7086" // Overlay0
                        visible: vmList.count === 0
                        font.pixelSize: 14
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#45475a" // Surface1
            }

            // Create New VM Section
            Text {
                text: "Create New VM"
                color: "#a6e3a1" // Green
                font.pixelSize: 16
                font.weight: Font.Bold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ComboBox {
                    id: osComboBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    model: mainInstance ? mainInstance.osListModel : null
                    textRole: "osName"
                    font.pixelSize: 16

                    background: Rectangle {
                        color: "#313244"
                        radius: 8
                        border.color: osComboBox.activeFocus ? "#89b4fa" : "transparent"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: osComboBox.displayText
                        color: "#cdd6f4"
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                        font.pixelSize: 16
                    }
                }

                NButton {
                    text: "Download"
                    icon: "download"
                    backgroundColor: "#cba6f7" // Mauve
                    textColor: "#11111b" // Crust
                    enabled: osComboBox.currentText !== "" && (!mainInstance || mainInstance.downloadProgress === 0.0)
                    onClicked: {
                        if (mainInstance && osComboBox.currentText) {
                            mainInstance.createVm(osComboBox.currentText);
                        }
                    }
                }
            }

            // Progress Bar
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                visible: mainInstance && mainInstance.downloadProgress > 0.0

                Rectangle {
                    anchors.fill: parent
                    color: "#313244"
                    radius: 4
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * (mainInstance ? mainInstance.downloadProgress : 0.0)
                    color: "#a6e3a1"
                    radius: 4
                }
                Text {
                    anchors.centerIn: parent
                    text: mainInstance ? Math.round(mainInstance.downloadProgress * 100) + "%" : "0%"
                    color: "#11111b"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
        }
    }
}
