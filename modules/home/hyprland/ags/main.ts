// TODO: Disable warning about global await

import Launcher from "Launcher"

const time = Variable('', {
    // Hour:Minute (24-hour), Day of the week abbr, day of month, month abbr
    // 24-hour time as we Brits can do maths
    poll: [1000, 'date "+%H:%M %a %e %b"'],
})

const Bar = (monitor: number) => Widget.Window({
    monitor,
    name: `bar${monitor}`,
    anchor: ['top', 'left', 'right'],
    exclusivity: 'exclusive',
    child: Widget.CenterBox({
        center_widget: Widget.Label({
            hpack: 'center',
            label: time.bind(),
        }),
    }),
})

App.config({
    style: "./style.css",
    windows: [
        Bar(0),
        Launcher(),
    ],
})
