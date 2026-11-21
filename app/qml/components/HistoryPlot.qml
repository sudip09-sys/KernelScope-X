import QtQuick

Canvas {
    id: plot
    property var samples: []
    property color lineColor: "#7abafb"
    property bool compact: false
    property real maximum: 100

    onSamplesChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onMaximumChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        const left = compact ? 1 : 30
        const right = width - 2
        const top = compact ? 2 : 9
        const bottom = height - (compact ? 1 : 9)
        if (left >= right || top >= bottom)
            return

        ctx.lineWidth = 1
        ctx.font = "11px Consolas"
        ctx.textAlign = "right"
        ctx.textBaseline = "middle"
        const divisions = compact ? 1 : 4
        for (let n = 0; n <= divisions; ++n) {
            const y = top + (bottom - top) * n / divisions
            ctx.strokeStyle = "#363e4c"
            ctx.beginPath()
            ctx.moveTo(left, y)
            ctx.lineTo(right, y)
            ctx.stroke()
            if (!compact) {
                ctx.fillStyle = "#a4afbe"
                ctx.fillText(String(maximum * (divisions - n) / divisions), left - 6, y)
            }
        }

        if (!compact) {
            ctx.strokeStyle = "#2b323d"
            ctx.beginPath()
            for (let n = 0; n <= 12; ++n) {
                const x = left + (right - left) * n / 12
                ctx.moveTo(x, top)
                ctx.lineTo(x, bottom)
            }
            ctx.stroke()
        }

        const step = (right - left) / 59
        const xAt = i => right - step * (samples.length - 1 - i)
        const yAt = i => bottom - (bottom - top) * Math.max(0, Math.min(maximum, samples[i])) / maximum
        const fill = ctx.createLinearGradient(0, top, 0, bottom)
        fill.addColorStop(0, Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.42))
        fill.addColorStop(1, Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.08))
        ctx.fillStyle = fill
        ctx.strokeStyle = lineColor
        ctx.lineWidth = compact ? 1.25 : 2

        // Missing samples are gaps rather than zeroes.
        let start = 0
        while (start < samples.length) {
            if (typeof samples[start] !== "number") {
                ++start
                continue
            }
            let end = start
            while (end + 1 < samples.length && typeof samples[end + 1] === "number")
                ++end

            ctx.beginPath()
            ctx.moveTo(xAt(start), yAt(start))
            for (let i = start + 1; i <= end; ++i)
                ctx.lineTo(xAt(i), yAt(i))
            ctx.stroke()
            ctx.lineTo(xAt(end), bottom)
            ctx.lineTo(xAt(start), bottom)
            ctx.closePath()
            ctx.fill()
            start = end + 1
        }
    }
}
