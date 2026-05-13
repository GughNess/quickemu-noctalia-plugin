import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var pluginApi: null

    // Use settings or default
    readonly property string vmDirectory: pluginApi?.pluginSettings?.vmDirectory || "~/quickemu/"
    readonly property string homeDir: Quickshell.env("HOME") || ""
    readonly property string resolvedVmDirectory: vmDirectory.replace("~", homeDir)

    property real downloadProgress: 0.0
    property string lastError: ""

    // Models
    ListModel { id: _vmListModel }
    property alias vmListModel: _vmListModel

    ListModel { id: _osListModel }
    property alias osListModel: _osListModel

    ListModel { id: _filteredOsListModel }
    property alias filteredOsListModel: _filteredOsListModel

    // Processes
    Process {
        id: listProcess
        command: ["find", root.resolvedVmDirectory, "-maxdepth", "1", "-name", "*.conf", "-exec", "basename", "-s", ".conf", "{}", ";"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (str.length > 0) {
                    _vmListModel.append({ "vmName": str });
                }
            }
        }
        stderr: SplitParser { onRead: data => root.lastError = data }
        onRunningChanged: {
            if (!running) {
                console.log("[QuickemuManager] VM list refreshed — " + _vmListModel.count + " VMs found");
            }
        }
    }

    Process {
        id: startProcess
        command: []
        running: false
        stdout: SplitParser { onRead: data => console.log("[quickemu] " + data) }
        stderr: SplitParser { onRead: data => root.lastError = data }
    }

    Process {
        id: editProcess
        command: []
        running: false
        stderr: SplitParser { onRead: data => root.lastError = data }
    }

    Process {
        id: deleteProcess
        command: []
        running: false
        stderr: SplitParser { onRead: data => root.lastError = data }
        onRunningChanged: {
            if (!running) {
                refreshVmList();
            }
        }
    }

    Process {
        id: createProcess
        command: []
        workingDirectory: root.resolvedVmDirectory
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
                root.lastError = data;
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
                    _filteredOsListModel.append({ "osName": str });
                }
            }
        }
        stderr: SplitParser { onRead: data => console.log("[quickget list ERR] " + data) }
        onRunningChanged: {
            if (!running) {
                console.log("[QuickemuManager] OS list populated with " + _osListModel.count + " options.");
            }
        }
    }

    // Functions
    function updateFilteredOsList(query) {
        _filteredOsListModel.clear();
        var q = query.toLowerCase();
        for (var i = 0; i < _osListModel.count; ++i) {
            var name = _osListModel.get(i).osName;
            if (name.toLowerCase().indexOf(q) !== -1) {
                _filteredOsListModel.append({ "osName": name });
            }
        }
    }

    function clearError() {
        root.lastError = "";
    }

    function refreshVmList() {
        clearError();
        _vmListModel.clear();
        listProcess.running = false;
        listProcess.running = true;
    }

    function startVm(name) {
        clearError();
        var confPath = root.resolvedVmDirectory + name + ".conf";
        startProcess.command = ["quickemu", "--vm", confPath];
        startProcess.running = false;
        startProcess.running = true;
        console.log("[QuickemuManager] Starting VM: " + name);
    }

    function editVm(name) {
        clearError();
        var confPath = root.resolvedVmDirectory + name + ".conf";
        // Safely pass the path as a shell argument $1
        editProcess.command = ["sh", "-c", "editor=$(xdg-mime query default text/plain | sed 's/.desktop//'); if [ -n \"$editor\" ]; then gtk-launch \"$editor\" \"$1\"; else xdg-open \"$1\"; fi", "--", confPath];
        editProcess.running = false;
        editProcess.running = true;
        console.log("[QuickemuManager] Editing VM config: " + confPath);
    }

    function deleteVm(name) {
        clearError();
        var confFile = root.resolvedVmDirectory + name + ".conf";
        var vmDir    = root.resolvedVmDirectory + name;
        deleteProcess.command = ["rm", "-rf", confFile, vmDir];
        deleteProcess.running = false;
        deleteProcess.running = true;
        console.log("[QuickemuManager] Deleting VM: " + name);
    }

    function createVm(osArgs) {
        clearError();
        root.downloadProgress = 0.0;
        // Run quickget safely, parsing the space-separated osArgs as $1
        createProcess.command = ["sh", "-c", "quickget $1 | tr '\\r' '\\n'", "--", osArgs];
        createProcess.running = false;
        createProcess.running = true;
        console.log("[QuickemuManager] Creating VM: " + osArgs);
    }

    Component.onCompleted: {
        refreshVmList();
        listOsProcess.running = true;
    }
}
