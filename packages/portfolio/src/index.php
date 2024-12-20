<?php
enum IconPack: string {
    case MDI = __DIR__ . '/mdi-icons/';
    case SI = __DIR__ . '/simple-icons/';
}

// TODO: Reuse icons. Inlining is wasteful. <img> doesn't work since I can't style them.
/**
 * Get the SVG icon for the given pack and name.
 */
function getIcon(IconPack $pack, string $name): string {
    $path = $pack->value . $name . '.svg';
    $svg = file_get_contents($path);
    if ($svg === false) {
        throw new Exception('Icon not found');
    }
    return $svg;
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
            <? echo projectHeader([
                'title' => 'CSC8502 Advanced Graphics for Games',
                'id' => 'csc8502',
                'videoId' => 'GKlL0EY-yHE',
                'github' => 'https://github.com/kieranknowles1/csc8502-advanced-graphics'
            ]); ?>
            <!-- TODO: Link to the project, should I automate building to be extra fancy? -->
        </article>

        <article>
            <? echo projectHeader([
                'title' => 'CSC8503 Advanced Game Technologies',
                'id' => 'csc8503',
                'videoId' => '0JzQBoRjsA0',
                'github' => 'https://github.com/kieranknowles1/csc8503-advanced-game-technologies/'
            ]); ?>
            <!-- TODO: Link to the project -->
        </article>
     </main>
</body>
