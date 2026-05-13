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

    property real contentPreferredWidth: 600 * Style.uiScaleRatio
    property real contentPreferredHeight: 650 * Style.uiScaleRatio

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
                    text: pluginApi?.tr("panel.title")
                    color: Color.mOnSurface
                    pointSize: Style.fontSizeL
                    font.weight: Style.fontWeightBold
                    Layout.fillWidth: true
                }

                NButton {
                    icon: "refresh-cw"
                    text: pluginApi?.tr("panel.refresh")
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
                text: pluginApi?.tr("panel.existing-vms")
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
                                text: pluginApi?.tr("panel.start")
                                icon: "play"
                                backgroundColor: Color.mPrimary
                                textColor: Color.mOnPrimary
                                onClicked: {
                                    if (mainInstance) mainInstance.startVm(model.vmName);
                                }
                            }
                            NButton {
                                text: pluginApi?.tr("panel.edit")
                                icon: "edit-2"
                                onClicked: {
                                    if (mainInstance) mainInstance.editVm(model.vmName);
                                }
                            }
                            NButton {
                                text: pluginApi?.tr("panel.delete")
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
                        text: pluginApi?.tr("panel.no-vms")
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
                text: pluginApi?.tr("panel.create-vm")
                color: Color.mPrimary
                pointSize: Style.fontSizeM
                font.weight: Style.fontWeightBold
            }

            // Category Sidebar + OS ComboBox
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                spacing: Style.marginS

                // Sidebar with OS categories
                NBox {
                    Layout.preferredWidth: 140 * Style.uiScaleRatio
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Style.marginXS
                        spacing: 0

                        // "All" button at the top
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 28
                            color: (mainInstance && mainInstance.selectedCategory === "") ? Qt.alpha(Color.mPrimary, 0.2) : "transparent"
                            radius: Style.radiusS

                            NText {
                                anchors.centerIn: parent
                                text: pluginApi?.tr("panel.all-categories")
                                pointSize: Style.fontSizeXS
                                font.weight: Style.fontWeightBold
                                color: (mainInstance && mainInstance.selectedCategory === "") ? Color.mPrimary : Color.mOnSurfaceVariant
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (mainInstance) mainInstance.clearCategoryFilter();
                                }
                            }
                        }

                        // Scrollable category list
                        ListView {
                            id: categoryList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: mainInstance ? mainInstance.osCategoryList : null
                            spacing: 2

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 26
                                color: catMouse.containsMouse ? Qt.alpha(Color.mPrimary, 0.1)
                                     : (mainInstance && mainInstance.selectedCategory === model.category) ? Qt.alpha(Color.mPrimary, 0.15)
                                     : "transparent"
                                radius: Style.radiusS

                                NText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: Style.marginS
                                    anchors.right: parent.right
                                    anchors.rightMargin: Style.marginXS
                                    text: model.category
                                    pointSize: Style.fontSizeXS
                                    color: (mainInstance && mainInstance.selectedCategory === model.category) ? Color.mPrimary : Color.mOnSurface
                                    font.weight: (mainInstance && mainInstance.selectedCategory === model.category) ? Style.fontWeightBold : Style.fontWeightMedium
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    id: catMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (mainInstance) mainInstance.filterByCategory(model.category);
                                    }
                                }
                            }
                        }
                    }
                }

                // Right side: search + download
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Style.marginS

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
                            placeholderText: pluginApi?.tr("panel.search-os")
                            placeholderTextColor: Color.mOnSurfaceVariant
                            background: Item {}
                            onTextChanged: osComboBox.editText = text
                        }
                    }

                    NText {
                        visible: mainInstance && mainInstance.selectedCategory !== ""
                        text: pluginApi?.tr("panel.category") + ": " + (mainInstance ? mainInstance.selectedCategory : "")
                        pointSize: Style.fontSizeXS
                        color: Color.mPrimary
                    }

                    Item { Layout.fillHeight: true }

                    NButton {
                        Layout.fillWidth: true
                        text: pluginApi?.tr("panel.download")
                        icon: "download"
                        backgroundColor: Color.mPrimary
                        textColor: Color.mOnPrimary
                        enabled: osComboBox.editText !== "" && (!mainInstance || !mainInstance.isDownloading)
                        onClicked: {
                            if (mainInstance && osComboBox.editText) {
                                mainInstance.createVm(osComboBox.editText);
                            }
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

        // Download overlay - blocks all interaction during download
        Rectangle {
            id: downloadOverlay
            anchors.fill: parent
            color: Qt.alpha(Color.mSurface, 0.85)
            visible: mainInstance && mainInstance.isDownloading
            z: 100

            // Block all mouse clicks
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Style.marginL

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    running: downloadOverlay.visible
                    palette.dark: Color.mPrimary
                }

                NText {
                    Layout.alignment: Qt.AlignHCenter
                    text: pluginApi?.tr("panel.downloading")
                    color: Color.mOnSurface
                    pointSize: Style.fontSizeM
                    font.weight: Style.fontWeightBold
                }

                // Inline progress bar inside overlay
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 250 * Style.uiScaleRatio
                    Layout.preferredHeight: Style.marginL

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

                NText {
                    Layout.alignment: Qt.AlignHCenter
                    text: pluginApi?.tr("panel.download-wait")
                    color: Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeXS
                }
            }
        }
    }
}
