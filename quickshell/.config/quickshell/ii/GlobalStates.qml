import qs.modules.common
import qs
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtCore
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool barOpen: true
    property bool sidebarLeftOpen: false
    property bool sidebarRightOpen: false
    property bool mediaControlsOpen: false
    property bool osdBrightnessOpen: false
    property bool osdVolumeOpen: false
    property bool oskOpen: false
    property bool overviewOpen: false
    property bool screenLocked: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
    property bool sessionOpen: false
    property bool quickFileOpen: false
    property string quickFilePath1: ""
    property string quickFilePath2: ""
    property string quickFilePath3: ""
    property string quickFilePath4: ""
    property string quickFilePath5: ""
    property string quickFilePath6: ""
    property bool superDown: false
    property bool superReleaseMightTrigger: true
    property bool workspaceShowNumbers: false

    property real screenZoom: 1
    onScreenZoomChanged: {
        Quickshell.execDetached(["hyprctl", "keyword", "cursor:zoom_factor", root.screenZoom.toString()]);
    }
    Behavior on screenZoom {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            root.superDown = true
        }
        onReleased: {
            root.superDown = false
        }
    }

    IpcHandler {
		target: "zoom"

		function zoomIn() {
            screenZoom = Math.min(screenZoom + 0.4, 3.0)
        }

        function zoomOut() {
            screenZoom = Math.max(screenZoom - 0.4, 1)
        } 
	}
    IpcHandler {
        target: "quickfile"

        function toggle() {
            root.quickFileOpen = !root.quickFileOpen
        }
    }
    Settings {
    id: quickFileSettings
    category: "quickfile"
    
    property alias path1: root.quickFilePath1
    property alias path2: root.quickFilePath2
    property alias path3: root.quickFilePath3
    property alias path4: root.quickFilePath4
    property alias path5: root.quickFilePath5
    property alias path6: root.quickFilePath6
}
}

