#!/usr/bin/env bash

INFORMATION="erdem.sahin.uslu@gmail.com"
SCRIPT_NAME="$(basename "$0")"
CSV_FILE="okul.csv"

# This file is used for searching, sorting and customized \
# viewing in csv files that satisfy the following conditions. see warning()
# For more INFORMATION: $INFORMATION
# 2017/12/08
# Name: $SCRIPT_NAME
# Version 1.0

# INFORMATION FUNCTIONS

# Usage message

usage () {
cat << EOF
Usage: $0 [(e | E) | (k | K) | N]

       e,E : search by men : optional
       k,K : search by women : optional
       N : search by Nth grade : optional
EOF
warning
exit 1
}

# Warning message

warning () {
cat << EOF
Warning! : file;
           1) must be $CSV_FILE
           csv data and format;
           1) must be name,surname,gender,grade format
           2) must be unique name,surname data
           3) must be in grade 1-4
EOF
}

# Error codes and answers

error () {
  case ${1} in
    1)
      echo "Hata: $CSV_FILE dosyası bulunamadı"
      ;;
    2)
      echo "Hata: ad,soyad çakışması var"
      ;;
    3)
      echo "Hata: devre numarası 1-4 aralığında olmalı"
      ;;
    4)
      echo "Hata: sadece bir argüman girebilirsiniz"
      ;;
    5)
      echo "Hata: taninmayan argüman: $2"
      ;;
    *)
      echo "Hata: bir sorun oluştu"
      ;;
  esac
}

die () {
  echo >&2 "$*"
  exit 1
}

# STUDENT

# Student List

student_list () {
  cat $CSV_FILE
}

# Student Helper Functions

student_print_format () {
  case $1 in
    by_gender)
      echo "\$grade \$name \$surname"
      ;;
    by_grade)
      echo "\$name \$surname \$gender"
      ;;
    all)
      echo "\$grade \$name \$surname \$gender"
      ;;
  esac
}

# Student Functions

student_print () {
  while IFS=',' read name surname gender grade;
  do
    eval echo ${1-\$name \$surname}
  done
}

student_sort_by () {
  IFS=',' read -r -a parameters<<< "$1";

  local sort_params

  for param in "${parameters[@]}"
  do
    case $param in
      name)
        sort_params+="-k1\,1 "
        ;;
      surname)
        sort_params+="-k2\,2 "
        ;;
      gender)
        sort_params+="-k3\,3 "
        ;;
      grade)
        sort_params+="-k4\,4n "
        ;;
    esac
  done

  eval "sort -t',' $sort_params"
}

student_grep_by () {
  local grep_param

  case $1 in
    gender)
      grep_param="'\$3 == \"${2^^}\"'"
      ;;
    grade)
      grep_param="'\$4 == $2'"
      ;;
  esac

  eval "awk -F',' $grep_param"
}

student_is_unique () {
  cut -d',' -f1,2 | uniq -di
}

# PROGRAM

[[ -f $CSV_FILE ]] || die $(error 1)
[[ $(student_list | student_is_unique) ]] && die $(error 2)
(( $# > 1 )) && die $(error 4)

case $1 in
  [eEkK])
    student_list |
      student_grep_by gender $1 |
      student_sort_by grade,name,surname |
      student_print "$(student_print_format by_gender)"
    ;;
  [1-4])
    student_list |
      student_grep_by grade $1 |
      student_sort_by name,surname |
      student_print "$(student_print_format by_grade)"
    ;;
  '')
    student_list |
      student_sort_by grade,name,surname |
      student_print "$(student_print_format all)"
    ;;
  *)
    [[ $1 =~ ^-?[0-9]+$ ]] && die $(error 3)
    die $(error 5 $1)
    ;;
esac
