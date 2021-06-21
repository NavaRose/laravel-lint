#!/bin/sh

# Variable define
DEBUG_MODE=false # Turn it true for debug this file only
CHECKING_STANDARDS='psr2' # List of PHP convention standards for checking, separate by comma ","
IS_STAGED_CHECKING=false # set false if you want to check global

PHP_STAGED_FILES=$(git status -s | grep -E '^[^D].*\.php$'| awk '{print $2}')
JS_STAGED_FILES=$(git status -s | grep -E '^[^D].*\.js$'| awk '{print $2}')
STAGED_FILES=$(git status -s | grep -E '^[^D]'| awk '{print $2}')

# Checking folder of PHP, JavaScript and ENV using if you set false to IS_STAGED_CHECKING variable
ENV_USING_CHECKING_DIRS='./app ./database'
PHP_CONVENTION_CHECKING_DIRS='./app'
JS_CONVENTION_CHECKING_DIRS='./resources'

LOGS_FILE_PATH='./storage/logs/pre_commit_checking/'
PHP_ERROR_LOG_FILE_NAME='php_commit_error'
JS_ERROR_LOG_FILE_NAME='js_commit_error'

LOGS_FILE_EXTENSION='.log'

LOG_DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Define text color
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
RESET_COLOR='\033[0m'

