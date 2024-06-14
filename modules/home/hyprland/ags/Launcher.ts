/**
 * Application launcher
 * Heavily based on https://github.com/Aylur/ags/blob/main/example/applauncher/applauncher.js
 */
// TODO: Add eslint
// TODO: Reset the launcher on close

import { type Application } from "types/service/applications";

/**
 * Launcher for applications
 */
const applications = await Service.import('applications');

const WINDOW_NAME = 'launcher';

function onAccept(app: Application) {
    // Close the launcher window
    App.closeWindow(WINDOW_NAME);
    // Launch the application
    app.launch();
}

function AppItem(app: Application) {
    return Widget.Button({
        // Expose the app to users of the widget
        // TODO: Is there a cleaner way to do this that is type-safe?
        attribute: { app },
        on_clicked: () => onAccept(app),
        child: Widget.Box({
            // Horizontal box
            children: [
                Widget.Icon({
                    icon: app.icon_name ?? '',
                    size: 24,
                }),
                Widget.Label({
                    css: 'margin-left: 10px;', // Add some space between icon and text
                    label: app.name,
                })
            ]
        })
    })
}

/**
 * Buttons to launch core applications such as the terminal
 */
function SystemApps() {
    function makeButton(name: string, hotkey: string, icon: string, onClick: () => void) {
        return Widget.Button({
            on_clicked: () => {
                App.closeWindow(WINDOW_NAME);
                onClick();
            },
            child: Widget.Box({
                vertical: true,
                children: [
                    Widget.Icon({
                        icon, // TODO: Try to get mdi-icons working. Not sure how to do it with GTK
                        size: 24,
                        tooltipText: `${name} (${hotkey})`,
                    }),
                ],
            })
        })
    }

    return Widget.Box({
        // Horizontal box
        children: [
            makeButton(
            'File Manager', 'Win+E', 'nautilus', () => Utils.execAsync('nautilus'),
            ),
            makeButton(
                'Terminal', 'Win+T', 'utilities-terminal', () => Utils.execAsync('kitty'),
            ),
        ],
    })
}

function AppLauncher(args: {
    width: number;
    height: number;
}) {
    const apps = applications.list
        .sort((a, b) => a.name.localeCompare(b.name))
        .map(AppItem);

    function filterApps(query: string) {
        query = query.toLowerCase();
        for (const entry of apps) {
            // TODO: Don't like type assertions
            const app = entry.attribute.app as Application;
            entry.visible = app.name.toLowerCase().includes(query);
        }
    }

    return Widget.Box({
        vertical: true, // Vertically stack children
        children: [
            Widget.Entry({
                hexpand: true, // Expand horizontally to fit
                on_accept: () => {
                    const firstVisibleApp = apps.find(app => app.visible);
                    if (firstVisibleApp) {
                        const app = firstVisibleApp.attribute.app as Application;
                        onAccept(app);
                    }
                },
                on_change: event => {
                    // TODO: When does this happen?
                    if (event.text === null) {
                        return;
                    }
                    filterApps(event.text);
                }
            }),
            Widget.Scrollable({
                hscroll: 'never', // Vertical scroll only
                css: `min-width: ${args.width}px; min-height: ${args.height}px;`,
                child: Widget.Box({
                    vertical: true,
                    children: apps,
                })
            }),
            SystemApps(),
        ]
    })
}

export default function() {
    return Widget.Window({
        name: WINDOW_NAME,
        setup: self => self.keybind("Escape", () => App.closeWindow(WINDOW_NAME)),
        visible: false, // Hidden by default, use "ags -t launcher" to show
        keymode: 'exclusive', // Only this window will receive key events
        child: AppLauncher({
            width: 500,
            height: 700,
        }),
    })
}
