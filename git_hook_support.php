<?php
require __DIR__ . '/../../vendor/autoload.php';

const LANGUAGE_DIR = __DIR__ . '/../../resources/lang/';

$dir = array_diff(scandir(LANGUAGE_DIR . 'en/'), ['..', '.']);
foreach ($dir as $file) {
    $en_data = require LANGUAGE_DIR . "en/$file";
    if (!file_exists(LANGUAGE_DIR . "ja/$file")) {
        echo "Missing $file of japanese language.";
        exit();
    }
    $jp_data = require LANGUAGE_DIR . "ja/$file";
    if (!compareLanguageFile($en_data, $jp_data, $file)) {
        exit();
    }
}

function compareLanguageFile($en, $ja, $fileName)
{
    if (count($en) !== count($ja)) {
        echo "Language keys of $fileName file between two language doesn't have consistence.";
        return false;
    }

    foreach ($en as $key => $value) {
        if (!isset($ja[$key])) {
            echo "Missing $key language key in japanese language.";
            return false;
        }
    }

    return true;
}

exit();