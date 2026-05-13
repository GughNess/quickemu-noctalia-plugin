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
    property real contentPreferredHeight: 600 * Style.uiScaleRatio

    anchors.fill: parent

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginM

            // Error Banner
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                visible: mainInstance && mainInstance.lastError !== ""
                color: Qt.alpha(Color.mError, 0.2)
                radius: Style.radiusS
                border.color: Color.mError
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    NIcon {
                        icon: "alert-triangle"
                        color: Color.mError
                    }
                    NText {
                        Layout.fillWidth: true
                        text: mainInstance ? mainInstance.lastError : ""
                        color: Color.mError
                        elide: Text.ElideRight
                    }
                    NButton {
                        icon: "x"
                        onClicked: if(mainInstance) mainInstance.clearError()
                    }
                }
            }

            // Header
            RowLayout {
                Layout.fillWidth: true
                
                NText {
                    text: "Quickemu Manager"
                    color: Color.mOnSurface
                    pointSize: Style.fontSizeL
                    font.weight: Font.Bold
                    Layout.fillWidth: true
                }
                
                NButton {
                    icon: "refresh-cw"
                    text: "Refresh"
                    onClicked: {
                        if (mainInstance) mainInstance.refreshVmList();
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.alpha(Color.mOnSurface, 0.1)
            }

            // Existing VMs List
            NText {
                text: "Existing VMs"
                color: Color.mPrimary
                pointSize: Style.fontSizeM
                font.weight: Font.Bold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.alpha(Color.mOnSurface, 0.05)
                radius: Style.radiusM

                ListView {
                    id: vmList
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    model: mainInstance ? mainInstance.vmListModel : null
                    clip: true
                    spacing: Style.marginS

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        color: Color.mSurfaceVariant
                        radius: Style.radiusM

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Style.marginS

                            NText {
                                text: model.vmName
                                color: Color.mOnSurface
                                pointSize: Style.fontSizeS
                                Layout.fillWidth: true
                            }

                            NButton {
                                text: "Start"
                                icon: "play"
                                backgroundColor: Color.mPrimary
                                textColor: Color.mOnPrimary
                                onClicked: {
                                    if (mainInstance) mainInstance.startVm(model.vmName);
                                    PanelService.closeContextMenu(root.screen);
                                }
                            }
                            NButton {
                                text: "Edit"
                                icon: "edit-2"
                                onClicked: {
                                    if (mainInstance) mainInstance.editVm(model.vmName);
                                }
                            }
                            NButton {
                                text: "Delete"
                                icon: "trash-2"
                                backgroundColor: Color.mError
                                textColor: Color.mOnError
                                onClicked: {
                                    if (mainInstance) mainInstance.deleteVm(model.vmName);
                                }
                            }
                        }
                    }

                    NText {
                        anchors.centerIn: parent
                        text: "No VMs found."
                        color: Color.mOnSurfaceVariant
                        visible: vmList.count === 0
                        pointSize: Style.fontSizeS
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.alpha(Color.mOnSurface, 0.1)
            }

            // Create New VM Section
            NText {
                text: "Create New VM"
                color: Color.mPrimary
                pointSize: Style.fontSizeM
                font.weight: Font.Bold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                ComboBox {
                    id: osComboBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    model: mainInstance ? mainInstance.filteredOsListModel : null
                    textRole: "osName"
                    editable: true

                    onEditTextChanged: {
                        if (mainInstance) {
                            mainInstance.updateFilteredOsList(editText);
                        }
                    }

                    background: Rectangle {
                        color: Color.mSurfaceVariant
                        radius: Style.radiusS
                        border.color: osComboBox.activeFocus ? Color.mPrimary : "transparent"
                        border.width: 1
                    }
                    contentItem: TextField {
                        text: osComboBox.editText
                        color: Color.mOnSurface
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Style.marginS
                        font.pixelSize: 14
                        background: Item {}
                        onTextChanged: osComboBox.editText = text
                    }
                }

                NButton {
                    text: "Download"
                    icon: "download"
                    backgroundColor: Color.mPrimary
                    textColor: Color.mOnPrimary
                    enabled: osComboBox.editText !== "" && (!mainInstance || mainInstance.downloadProgress === 0.0)
                    onClicked: {
                        if (mainInstance && osComboBox.editText) {
                            mainInstance.createVm(osComboBox.editText);
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
                    color: Color.mSurfaceVariant
                    radius: Style.radiusS
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * (mainInstance ? mainInstance.downloadProgress : 0.0)
                    color: Color.mPrimary
                    radius: Style.radiusS
                }
                NText {
                    anchors.centerIn: parent
                    text: mainInstance ? Math.round(mainInstance.downloadProgress * 100) + "%" : "0%"
                    color: Color.mOnPrimary
                    pointSize: Style.fontSizeXS
                    font.weight: Font.Bold
                }
            }
        }
    }
}
