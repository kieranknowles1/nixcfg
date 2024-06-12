// Copy of https://github.com/Aylur/ags/blob/main/example/ts-starter-config/config.js

const main = '/tmp/ags/main.js';

try {
    await Utils.execAsync([
        'bun', 'build', `${App.configDir}/main.ts`,
        '--outfile', main,
        '--external', 'resource://*',
        '--external', 'gi://*',
        '--external', 'file://*',
    ]);
    await import(`file://${main}`);
} catch (error) {
    console.error(error);
    App.quit();
}
