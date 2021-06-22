<?php
//require __DIR__ . '/../../../../vendor/autoload.php';
require './vendor/autoload.php';
const LANGUAGE_DIR = './resources/lang/';
$main_language = $argv[1];
$dir = array_diff(scandir(LANGUAGE_DIR . "$main_language/"), ['..', '.']);
foreach ($dir as $file) {
    $main_language_data = require LANGUAGE_DIR . "$main_language/$file";

    foreach (array_diff(scandir(LANGUAGE_DIR), ['..', '.']) as $lang_code) {
        if (!file_exists(LANGUAGE_DIR . "$lang_code/$file")) {
            echo "Missing $file of $lang_code language.";
            exit();
        }
        $compare_language_data = require LANGUAGE_DIR . "$lang_code/$file";
        if (!compareLanguageFile(
            [
                'language_code' => $main_language,
                'language_data' => $main_language_data
            ],
            [
                'language_code' => $lang_code,
                'language_data' => $compare_language_data
            ], $file
        )) {
            exit();
        }
    }
}

function compareLanguageFile($main_language_data, $compare_language_data, $fileName)
{
    $main_code = $main_language_data['language_code'];
    $compare_code = $compare_language_data['language_code'];
    if (count($main_language_data['language_data']) !== count($compare_language_data['language_data'])) {
        echo "Language keys of $fileName file between $main_code and $compare_code languages doesn't have consistence.\n";
        return false;
    }

    foreach ($main_language_data['language_data'] as $key => $value) {
        if (!isset($compare_language_data['language_data'][$key])) {
            echo "Missing $key language key in $compare_code language.";
            return false;
        }
    }

    return true;
}

exit();