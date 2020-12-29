#!/usr/bin/env sh

_info(){
    echo "$@"
}
_err(){
    echo "$@"
}
_debug() {
    a=1
    # _info "$@"
}

#output the sensitive messages
_secure_debug() {
    _debug "$@"
}

_debug2() {
    _debug "$@"
}

_secure_debug2() {
    _debug "$@"
}

_debug3() {
    _debug "$@"
}

_secure_debug3() {
    _debug "$@"
}

_upper_case() {
  # shellcheck disable=SC2018,SC2019
  tr 'a-z' 'A-Z'
}

_lower_case() {
  # shellcheck disable=SC2018,SC2019
  tr 'A-Z' 'a-z'
}

_startswith() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep "^$_sub" >/dev/null 2>&1
}

_endswith() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep -- "$_sub\$" >/dev/null 2>&1
}

_contains() {
  _str="$1"
  _sub="$2"
  echo "$_str" | grep -- "$_sub" >/dev/null 2>&1
}

_math() {
  _m_opts="$@"
  printf "%s" "$(($_m_opts))"
}

_post(){
  curl --user-agent "dns-api/0.0.1 (598420668@qq.com)"  --request "POST"  --data "$1" "$2"   2>/dev/null &
}


_get(){
  curl --user-agent "dns-api/0.0.1 (598420668@qq.com)"  --request "GET"  "$1"   2>/dev/null &
}