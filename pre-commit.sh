#!/bin/sh

# Create logs dir if not exist
if [ ! -f ./.amv_lint.env ]; then
    echo "${RED}[✗] The initial of package isn't done yet. Please run:${RESET_COLOR}"
    echo "    ./vendor/amv-hub/amv-lint/init.sh\n"
    exit 1;
fi

# Variable define
. .amv_lint.env
CHECK_TYPE=$3
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

lint() {
  BIN_DIR=./vendor/"$PACKAGE_NAME"/bin/

  case $CHECK_TYPE in
  php)
    sh "$BIN_DIR"check_php.sh "$PHP_CONVENTION_CHECKING_DIRS" $DEBUG_MODE
    [ $? == 1 ] && exit 1
    exit 0
    ;;
  js)
    sh "$BIN_DIR"check_javascript.sh "$JS_CONVENTION_CHECKING_DIRS" $DEBUG_MODE
    [ $? == 1 ] && exit 1
    exit 0
    ;;
  env)
    sh "$BIN_DIR"check_env.sh "$ENV_USING_CHECKING_DIRS" $DEBUG_MODE
    [ $? == 1 ] && exit 1
    exit 0
    ;;
  lang)
    sh "$BIN_DIR"check_language.sh
    [ $? == 1 ] && exit 1
    exit 0
  esac

  sh "$BIN_DIR"check_env.sh "$ENV_USING_CHECKING_DIRS" $DEBUG_MODE
  [ $? == 1 ] && exit 1

  # Checking language translation files
  sh "$BIN_DIR"check_language.sh
  [ $? == 1 ] && exit 1

  # Create logs dir if not exist
  if [ ! -d $LOGS_FILE_PATH ]; then
    mkdir $LOGS_FILE_PATH
  fi

  # Checking for coding convention, coding styles of PHP
  sh "$BIN_DIR"check_php.sh "$PHP_CONVENTION_CHECKING_DIRS" $DEBUG_MODE
  [ $? == 1 ] && exit 1

  # Checking for coding convention, coding styles of JavaScript
  sh "$BIN_DIR"check_javascript.sh "$JS_CONVENTION_CHECKING_DIRS" $DEBUG_MODE
  [ $? == 1 ] && exit 1

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
  echo $params1
  exit 1
  if [ $params1 == 'enable' ]; then
      cp ./vendor/nguyendotrung/laravel-lint/hooks/pre-commit .git/hooks/pre-commit
  fi
}

clear_logs () {
  rm -rf ./storage/logs/pre_commit_checking/*
}

"$@"
exit 0