import qs.modules.common
import qs
import qs.services
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: quickFileRoot

    property int editingSlot: -1  // Which slot is being edited

    Loader {
        id: quickFileLoader
        active: GlobalStates.quickFileOpen

        Connections {
            target: GlobalStates
            function onScreenLockedChanged() {
                if (GlobalStates.screenLocked) {
                    GlobalStates.quickFileOpen = false;
                }
            }
        }

        sourceComponent: PanelWindow {
            id: quickFileWindow
            visible: quickFileLoader.active

            function hide() {
                GlobalStates.quickFileOpen = false;
            }

    // Add this at PanelWindow level
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            quickFileWindow.hide();
            event.accepted = true;
        }
    }
      Shortcut {
        sequence: "Escape"
        onActivated: quickFileWindow.hide()
    }
    exclusionMode: ExclusionMode.Ignore

            WlrLayershell.namespace: "quickshell:quickfile"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: ColorUtils.transparentize(Appearance.m3colors.m3background, 0.3)

            property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)

            anchors {
                top: true
                left: true
                right: true
            }

            implicitWidth: focusedScreen?.width ?? 0
            implicitHeight: focusedScreen?.height ?? 0

            MouseArea {
                id: quickFileMouseArea
                anchors.fill: parent
                onClicked: {
                    quickFileWindow.hide()
                }
            }

            ColumnLayout {
                id: contentColumn
                anchors.centerIn: parent
                spacing: 15

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        quickFileWindow.hide();
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 5

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Appearance.font.family.title
                        font.pixelSize: Appearance.font.pixelSize.title
                        font.weight: Font.DemiBold
                        text: Translation.tr("Quick File")
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Appearance.font.pixelSize.normal
                        text: Translation.tr("Left click to open, Right click to set folder\nEsc or click anywhere to cancel")
                    }
                }

                GridLayout {
                    id: buttonsGrid
                    Layout.alignment: Qt.AlignHCenter
                    columns: 3
                    rowSpacing: 20
                    columnSpacing: 20

                    Repeater {
    model: 6
    
    QuickFileButton {
        id: slotButton
        required property int index
        
        focus: index === 0  // First button gets focus
        
        property string slotPath: {
            switch(index) {
                case 0: return GlobalStates.quickFilePath1;
                case 1: return GlobalStates.quickFilePath2;
                case 2: return GlobalStates.quickFilePath3;
                case 3: return GlobalStates.quickFilePath4;
                case 4: return GlobalStates.quickFilePath5;
                case 5: return GlobalStates.quickFilePath6;
                default: return "";
            }
        }
        
        property string folderName: {
            if (slotPath === "") return "Slot " + (index + 1);
            var parts = slotPath.split("/");
            return parts[parts.length - 1] || parts[parts.length - 2] || "Folder";
        }
        
        buttonIcon: slotPath !== "" ? "folder" : "add"
        buttonText: folderName
        opacity: slotPath !== "" ? 1.0 : 0.6
        
        onClicked: {
            if (slotPath !== "") {
                Quickshell.execDetached(["dolphin", slotPath]);
                GlobalStates.quickFileOpen = false;
            }
        }
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true  // Let button keep focus
            onClicked: {
                quickFileRoot.editingSlot = index;
                quickFileWindow.hide();
                folderPicker.open();
            }
        }
        
        // Manual navigation since Repeater indexing is tricky
        KeyNavigation.right: {
            var nextIdx = index + 1;
            return nextIdx % 3 !== 0 && nextIdx < 6 ? buttonsGrid.children[nextIdx] : slotButton;
        }
        KeyNavigation.left: {
            var prevIdx = index - 1;
            return prevIdx >= 0 && index % 3 !== 0 ? buttonsGrid.children[prevIdx] : slotButton;
        }
        KeyNavigation.down: {
            var downIdx = index + 3;
            return downIdx < 6 ? buttonsGrid.children[downIdx] : slotButton;
        }
        KeyNavigation.up: {
            var upIdx = index - 3;
            return upIdx >= 0 ? buttonsGrid.children[upIdx] : slotButton;
        }
    }
}
                }
            }
        }
    }

    FolderDialog {
        id: folderPicker
        onAccepted: {
            var path = selectedFolder.toString().replace("file://", "");

            switch(quickFileRoot.editingSlot) {
                case 0: GlobalStates.quickFilePath1 = path; break;
                case 1: GlobalStates.quickFilePath2 = path; break;
                case 2: GlobalStates.quickFilePath3 = path; break;
                case 3: GlobalStates.quickFilePath4 = path; break;
                case 4: GlobalStates.quickFilePath5 = path; break;
                case 5: GlobalStates.quickFilePath6 = path; break;
            }

            quickFileRoot.editingSlot = -1;
        }
        onRejected: {
            quickFileRoot.editingSlot = -1;
        }
    }

    IpcHandler {
        target: "quickfile"

        function toggle(): void {
            GlobalStates.quickFileOpen = !GlobalStates.quickFileOpen;
        }

        function close(): void {
            GlobalStates.quickFileOpen = false;
        }

        function open(): void {
            GlobalStates.quickFileOpen = true;
        }
    }

    GlobalShortcut {
        name: "quickfileToggle"
        description: "Toggles Quick File menu on press"

        onPressed: {
            GlobalStates.quickFileOpen = !GlobalStates.quickFileOpen;
        }
    }

    GlobalShortcut {
        name: "quickfileOpen"
        description: "Opens Quick File menu on press"

        onPressed: {
            GlobalStates.quickFileOpen = true;
        }
    }

    GlobalShortcut {
        name: "quickfileClose"
        description: "Closes Quick File menu on press"

        onPressed: {
            GlobalStates.quickFileOpen = false;
        }
    }
}
