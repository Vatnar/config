import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

RippleButton {
    id: button

    property string buttonIcon
    property string buttonText
    property bool keyboardDown: false
    property real size: 120

    buttonRadius: (button.focus || button.down) ? size / 2 : Appearance.rounding.verylarge
    colBackground: button.keyboardDown ? Appearance.colors.colSecondaryContainerActive : 
        button.focus ? Appearance.colors.colPrimary : 
        Appearance.colors.colSecondaryContainer
    colBackgroundHover: Appearance.colors.colPrimary
    colRipple: Appearance.colors.colPrimaryActive
    property color colText: (button.down || button.keyboardDown || button.focus || button.hovered) ?
        Appearance.m3colors.m3onPrimary : Appearance.colors.colOnLayer0

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    background.implicitHeight: size
    background.implicitWidth: size

    Behavior on buttonRadius {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
            button.keyboardDown = true;
            button.clicked();
        }
    }

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
            button.keyboardDown = false;
        }
    }

    contentItem: ColumnLayout {
        spacing: 5

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredHeight: 45
            Layout.preferredWidth: 45
            color: button.colText
            horizontalAlignment: Text.AlignHCenter
            iconSize: 32
            text: button.buttonIcon
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            text: button.buttonText
            font.pixelSize: Appearance.font.pixelSize.small
            horizontalAlignment: Text.AlignHCenter
            color: button.colText
        }
    }
}
