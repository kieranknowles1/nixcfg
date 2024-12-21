<?php

$finder = (new PhpCsFixer\Finder())->in(__DIR__);

return (new PhpCsFixer\Config())
    ->setRules([
        '@PER-CS' => true,
        'braces_position' => [
            'classes_opening_brace' => 'same_line',
            'functions_opening_brace' => 'same_line',
        ],
    ])
    ->setFinder($finder);
