#!/usr/local/bin/env zsh
# -*- mode: shell-script; -*-

# script file
FILE=${0:A}

# file directory
DIR=$(dirname $FILE)

# source directory
SRC=$(realpath $DIR/../src)

# option parser
PARSER=$SRC/$(basename ${0#.sh} | sed s,proj-,,)

function find_projects {
  # assign args
  local args=(${(s: :)*})
  local limit=${args[1]}
  local fullpath=${args[2]}
  local oneline=${args[3]}
  local grid=${args[4]}
  local long=${args[5]}

  # find and set project symbolic links
  set -A project_links
  local project_links=($(find $PROJECTS -mindepth 2 -maxdepth 2 -type l | xargs realpath 2>/dev/null))

  # set project ignore patterns
  set -A project_ignores
  if [ -x $(which git-ignore) 2>/dev/null ]; then project_ignores+=($(git-ignore --global | tail -n+2)); fi
  if [ -e $HOME/.gitignore ]; then project_ignores+=($(cat $HOME/.gitignore)); fi
  project_ignores=($(echo $project_ignores | grep -v -e '^$' | sort))

  local active_projects=()
  local count=0

  for modified_file_path in $PROJECTS/*/*/**(-/DNom); do
    # ignore file if it is the target of a symbolic link
    if [[ ${project_links[(r)$modified_file_path]} == $modified_file_path ]]; then continue; fi

    local modified_file=${modified_file_path#$PROJECTS}
    local modified_file_array=(${(s:/:)modified_file})
    local filename=${modified_file_array[-1]}

    # ignore file if it matches an ignored glob
    if [[ ${project_ignores[(r)$filename]} == $filename ]]; then continue; fi

    local project_org=${modified_file_array[1]}
    local project_name=${modified_file_array[2]}
    local project="$project_org/$project_name"

    # ignore project if another of its files have changed and the project is active
    if [[ ${active_projects[(r)$project]} == $project ]]; then continue; else active_projects+=$project; fi

    # abort if we've hit our limit
    let ++count
    test $count -gt $limit && break

    if [ $long -eq 1 ]; then
      print_project_long $project $fullpath $modified_file_path $count
      # print a newline if last item
      test $count -eq $limit && echo
    elif [ $oneline -eq 1 ] || [ $grid -eq 1 ]; then
      print_project_path $project $fullpath
    fi
  done
}

function print_project_path {
  local project=$1
  local fullpath=$2

  if [ $fullpath -eq 1 ]; then
    realpath $PROJECTS/$project
  else
    echo $project
  fi
}

function print_project_long {
  local project_path=$(print_project_path $1 $2)
  local project_date=$(print_project_date $3)

  print_project_gap $4

  printf "%s %s" $project_date $project_path
}

function print_project_date {
  stat --printf="%Y" $1 | xargs -I _ date +'%Y-%m-%d %H:%M' --date='@_'
}

function print_project_gap {
  test $1 -gt 1 && echo
}

# parse args
ARGV=$($PARSER $*)

# did parsing succeed?
if [ $? -eq 0 ]; then
  # was help displayed?
  if [ $(wc -l <<< $ARGV) -eq 1 ]; then
    find_projects $ARGV
  else
    echo $ARGV
  fi
else
  return 1
fi
