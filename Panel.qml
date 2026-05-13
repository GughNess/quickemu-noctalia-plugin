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

    // Panel geometry anchor for Noctalia's windowing system
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

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
                Layout.preferredHeight: errorRow.implicitHeight + Style.marginS * 2
                visible: mainInstance && mainInstance.lastError !== ""
                color: Qt.alpha(Color.mError, 0.15)
                radius: Style.radiusS
                border.color: Qt.alpha(Color.mError, 0.4)
                border.width: Style.borderWidth || 1

                RowLayout {
                    id: errorRow
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    spacing: Style.marginS

                    NIcon {
                        icon: "alert-triangle"
                        pointSize: Style.fontSizeS
                        color: Color.mError
                    }
                    NText {
                        Layout.fillWidth: true
                        text: mainInstance ? mainInstance.lastError : ""
                        color: Color.mError
                        pointSize: Style.fontSizeXS
                        elide: Text.ElideRight
                    }
                    NButton {
                        icon: "x"
                        onClicked: if (mainInstance) mainInstance.clearError()
                    }
                }
            }

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginS

                NIcon {
                    icon: "server"
                    pointSize: Style.fontSizeL
                    color: Color.mPrimary
                }

                NText {
                    text: pluginApi?.tr("panel.title") || "Quickemu Manager"
                    color: Color.mOnSurface
                    pointSize: Style.fontSizeL
                    font.weight: Style.fontWeightBold
                    Layout.fillWidth: true
                }

                NButton {
                    icon: "refresh-cw"
                    text: pluginApi?.tr("panel.refresh") || "Refresh"
                    onClicked: {
                        if (mainInstance) mainInstance.refreshVmList();
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.alpha(Color.mOnSurface, 0.1)
            }

            // Existing VMs section header
            NText {
                text: pluginApi?.tr("panel.existing-vms") || "Existing VMs"
                color: Color.mPrimary
                pointSize: Style.fontSizeM
                font.weight: Style.fontWeightBold
            }

            // VM List
            NBox {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: vmList
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    model: mainInstance ? mainInstance.vmListModel : null
                    clip: true
                    spacing: Style.marginS

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: delegateRow.implicitHeight + Style.marginS * 2
                        color: delegateMouseArea.containsMouse ? Qt.alpha(Color.mPrimary, 0.1) : Color.mSurfaceVariant
                        radius: Style.radiusM
                        border.width: delegateMouseArea.containsMouse ? 1 : 0
                        border.color: Qt.alpha(Color.mPrimary, 0.3)

                        MouseArea {
                            id: delegateMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }

                        RowLayout {
                            id: delegateRow
                            anchors.fill: parent
                            anchors.margins: Style.marginS
                            spacing: Style.marginS

                            NText {
                                text: model.vmName
                                color: Color.mOnSurface
                                pointSize: Style.fontSizeS
                                font.weight: Style.fontWeightMedium
                                Layout.fillWidth: true
                            }

                            NButton {
                                text: pluginApi?.tr("panel.start") || "Start"
                                icon: "play"
                                backgroundColor: Color.mPrimary
                                textColor: Color.mOnPrimary
                                onClicked: {
                                    if (mainInstance) mainInstance.startVm(model.vmName);
                                }
                            }
                            NButton {
                                text: pluginApi?.tr("panel.edit") || "Edit"
                                icon: "edit-2"
                                onClicked: {
                                    if (mainInstance) mainInstance.editVm(model.vmName);
                                }
                            }
                            NButton {
                                text: pluginApi?.tr("panel.delete") || "Delete"
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
                        text: pluginApi?.tr("panel.no-vms") || "No VMs found."
                        color: Color.mOnSurfaceVariant
                        visible: vmList.count === 0
                        pointSize: Style.fontSizeS
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.alpha(Color.mOnSurface, 0.1)
            }

            // Create New VM section
            NText {
                text: pluginApi?.tr("panel.create-vm") || "Create New VM"
                color: Color.mPrimary
                pointSize: Style.fontSizeM
                font.weight: Style.fontWeightBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.marginM

                ComboBox {
                    id: osComboBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: Style.capsuleHeight
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
                        border.color: osComboBox.activeFocus ? Color.mPrimary : Qt.alpha(Color.mOnSurface, 0.1)
                        border.width: Style.borderWidth || 1
                    }
                    contentItem: TextField {
                        text: osComboBox.editText
                        color: Color.mOnSurface
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: Style.marginS
                        font.pixelSize: Style.fontSizeS * Style.uiScaleRatio
                        placeholderText: pluginApi?.tr("panel.search-os") || "Search OS..."
                        placeholderTextColor: Color.mOnSurfaceVariant
                        background: Item {}
                        onTextChanged: osComboBox.editText = text
                    }
                }

                NButton {
                    text: pluginApi?.tr("panel.download") || "Download"
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
                Layout.preferredHeight: Style.marginL
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

                    Behavior on width {
                        NumberAnimation { duration: 150 }
                    }
                }
                NText {
                    anchors.centerIn: parent
                    text: mainInstance ? Math.round(mainInstance.downloadProgress * 100) + "%" : "0%"
                    color: Color.mOnPrimary
                    pointSize: Style.fontSizeXS
                    font.weight: Style.fontWeightBold
                }
            }
        }
    }
}
