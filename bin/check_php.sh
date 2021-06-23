. .amv_lint.env
PHP_CONVENTION_CHECKING_DIRS=$1
DEBUG_MODE=$2
FIX=$3
checking_php () {
  if [ "$PHP_CONVENTION_CHECKING_DIRS" == '' ]; then
    echo "${ORANGE}[!] There are no files to check.${RESET_COLOR}\n"
      return
  fi

  if [ "$FIX" == '--fix' ]; then
    checking_php_result=$(php vendor/bin/phpcbf --standard=$CHECKING_STANDARDS $PHP_CONVENTION_CHECKING_DIRS)
    php_log_path=$LOGS_FILE_PATH$PHP_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${GREEN}[✓] Fixing completed. Please check fixed log at: \"$php_log_path\"${RESET_COLOR}\n"
    echo "$checking_php_result" > "$php_log_path"
    exit 0
  else
    checking_php_result=$(php vendor/bin/phpcs --standard=$CHECKING_STANDARDS $PHP_CONVENTION_CHECKING_DIRS -n)
  fi
  if [ "$checking_php_result" != '' ]; then
    php_log_path=$LOGS_FILE_PATH$PHP_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${RED}[✗] There are some errors: Please checking these errors in your \"$php_log_path\"${RESET_COLOR}\n"
    echo "$checking_php_result" > "$php_log_path"
    [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Passed !!!${RESET_COLOR}\n"
  fi
}

echo "\n${BLUE}- Checking for coding convention of PHP files:${RESET_COLOR}"
checking_php
exit 0