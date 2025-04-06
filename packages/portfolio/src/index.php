<?php
// Can't use getenv with constants
// $out is magically set by Nix. This build system is overkill, but I use NixOS anyway.
$OUT_DIR = getenv('out');
if ($OUT_DIR === false) {
    throw new Exception('Output directory not set');
}
mkdir("$OUT_DIR/icons");

enum IconPack: string {
    case MDI = __DIR__ . '/.build-only/mdi-icons/';
    // Some of these have been removed over time due to licencing
    // Get creative with alternatives
    case SI = __DIR__ . '/.build-only/simple-icons/';
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

// TODO: Find a middle ground between embeds with tracking and just linking to the video
// Maybe an img that turns into an embed on click? Or just host it ourselves
function embedVideo(string $id): string {
    return <<<HTML
        <iframe class="video" width="560" height="315" src="https://www.youtube-nocookie.com/embed/$id"
          title="YouTube video player"
          allow="fullscreen" referrerpolicy="no-referrer"></iframe>
    HTML;
}

/**
 * @param array{
 *  github: string,
 *  itchio?: string,
 * } $project
 */
function projectLinks(array $project): string {
    $gh = getIcon(IconPack::SI, 'github');
    $itch = getIcon(IconPack::SI, 'itchdotio');
    $download = array_key_exists('itchio', $project)
      ? "<li>{$itch} itch.io: <a href='{$project['itchio']}'>{$project['itchio']}</a></li>"
      : "";

    // TODO: Serve downloads from the server. How to include the builds?
    // Probably use itch.io
    // Serving only Windows builds is good enough, and builds made on NixOS are not portable
    // Could just be lazy, include a zip in the repo and say "build it yourself" for Linux
    return <<<HTML
        <ul class="links-list">
            <li>{$gh} GitHub: <a href="{$project['github']}">{$project['github']}</a></li>
            $download
        </ul>
    HTML;
}

?>
<!DOCTYPE html>
<html lang="en-GB">
<head>
    <meta charset="UTF-8">
    <title>Kieran Knowles</title>
    <link rel="stylesheet" href="style.css">
    <script src="gameOfLife.js" defer></script>
</head>
<body>
    <h1>Kieran Knowles</h1>
    <!-- TODO: Work on the portfolio page -->
     <nav>
        <ul>
            <li><a href="#blitzbox">Blitzbox</a></li>
            <li><a href="#csc8502">CSC8502 Advanced Graphics for Games</a></li>
            <li><a href="#csc8503">CSC8503 Advanced Game Technologies</a></li>
        </ul>
     </nav>

     <header>
        <h2>About Me</h2>
        <!-- TODO: Fill this in -->
        <a href="./cv-kieran-knowles.pdf" target="_blank"><?echo getIcon(IconPack::MDI, 'file-document')?> CV Download</a>
        <div class="twopane">
            <section>
                <h3>Contact</h3>
                <ul class="links-list">
                    <li><?echo getIcon(IconPack::MDI, 'email')?> Email: <a href="mailto:contact@selwonk.uk">contact@selwonk.uk</a></li>
                    <li><?echo getIcon(IconPack::SI, 'github')?> GitHub: <a href="https://github.com/kieranknowles1">https://github.com/kieranknowles1</a></li>
                    <li><?echo getIcon(IconPack::MDI, 'domain')?> LinkedIn: <a href="https://www.linkedin.com/in/kieran-john-knowles/">https://www.linkedin.com/in/kieran-john-knowles/</a></li>
                    <li><?echo getIcon(IconPack::SI, 'itchdotio')?> itch.io: <a href="https://kieranknowles.itch.io/">https://kieranknowles.itch.io/</a></li>
                </ul>
            </section>

