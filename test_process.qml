import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Process {
        id: proc
        command: ["echo", "test"]
    }
    Component.onCompleted: {
        console.log(Object.keys(proc));
        Quickshell.exit(0);
    }
}
