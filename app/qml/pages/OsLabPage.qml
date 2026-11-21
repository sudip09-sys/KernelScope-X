pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

PageScroll {
    id: root
    property string algorithm: "FCFS"
    property var result: ({})
    property bool outdated: false
    property int zoom: 1
    readonly property bool hasResult: (result.totalTime || 0) > 0
    readonly property var resultRows: result.rows || []
    readonly property var segmentColors: ["#7abafb", "#77d8be", "#efb971", "#c5a2f5", "#ef99a7", "#beda83"]

    ListModel {
        id: jobs
        ListElement { jobName: "P1"; arrival: 0; burst: 8 }
        ListElement { jobName: "P2"; arrival: 1; burst: 4 }
        ListElement { jobName: "P3"; arrival: 2; burst: 9 }
        ListElement { jobName: "P4"; arrival: 3; burst: 5 }
    }

    function csv() {
        const lines = []
        for (let i = 0; i < jobs.count; ++i) {
            const job = jobs.get(i)
            lines.push([job.jobName, job.arrival, job.burst].join(","))
        }
        return lines.join("\n")
    }

    function run() {
        result = scheduler.simulate(csv(), algorithm, quantum.value)
        outdated = false
        zoom = 1
        timeline.contentX = 0
    }

    function loadCsv() {
        const parsed = scheduler.simulate(csvInput.text, algorithm, quantum.value)
        if (parsed.error) {
            csvDialog.errorMessage = parsed.error
            return
        }
        jobs.clear()
        for (const job of parsed.rows)
            jobs.append({ jobName: job.name, arrival: job.arrival, burst: job.burst })
        outdated = true
        csvDialog.close()
    }

    function colorFor(index) {
        return segmentColors[index % segmentColors.length]
    }

    Component.onCompleted: run()

    ColumnLayout {
        width: root.availableWidth
        spacing: 11

        SectionHeader {
            Layout.fillWidth: true
            heading: "CPU scheduling lab"
            subheading: "Build a simulated workload and inspect its execution timeline"
        }

        GridLayout {
            Layout.fillWidth: true
            columns: width < 755 ? 1 : 2
            columnSpacing: 10
            rowSpacing: 10

            Rectangle {
                Layout.fillWidth: parent.columns === 1
                Layout.preferredWidth: 205
                Layout.preferredHeight: algorithms.implicitHeight + 24
                Layout.alignment: Qt.AlignTop
                radius: 6
                color: "#20242b"
                border.color: "#343c48"

                ColumnLayout {
                    id: algorithms
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12
                    spacing: 6

                    Label { text: "Algorithm"; font.pixelSize: 16; font.weight: Font.DemiBold }
                    Repeater {
                        model: [
                            { code: "FCFS", name: "First Come, First Served" },
                            { code: "SJF", name: "Shortest Job First" },
                            { code: "RR", name: "Round Robin" }
                        ]
                        delegate: ItemDelegate {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 34
                            text: modelData.name
                            highlighted: root.algorithm === modelData.code
                            onClicked: {
                                if (root.algorithm !== modelData.code) {
                                    root.algorithm = modelData.code
                                    root.outdated = true
                                }
                            }
                        }
                    }

                    RowLayout {
                        visible: root.algorithm === "RR"
                        Layout.fillWidth: true
                        Label { text: "Quantum"; Layout.fillWidth: true }
                        SpinBox {
                            id: quantum
                            from: 1
                            to: 1000
                            value: 3
                            Accessible.name: "Round Robin quantum"
                            onValueModified: root.outdated = true
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 262
                radius: 6
                color: "#20242b"
                border.color: "#343c48"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 7

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: "Workload"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                        }
                        Button {
                            text: "Edit CSV"
                            onClicked: {
                                csvInput.text = root.csv()
                                csvDialog.errorMessage = ""
                                csvDialog.open()
                            }
                        }
                        Button {
                            text: "Add process"
                            enabled: jobs.count < 24
                            onClicked: {
                                jobs.append({ jobName: "", arrival: 0, burst: 1 })
                                root.outdated = true
                                workload.positionViewAtEnd()
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.rightMargin: 9
                        spacing: 8
                        Label { text: "Process"; Layout.fillWidth: true; color: "#a4afbe" }
                        Label { text: "Arrival"; Layout.preferredWidth: 108; color: "#a4afbe" }
                        Label { text: "Burst"; Layout.preferredWidth: 108; color: "#a4afbe" }
                        Item { Layout.preferredWidth: 32 }
                    }
                    ListView {
                        id: workload
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: jobs
                        clip: true
                        spacing: 3
                        ScrollBar.vertical: ScrollBar {}

                        delegate: RowLayout {
                            id: jobRow
                            required property int index
                            required property string jobName
                            required property int arrival
                            required property int burst
                            width: workload.width - 9
                            height: 30
                            spacing: 8

                            TextField {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Accessible.name: "Process name"
                                placeholderText: "Process name"
                                text: jobRow.jobName
                                maximumLength: 20
                                validator: RegularExpressionValidator { regularExpression: /[^,#]*/ }
                                onTextEdited: {
                                    jobs.setProperty(jobRow.index, "jobName", text)
                                    root.outdated = true
                                }
                            }
                            SpinBox {
                                Layout.preferredWidth: 108
                                Layout.fillHeight: true
                                Accessible.name: "Arrival time"
                                from: 0
                                to: 1000
                                value: jobRow.arrival
                                editable: true
                                onValueModified: {
                                    jobs.setProperty(jobRow.index, "arrival", value)
                                    root.outdated = true
                                }
                            }
                            SpinBox {
                                Layout.preferredWidth: 108
                                Layout.fillHeight: true
                                Accessible.name: "Burst time"
                                from: 1
                                to: 1000
                                value: jobRow.burst
                                editable: true
                                onValueModified: {
                                    jobs.setProperty(jobRow.index, "burst", value)
                                    root.outdated = true
                                }
                            }
                            Button {
                                Layout.preferredWidth: 32
                                Layout.fillHeight: true
                                text: "×"
                                Accessible.name: "Remove process " + jobRow.jobName
                                onClicked: {
                                    jobs.remove(jobRow.index)
                                    root.outdated = true
                                }
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: root.result.error || (root.outdated ? "Run again to update the results." : "")
                            wrapMode: Text.WordWrap
                            color: root.result.error ? "#eab476" : "#a4afbe"
                        }
                        Button {
                            text: "Run simulation"
                            highlighted: true
                            onClicked: root.run()
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: timelineContent.implicitHeight + 24
            radius: 6
            color: "#20242b"
            border.color: "#343c48"

            ColumnLayout {
                id: timelineContent
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: "Execution timeline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }
                    Label {
                        visible: root.hasResult
                        text: root.result.algorithm + " · " + root.result.totalTime + " time units"
                        color: "#a4afbe"
                    }
                    Button {
                        text: "−"
                        Accessible.name: "Zoom out"
                        enabled: root.hasResult && root.zoom > 1
                        onClicked: root.zoom -= 1
                    }
                    Button {
                        text: "+"
                        Accessible.name: "Zoom in"
                        enabled: root.hasResult && root.zoom < 3
                        onClicked: root.zoom += 1
                    }
                }
                Flow {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: root.resultRows
                        delegate: Row {
                            id: legend
                            required property int index
                            required property var modelData
                            spacing: 5
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 9
                                height: 9
                                radius: 2
                                color: root.colorFor(legend.index)
                            }
                            Label {
                                text: legend.modelData.name
                                textFormat: Text.PlainText
                                color: "#cbd5e1"
                            }
                        }
                    }
                    Label {
                        visible: root.hasResult && root.result.totalTime > root.result.totalBurst
                        text: "Idle · " + (root.result.totalTime - root.result.totalBurst) + " units"
                        color: "#a4afbe"
                    }
                }
                Flickable {
                    id: timeline
                    Layout.fillWidth: true
                    Layout.preferredHeight: 94
                    contentWidth: width * root.zoom
                    contentHeight: height
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.HorizontalFlick
                    clip: true
                    ScrollBar.horizontal: ScrollBar {}

                    Canvas {
                        id: chart
                        width: timeline.contentWidth
                        height: timeline.height - 9
                        property var schedule: root.result
                        onScheduleChanged: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            const duration = schedule.totalTime || 0
                            if (duration === 0 || width <= 24)
                                return

                            const scale = (width - 24) / duration
                            const xAt = time => 12 + time * scale
                            const colors = new Map(schedule.rows.map((row, i) => [row.name, root.colorFor(i)]))
                            ctx.font = "11px Consolas"
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle"
                            ctx.fillStyle = "#171a20"
                            ctx.fillRect(0, 0, width, height)

                            const tickStep = Math.max(1, Math.ceil(duration / Math.max(1, Math.floor(width / 64))))
                            ctx.lineWidth = 1
                            for (let t = 0; t < duration; t += tickStep) {
                                if (t !== 0 && (duration - t) * scale < 24)
                                    break
                                const x = xAt(t)
                                ctx.strokeStyle = "#343c48"
                                ctx.beginPath()
                                ctx.moveTo(x, 6)
                                ctx.lineTo(x, 57)
                                ctx.stroke()
                                ctx.fillStyle = "#a4afbe"
                                ctx.fillText(String(t), x, 71)
                            }
                            ctx.fillStyle = "#a4afbe"
                            ctx.textAlign = "right"
                            ctx.fillText(String(duration), xAt(duration) + 8, 71)
                            ctx.textAlign = "center"

                            for (const segment of schedule.segments) {
                                const x = xAt(segment.start)
                                const length = segment.duration * scale
                                ctx.fillStyle = segment.idle ? "#3b4655" : colors.get(segment.name)
                                ctx.fillRect(x, 15, length, 34)
                                if (length >= ctx.measureText(segment.name).width + 8) {
                                    ctx.fillStyle = segment.idle ? "#eef1f5" : "#17202c"
                                    ctx.fillText(segment.name, x + length / 2, 32)
                                }
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MetricCard {
                Layout.fillWidth: true
                caption: "Average waiting"
                value: root.hasResult ? Number(root.result.avgWaiting).toFixed(2) : "—"
                subtitle: "Time units"
            }
            MetricCard {
                Layout.fillWidth: true
                caption: "Average turnaround"
                value: root.hasResult ? Number(root.result.avgTurnaround).toFixed(2) : "—"
                subtitle: "Time units"
                accent: "#c5a2f5"
            }
            MetricCard {
                Layout.fillWidth: true
                caption: "Average response"
                value: root.hasResult ? Number(root.result.avgResponse).toFixed(2) : "—"
                subtitle: "Time units"
                accent: "#77d8be"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 228
            radius: 6
            color: "#20242b"
            border.color: "#343c48"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 5

                Label { text: "Per-process results"; font.pixelSize: 16; font.weight: Font.DemiBold }
                Row {
                    Layout.fillWidth: true
                    Layout.rightMargin: 9
                    Repeater {
                        model: ["Process", "Arrival", "Burst", "Finish", "Turnaround", "Wait", "Response"]
                        delegate: Label {
                            required property string modelData
                            text: modelData
                            width: parent.width / 7
                            color: "#a4afbe"
                        }
                    }
                }
                ListView {
                    id: results
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.resultRows
                    clip: true
                    ScrollBar.vertical: ScrollBar {}

                    delegate: Rectangle {
                        id: resultRow
                        required property int index
                        required property var modelData
                        width: results.width - 9
                        height: 30
                        color: index % 2 ? "transparent" : "#272e38"

                        Row {
                            anchors.fill: parent
                            Repeater {
                                model: [
                                    resultRow.modelData.name, resultRow.modelData.arrival,
                                    resultRow.modelData.burst, resultRow.modelData.completion,
                                    resultRow.modelData.turnaround, resultRow.modelData.waiting,
                                    resultRow.modelData.response
                                ]
                                delegate: Label {
                                    required property var modelData
                                    width: parent.width / 7
                                    height: parent.height
                                    text: modelData
                                    textFormat: Text.PlainText
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    font.family: "Consolas"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: csvDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(490, parent.width - 32)
        title: "Edit workload as CSV"
        modal: true
        standardButtons: Dialog.Cancel
        property string errorMessage: ""

        contentItem: ColumnLayout {
            Label { text: "One process per line: name, arrival, burst" }
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                clip: true
                TextArea {
                    id: csvInput
                    font.family: "Consolas"
                    wrapMode: TextEdit.Wrap
                }
            }
            Label {
                Layout.fillWidth: true
                text: csvDialog.errorMessage
                visible: text.length > 0
                color: "#eab476"
                wrapMode: Text.WordWrap
            }
            Button {
                text: "Apply workload"
                highlighted: true
                onClicked: root.loadCsv()
            }
        }
    }
}
