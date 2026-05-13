import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var pluginApi: null

    // Use settings or default
    readonly property string vmDirectory: pluginApi?.pluginSettings?.vmDirectory || "/home/ness/quickemu/"

    property real downloadProgress: 0.0

    // Models
    ListModel { id: _vmListModel }
    property alias vmListModel: _vmListModel

    ListModel { id: _osListModel }
    property alias osListModel: _osListModel

    // Processes
    Process {
        id: listProcess
        command: ["sh", "-c", "echo noop"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (str.length > 0) {
                    _vmListModel.append({ "vmName": str });
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                console.log("[QuickemuManager] VM list refreshed — " + _vmListModel.count + " VMs found");
            }
        }
    }

    Process {
        id: startProcess
        command: ["sh", "-c", "echo noop"]
        running: false
        stdout: SplitParser { onRead: data => console.log("[quickemu] " + data) }
        stderr: SplitParser { onRead: data => console.log("[quickemu ERR] " + data) }
    }

    Process {
        id: editProcess
        command: ["sh", "-c", "echo noop"]
        running: false
    }

    Process {
        id: deleteProcess
        command: ["sh", "-c", "echo noop"]
        running: false
        onRunningChanged: {
            if (!running) {
                refreshVmList();
            }
        }
    }

    Process {
        id: createProcess
        command: ["sh", "-c", "echo noop"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                var match = str.match(/([0-9.]+)\s*%/);
                if (match) {
                    root.downloadProgress = parseFloat(match[1]) / 100.0;
                } else if (str.length > 0) {
                    console.log("[quickget] " + str);
                }
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.log("[quickget ERR] " + data);
            }
        }
        onRunningChanged: {
            if (!running) {
                console.log("[QuickemuManager] quickget finished");
                root.downloadProgress = 0.0;
                refreshVmList();
            }
        }
    }

    Process {
        id: listOsProcess
        command: ["sh", "-c", "quickget --list | awk -F',' '{if (NR>1) print $1 \" \" $2}'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (str.length > 0) {
                    _osListModel.append({ "osName": str });
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                console.log("[QuickemuManager] OS list populated with " + _osListModel.count + " options.");
            }
        }
    }

    // Functions
    function refreshVmList() {
        _vmListModel.clear();
        listProcess.running = false;
        listProcess.command = ["sh", "-c", "ls -1 " + root.vmDirectory + "*.conf 2>/dev/null | xargs -I{} basename {} .conf"];
        listProcess.running = true;
    }

    function startVm(name) {
        var confPath = root.vmDirectory + name + ".conf";
        startProcess.command = ["quickemu", "--vm", confPath];
        startProcess.running = false;
        startProcess.running = true;
        console.log("[QuickemuManager] Starting VM: " + name);
    }

    function editVm(name) {
        var confPath = root.vmDirectory + name + ".conf";
        var cmd = "editor=$(xdg-mime query default text/plain | sed 's/.desktop//'); " +
                  "if [ -n \"$editor\" ]; then gtk-launch \"$editor\" \"" + confPath + "\"; " +
                  "else xdg-open \"" + confPath + "\"; fi";
        editProcess.command = ["sh", "-c", cmd];
        editProcess.running = false;
        editProcess.running = true;
        console.log("[QuickemuManager] Editing VM config: " + confPath);
        // Optionally close panel via IPC or let user click away
    }

    function deleteVm(name) {
        var confFile = root.vmDirectory + name + ".conf";
        var vmDir   = root.vmDirectory + name + "/";
        deleteProcess.command = ["sh", "-c", "rm -rf " + confFile + " " + vmDir];
        deleteProcess.running = false;
        deleteProcess.running = true;
        console.log("[QuickemuManager] Deleting VM: " + name);
    }

    function createVm(osArgs) {
        root.downloadProgress = 0.0;
        createProcess.command = ["sh", "-c", "cd " + root.vmDirectory + " && quickget " + osArgs + " | tr '\\r' '\\n'"];
        createProcess.running = false;
        createProcess.running = true;
        console.log("[QuickemuManager] Creating VM: " + osArgs);
    }

    Component.onCompleted: {
        refreshVmList();
        listOsProcess.running = true;
    }
}
