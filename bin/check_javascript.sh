. .amv_lint.env
JS_CONVENTION_CHECKING_DIRS=$1
DEBUG_MODE=$2
FIX=$3
checking_javascript () {
  if [ "$JS_CONVENTION_CHECKING_DIRS"  == '' ]; then
    echo "${ORANGE}[!] There are no files to check.${RESET_COLOR}\n"
    return
  fi

  if [ $FIX == '--fix' ]; then
    checking_js_result=$(npx eslint --fix $JS_CONVENTION_CHECKING_DIRS)
    js_log_path=$LOGS_FILE_PATH$JS_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${GREEN}[✓] Fixing completed. Please check fixed log at: \"$js_log_path\"${RESET_COLOR}\n"
    echo "$checking_js_result" > "$js_log_path"
    exit 0;
  else
    checking_js_result=$(npx eslint $JS_CONVENTION_CHECKING_DIRS)
  fi

  if [ "$checking_js_result" != '' ]; then
    js_log_path=$LOGS_FILE_PATH$JS_ERROR_LOG_FILE_NAME"_"$LOG_DATE$LOGS_FILE_EXTENSION
    echo "${RED}[✗] There are some errors: Please check these errors in your \"$js_log_path\"${RESET_COLOR}\n"
    echo "$checking_js_result" > "$js_log_path"
    [ ! $DEBUG_MODE == 'true' ] && exit 1
  else
    echo "${GREEN}[✓] Passed !!!${RESET_COLOR}\n"
  fi
}

echo "${BLUE}- Checking for coding convention of JavaScript files:${RESET_COLOR}"
checking_javascript
exit 0