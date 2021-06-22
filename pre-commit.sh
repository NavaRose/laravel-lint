#!/bin/sh

# Create logs dir if not exist
if [ ! -f ./.amv_lint.env ]; then
    echo "${RED}[✗] The initial of package isn't done yet. Please run:${RESET_COLOR}"
    echo "    ./vendor/amv-hub/amv-lint/init.sh\n"
    exit 1;
fi

# Variable define
. .amv_lint.env

if [ $2 == '-g' ]; then
    DEBUG_MODE=true
fi

DIR=./vendor/$PACKAGE_NAME

# Define text color
. "$DIR"/bin/.color

PHP_STAGED_FILES=$(git status -s | grep -E '^[^D].*\.php$'| awk '{print $2}')
JS_STAGED_FILES=$(git status -s | grep -E '^[^D].*\.js$'| awk '{print $2}')
STAGED_FILES=$(git status -s | grep -E '^[^D]'| awk '{print $2}')

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
  BIN_DIR=./vendor/"$PACKAGE_NAME"/bin/
  
  case $3 in
  php)
    sh "$BIN_DIR"check_php.sh "$PHP_CONVENTION_CHECKING_DIRS" $DEBUG_MODE
      [ $? == 1 ] && exit 1
    ;;
  esac

  echo "${BLUE}- Checking environment variable:${RESET_COLOR}"
  sh "$BIN_DIR"check_env.sh "$ENV_USING_CHECKING_DIRS" $DEBUG_MODE

  [ $? == 1 ] && exit 1

  # Checking language translation files
  echo "${BLUE}- Checking consistency of language translation files:${RESET_COLOR}"
  sh "$BIN_DIR"check_language.sh

  [ $? == 1 ] && exit 1

  # Create logs dir if not exist
  if [ ! -d $LOGS_FILE_PATH ]; then
    mkdir $LOGS_FILE_PATH
  fi

  # Checking for coding convention, coding styles of PHP
  echo "\n${BLUE}- Checking for coding convention of PHP files:${RESET_COLOR}"
  sh "$BIN_DIR"check_php.sh

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