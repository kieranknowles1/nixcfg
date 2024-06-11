/**
 * Application launcher
 * Heavily based on https://github.com/Aylur/ags/blob/main/example/applauncher/applauncher.js
 */
// TODO: Finish implementing this

import { Application } from "types/service/applications";

/**
 * Launcher for applications
 */
const applications = await Service.import('applications');

const WINDOW_NAME = 'launcher';

function AppItem(app: Application) {
    return Widget.Button({
        on_clicked: () => {
            App.closeWindow(WINDOW_NAME);
            app.launch();
        },
        child: Widget.Box({
            // Horizontal box
            children: [
                // TODO: Icon
                Widget.Label({
                    label: app.name,
                })
            ]
        })
    })
}

function AppLauncher(args: {
    width: number;
    height: number;
}) {
    const apps = applications.list;

    return Widget.Box({
        vertical: true, // Vertically stack children
        children: [
            Widget.Scrollable({
                hscroll: 'never', // Vertical scroll only
                css: `min-width: ${args.width}px; min-height: ${args.height}px;`,
                child: Widget.Box({
                    vertical: true,
                    children: apps.map(AppItem),
                })
            })
        ]
    })
}

export default function() {
    return Widget.Window({
        name: WINDOW_NAME,
        setup: self => self.keybind("Escape", () => App.closeWindow(WINDOW_NAME)),
        anchor: ['top', 'bottom', 'left', 'right'],
        child: AppLauncher({
            width: 400,
            height: 700,
        }),
    })
}