            <section>
                <h3>Skills</h3>
                <p>Programming in:</p>
                <ul class="links-list">
                    <li><?echo getIcon(IconPack::SI, 'cplusplus')?> C++</li>
                    <li><?echo getIcon(IconPack::SI, 'rust')?> Rust (fairly limited) <!-- :) --></li>
                    <li><?echo getIcon(IconPack::MDI, 'coffee')?> Java</li>
                    <li><?echo getIcon(IconPack::SI, 'python')?> Python</li>
                    <li><?echo getIcon(IconPack::SI, 'typescript')?> Typescript</li>
                </ul>
            </section>
        </div>
    </header>

    <canvas id="gameoflife" width="500" height="250"></canvas>
    <div class="flexbox">
        <button id="gameoflife_pause" type="button">Pause</button>
        <button id="gameoflife_reset" type="button">Reset</button>
    </div>

    <main>
        <h2>Projects</h2>
        <article id="blitzbox">
            <h3>Blitzbox</h3>
            <?php echo embedVideo('xMGoUh14qWc') ?>
            <!-- TODO: Gallery -->
            <div class="twopane">
              <div>
                <?php echo projectLinks([
                    'github' => 'https://github.com/kieranknowles1/csc8508-team-project',
                    'itchio' => 'https://abarnett.itch.io/blitzbox',
                ]); ?>
                <p>
                  A gravity manipulation boomer shooter built for the CSC8508 Team Project module by
                  a team of eight. My work includes:
                </p>
                <ul>
                  <li>Full PS5 support, including cross-platform multiplayer</li>
                  <li>Multithreaded asset loading via a thread pool</li>
                  <li>Controller input on all platforms</li>
                  <li>Automatic mesh conversion during build, for an order of magnitude speedup</li>
                  <li>TrueType font rendering via a texture atlas</li>
                  <li>Memory leak detection using Valgrind</li>
                  <li>As always, Linux support through SDL2</li>
                </ul>
              </div>
            </div>
        </article>

        <article id="csc8502">
            <h3>CSC8502 Advanced Graphics for Games</h3>
            <!-- TODO: Gallery with images -->
            <?php echo embedVideo('GKlL0EY-yHE') ?>
            <div class="twopane">
                <div>
                  <?php echo projectLinks([
                      'github' => 'https://github.com/kieranknowles1/csc8502-advanced-graphics',
                  ]); ?>
                  <!-- TODO: Link to the project, should I automate building to be extra fancy? -->
                  <p>
                      A 3D graphics engine based on OpenGL. Features include:
                  </p>
                  <ul>
                      <li>Deferred rendering capable of handling 500 lights at 1440p 60fps</li>
                      <li>Shadow mapping with projected textures and no hard limits</li>
                      <li>Tessellated terrain</li>
                      <li>Built-in video recording, capturing each frame as a PNG image</li>
                      <li>Linux support via SDL2</li>
                  </ul>
                </div>
                <div>
                    <h4>Feedback</h4>
                    <p>Marks: 94/100</p>
                    <blockquote>
                        Excellent piece of work showcasing multiple graphical techniques in a cohesive scene.
                        All of the core concepts are in place and well integrated, with particularly good terrain.
                        Many more advanced techniques are also included, with great use of lighting in general
                        (including multiple shadow maps). Nice to see tessellation place as well as good
                        understanding of the uses for frame buffers etc. An excellent addition to your portfolio.
                    </blockquote>
                    <cite>Dr G Ushaw</cite>
                </div>
            </div>
        </article>

        <article id="csc8503">
            <h3>CSC8503 Advanced Game Technologies</h3>
            <?php echo embedVideo('0JzQBoRjsA0') ?>
            <div class="twopane">
                <div>
                    <?php echo projectLinks([
                        'github' => 'https://github.com/kieranknowles1/csc8503-advanced-game-technologies/',
                    ]); ?>
                    <!-- TODO: Link to the project -->
                    <p>
                        A game engine primarily focused on networking, including:
                    </p>
                    <ul>
                        <li>Client-server architecture with lazily sent delta states</li>
                        <li>UDP networking via the ENet library</li>
                        <li>AI agents controlled by nested state machines and A* pathfinding</li>
                        <li>Physics engine with support for OOBBs, constraints, and raycasting</li>
                        <li>Spatial partitioning using quadtrees</li>
                        <li>As before, Linux support</li>
                    </ul>
                </div>
                <div>
                    <h4>Feedback</h4>
                    <p>Marks: 95/100</p>
                    <blockquote>
                        A nice game world, with some strong additions throughout. There's added elasticity and some
                        new collision volume code, along with separate static and dynamic collision lists for performance.
                        There's some extra work on constraints to add some additional expressiveness to the physics system.
                        Good use of raycasting to keep the camera in a useful position relative to the player.
                        <br>
                        There's a lot of network code implemented, and it is well integrated into the gameplay. The AI
                        makes good use of hierarchical state machines, and implements both pathfinding itself, and moving
                        through the world to reach waypoints well.
                        <br>
                        While more could have been done on the physics side, there's been a lot of thought put into making
                        an effective networking solution, that maintains the consistency of the game world.
                    </blockquote>
                    <cite>Dr RG Davison</cite>
                </div>
            </div>
        </article>
    </main>

    <footer>
        <p>Icons sourced from <a href="https://pictogrammers.com/">Material Design Icons</a> and <a href="https://simpleicons.org/">Simple Icons</a></p>
        <p>© 2025 Kieran Knowles</p>
    </footer>
</body>
</html>