if [ $DEBUG_MODE == true ]; then
  clear
  rm -rf ./storage/logs/pre_commit_checking/*
fi

echo "=============================== Git Hook Pre-commit ===================================="

# Check current executing file and if check staged files
if [ $IS_STAGED_CHECKING == true ]; then
    ENV_USING_CHECKING_DIRS=$STAGED_FILES
    PHP_CONVENTION_CHECKING_DIRS=$PHP_STAGED_FILES
    JS_CONVENTION_CHECKING_DIRS=$JS_STAGED_FILES
fi

# Check system consistency and coding convention before commit
count_file_line () {
    arg1=$1
    return "$(wc -l "$arg1" | awk '{print $1}')"
}

checking_env_lines () {
  count_file_line .env
  env_file_line=$?
  count_file_line .env.example
  env_example_file_line=$?

  if [ "$env_file_line"  != "$env_example_file_line" ]; then
    echo "${RED}[✗] Not match: You cannot commit this change.${RESET_COLOR}"
    [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Lines number of environment files matched.${RESET_COLOR}"
  fi
}

checking_env_variable () {
  error_flag=false
  ENV_VARIABLE=$(cat .env | sed 's;=.*;;')
  . .env.example
  for var in $ENV_VARIABLE
  do
    CHECKING_VAR="${!var=::undefined::}"
    if [ "$CHECKING_VAR" == "::undefined::" ]; then
      echo "${RED}[✗] Please define $var variable at .env.example${RESET_COLOR}:" ${!var}
      error_flag=true
    fi
  done
  if [ $error_flag != false ]; then
      [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Variable consistency between environment files matched.${RESET_COLOR}"
  fi
}

checking_using_of_env () {
  use_env_directly=$(grep -rn $ENV_USING_CHECKING_DIRS -e "env([[:alnum:] ',_]*)")
  if [ "$use_env_directly" != '' ]; then
    echo "${RED}[✗] Failed: these following files are using environment variables directly:${RESET_COLOR}"
    echo "$use_env_directly\n"
    [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Checking completed, no files using environment variables in wrong way.${RESET_COLOR}\n"
  fi
}

checking_language () {
  error_flag=false
  dir=`ls ./resources/lang/en`

  # Scanning in En language dir...
  for entry in $dir
  do
    EN_FILE=./resources/lang/en/$entry
    JP_FILE=./resources/lang/ja/$entry

    # Check if file exist in Ja language dir
    if [ -f "$JP_FILE" ]; then
      # If exist, then checking line number between two language are same
      count_file_line "$JP_FILE"
      jp_lang_file_line=$?
      count_file_line "$EN_FILE"
      en_lang_file_line=$?
      if [ $jp_lang_file_line != $en_lang_file_line ]; then
        echo "${RED}[✗] $entry between two languages not same line${RESET_COLOR}"
        error_flag=true
      fi
      echo "${GREEN}[✓] $entry${RESET_COLOR} file are matched."
    else
      echo "${RED}[✗] $entry file is not exist in JA language${RESET_COLOR}"
      error_flag=true
    fi
  done

  checking_language_result=$(php -f ./git_hooks/git_hook_support.php)
  if [ "$checking_language_result" != '' ]; then
      echo "\n${RED}[✗] $checking_language_result${RESET_COLOR}"
      error_flag=true
  fi

  if [ $error_flag != false ]; then
      [ ! $DEBUG_MODE == 'true' ] && exit 1
  fi
}

checking_php () {
  if [ "$PHP_CONVENTION_CHECKING_DIRS" == '' ]; then
    echo "${ORANGE}[!] There are no files to check.${RESET_COLOR}\n"
      return
  fi
  checking_php_result=$(php vendor/bin/phpcs --standard=$CHECKING_STANDARDS $PHP_CONVENTION_CHECKING_DIRS -n)
  if [ "$checking_php_result" != '' ]; then
    php_log_path=$LOGS_FILE_PATH$PHP_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${RED}[✗] There are some errors: Please checking these errors in your \"$php_log_path\"${RESET_COLOR}\n"
    echo "$checking_php_result" > "$php_log_path"
    [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Passed !!!${RESET_COLOR}\n"
  fi
}

checking_javascript () {
  if [ "$JS_CONVENTION_CHECKING_DIRS"  == '' ]; then
    echo "${ORANGE}[!] There are no files to check.${RESET_COLOR}\n"
    return
  fi
  checking_js_result=$(npx eslint $JS_CONVENTION_CHECKING_DIRS)
  if [ "$checking_js_result" != '' ]; then
    js_log_path=$LOGS_FILE_PATH$JS_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${RED}[✗] There are some errors: Please check these errors in your \"$js_log_path\"${RESET_COLOR}\n"
    echo "$checking_js_result" > "$js_log_path"
    [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Passed !!!${RESET_COLOR}\n"
  fi
}

lint() {
  echo "${BLUE}- Checking environment variable:${RESET_COLOR}"
  checking_env_lines
  checking_env_variable
  checking_using_of_env

  # Checking language translation files
  echo "${BLUE}- Checking consistency of language translation files:${RESET_COLOR}"
  checking_language

  # Create logs dir if not exist
  if [ ! -d $LOGS_FILE_PATH ]; then
    mkdir $LOGS_FILE_PATH
  fi

  # Checking for coding convention, coding styles of PHP
  echo "\n${BLUE}- Checking for coding convention of PHP files:${RESET_COLOR}"
  checking_php

  # Checking for coding convention, coding styles of JavaScript
  echo "${BLUE}- Checking for coding convention of JavaScript files:${RESET_COLOR}"
  checking_javascript

  echo "${GREEN}=> Ok all checking passed. Congratulations !!${RESET_COLOR}"
  [ $DEBUG_MODE == 'true' ] && exit 1
}

fix () {
  echo "${BLUE}- Begin to fix JavaScript conventions:${RESET_COLOR}"

  checking_js_result=$(npx eslint --fix $JS_CONVENTION_CHECKING_DIRS)
  if [ "$checking_js_result" != '' ]; then
    js_log_path=$LOGS_FILE_PATH$JS_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${RED}[✗] There are still some errors: Please check these errors in your \"$js_log_path\"${RESET_COLOR}\n"
    echo "$checking_js_result" > "$js_log_path"
  else
    echo "${GREEN}[✓] Passed !!!${RESET_COLOR}\n"
  fi

  echo "${BLUE}- Begin to fix PHP conventions:${RESET_COLOR}"
  checking_php_result=$(php vendor/bin/phpcbf $PHP_CONVENTION_CHECKING_DIRS)
  if [ "$checking_php_result" != '' ]; then
    php_log_path=$LOGS_FILE_PATH$PHP_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${RED}[✗] There are still some errors: Please checking these errors in your \"$php_log_path\"${RESET_COLOR}\n"
    echo "$checking_php_result" > "$php_log_path"
    [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Passed !!!${RESET_COLOR}\n"
  fi
}

hooks() {
  params1=$1

  if [ $params1 == 'enable' ]; then
      cp ./vendor/nguyendotrung/laravel-lint/hooks/pre-commit .git/hooks/pre-commit
  fi
}

clear_logs () {
  rm -rf ./storage/logs/pre_commit_checking/*
}

"$@"
exit 0