<?php
enum IconPack: string {
    case MDI = __DIR__ . '/mdi-icons/';
    case SI = __DIR__ . '/simple-icons/';
}

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
            <h3 id="csc8502">CSC8502 Advanced Graphics for Games</h3>
            <!-- TODO: Demo and link to the project, should I automate building to be extra fancy? -->
        </article>

        <article>
            <h3 id="csc8503">CSC8503 Advanced Game Technologies</h3>
            <!-- TODO: Demo and link to the project -->
        </article>
     </main>
</body>
