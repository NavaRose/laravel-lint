#!/bin/sh

DIR=$(dirname "${BASH_SOURCE[0]}")

mv "$DIR"/.amv_lint.env ./amv_lint.env
mv "$DIR"/.eslintrc.json ./.eslintrc.json
cp ./vendor/amv-hub/amv-lint/pre-commit.sh /usr/local/bin/amv
npm i eslint@7.29.0 eslint-plugin-vue@7.11.1 eslint-config-google@0.14.0 babel-eslint @babel/eslint-plugin
composer require "squizlabs/php_codesniffer=*" --dev

sudo rm -rf "$DIR"/init.sh