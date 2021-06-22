DIR=$(dirname "${BASH_SOURCE[0]}")
. "$DIR"/.color
checking_language () {
  language_list=`ls ./resources/lang`
  echo $language_list
  exit 1
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
      "$DIR"/utilities.sh count_file_line "$JP_FILE"
      jp_lang_file_line=$?
      "$DIR"/utilities.sh count_file_line "$EN_FILE"
      en_lang_file_line=$?

      if [ $jp_lang_file_line != $en_lang_file_line ]; then
        echo "${RED}[✗] $entry between two languages not same line${RESET_COLOR}"
        error_flag=true
      else
        echo "${GREEN}[✓] $entry${RESET_COLOR} file are matched."
      fi
    else
      echo "${RED}[✗] $entry file is not exist in JA language${RESET_COLOR}"
      error_flag=true
    fi
  done

  checking_language_result=$(php -f "$DIR"/git_hook_support.php)
  if [ "$checking_language_result" != '' ]; then
      echo "\n${RED}[✗] $checking_language_result${RESET_COLOR}"
      error_flag=true
  fi

  if [ $error_flag != false ]; then
      [ ! $DEBUG_MODE == 'true' ] && exit 1
  fi
}

echo "${BLUE}- Checking consistency of language translation files:${RESET_COLOR}"
checking_language
exit 0
