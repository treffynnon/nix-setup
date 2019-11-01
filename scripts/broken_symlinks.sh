#!/bin/bash

function get_full_path() {
  local __basepath="$1"
  local __path=$(realpath "$__basepath")
  local __result=$?
  if [ $__result -eq 0 ]; then
    echo "$__path"
  else
    echo "$__basepath is not a valid path"
    exit $__result
  fi
}
function find_broken_links() {
  local __basepath="$1"
  find "$__basepath" -type l -exec test ! -e {} \; -print
}
function find_link_target() {
  local __basepath="$1"
  # Unfortunately not POSIX compatible
  # find "$__basepath" -maxdepth 0 -printf %l
  # so use this less appealing solution instead
  ls -l "$__basepath" | sed -e 's/.* -> //'
}
function is_matching_target() {
  local __target="$1"
  local __term="$2"
  local __matched=0
  [[ "$__target" =~ $__term ]]
}
function map_broken_links() {
  local __fn="$1"
  local __basepath="$(get_full_path $2)"
  local __term="$3"
  while read -r link; do
    if is_matching_target $(find_link_target "$link") "$__term"; then
      $__fn "$link"
    fi
  done <<< "$(find_broken_links $__basepath)"
}

function help() {
  echo "$0 fn basepath target_terms"
  echo "  fn            a function or bash executable command that is applied to each matching link"
  echo "  basepath      where to start looking for broken symlinks"
  echo "  target_terms  regex that must match against the broken symlinks target ('.*' to match all)"
  echo " "
  echo "For example:"
  echo "  $0 unlink ./my/base/path '^/(etc|tmp)'"
  echo "  $0 echo ./my/base/path '.*'"
  echo " "
}

if [ "$1" = "--help" ]; then
  help
  exit 0
elif [ "$1" = "" -o "$2" = "" -o "$3" = "" ]; then
  help
  exit 1
fi

map_broken_links $1 "$2" "$3"

