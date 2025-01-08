<?php

$finder = (new PhpCsFixer\Finder())->in(__DIR__);

// https://mlocati.github.io/php-cs-fixer-configurator/
return (new PhpCsFixer\Config())
    ->setRules([
        '@PER-CS' => true,
        'braces_position' => [
            'classes_opening_brace' => 'same_line',
            'functions_opening_brace' => 'same_line',
        ],
    ])
    ->setFinder($finder);
