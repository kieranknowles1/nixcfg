<?php

/**
 * Build the file specified in argv[1] and output it to stdout
 */
declare(strict_types=1);
ini_set('display_errors', 'stderr');
error_reporting(E_ALL);
set_error_handler(function (int $errno, string $errstr, string $errfile, int $errline): void {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});

if (count($argv) != 2) {
    echo "Usage: php $argv[0] <file>\n";
    exit(1);
}

$file = $argv[1];

require $file;
