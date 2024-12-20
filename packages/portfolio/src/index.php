<?php
// Print errors to stderr and be strict about them
declare(strict_types=1);
ini_set('display_errors', 'stderr');
error_reporting(E_ALL);
set_error_handler(function (int $errno, string $errstr, string $errfile, int $errline): void {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});

// Can't use getenv with constants
// $out is magically set by Nix. This build system is overkill, but I use NixOS anyway.
$OUT_DIR = getenv('out');
if ($OUT_DIR === false) {
    throw new Exception('Output directory not set');
}

enum IconPack: string {
    case MDI = __DIR__ . '/mdi-icons/';
    case SI = __DIR__ . '/simple-icons/';
}

/**
 * Make an icon available in the output directory.
 */
function loadIcon(IconPack $pack, string $name): string {
    global $OUT_DIR;
    assert(is_string($OUT_DIR));
    $src = "{$pack->value}{$name}.svg";
    $dst = "icons/{$name}.svg";

    $svg = file_get_contents($src);
    if ($svg === false) {
        throw new Exception('Icon not found');
    }

    if (!copy($src, "{$OUT_DIR}/{$dst}")) {
        throw new Exception('Failed to copy icon');
    }
    return $dst;
}

/**
 * Get the SVG icon for the given pack and name.
 */
function getIcon(IconPack $pack, string $name): string {
    $src = loadIcon($pack, $name);
    // Alt text is empty to indicate that the icon is purely decorative
    // The surrounding text is expected to repeat the icon's meaning
    return "<img src='{$src}' alt='' class='icon'>";
}

/**
 * @param array{
 *  title: string,
 *  id: string,
 *  videoId: string,
 *  github: string,
 * } $project
 */
function projectHeader(array $project): string {
    $gh = getIcon(IconPack::SI, 'github');
    $yt = getIcon(IconPack::SI, 'youtube');
    // TODO: Find a middle ground between embeds with tracking and just linking to the video
    // Maybe an img that turns into an embed on click?
    return <<<HTML
        <h3 id="{$project['id']}">{$project['title']}</h3>
        <p>{$gh} GitHub: <a href="{$project['github']}">{$project['github']}</a></p>
        <p>{$yt} YouTube: <a href="https://www.youtube.com/watch?v={$project['videoId']}">https://www.youtube.com/watch?v={$project['videoId']}</a></p>
    HTML;
}

?>
<!DOCTYPE html>
<html lang="en-GB">
<head>
    <title>Portfolio</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Portfolio</h1>
    <!-- TODO: Work on the portfolio page -->
     <nav>
        <ul>
            <li><a href="#csc8502">CSC8502 Advanced Graphics for Games</a></li>
            <li><a href="#csc8503">CSC8503 Advanced Game Technologies</a></li>
        </ul>
     </nav>

     <header>
        <h2>About Me</h2>
        <!-- TODO: Fill this in -->
        <section>
            <h3>Contact</h3>
            <p><?echo getIcon(IconPack::MDI, 'email')?> Email: </p> <!-- TODO -->
            <p><?echo getIcon(IconPack::SI, 'github')?> GitHub: <a href="https://github.com/kieranknowles1">https://github.com/kieranknowles1</a></p>
        </section>
     </header>

     <main>
        <h2>Projects</h2>
        <article>
            <?php echo projectHeader([
                'title' => 'CSC8502 Advanced Graphics for Games',
                'id' => 'csc8502',
                'videoId' => 'GKlL0EY-yHE',
                'github' => 'https://github.com/kieranknowles1/csc8502-advanced-graphics',
            ]); ?>
            <!-- TODO: Link to the project, should I automate building to be extra fancy? -->
        </article>

        <article>
            <?php echo projectHeader([
                'title' => 'CSC8503 Advanced Game Technologies',
                'id' => 'csc8503',
                'videoId' => '0JzQBoRjsA0',
                'github' => 'https://github.com/kieranknowles1/csc8503-advanced-game-technologies/',
            ]); ?>
            <!-- TODO: Link to the project -->
        </article>
     </main>
</body>
</html>
