#!/usr/bin/env bash

#==============================================================================
# Script Name: fetch.sh
#
# Description:
#   This script fetches a URL using curl with support for caching and optional
#   authentication methods. It validates that the response is in JSON format
#   and caches the result to avoid unnecessary re-fetching.
#
# Usage:
#   ./fetch.sh [OPTIONS] <URL>
#
# Options:
#   -a, --bearer-token     Provide a Bearer Token for authentication.
#   -b, --basic-token      Provide a Basic Token for authentication.
#   -d, --cache-directory  Specify a custom directory to store cache files.
#   -i, --invalidate-cache Force invalidation of the cached content.
#   -o, --oauth-token      Provide an OAuth Token for authentication.
#   -s, --cache-suffix     Specify a custom suffix for the cache filename.
#   -u, --user             Provide a username for basic authentication.
#
# Notes:
#   Only one authentication method can be used per execution.
#
#==============================================================================

#------------------------------------------------------------------------------
# Constants and Initial Variable Setup
#------------------------------------------------------------------------------

ERROR_PREFIX="\033[37;41;1m ERR \033[0m"

CACHE_DIRECTORY="$(dirname "$(realpath "$0")")/.fetch/cache"
CACHE_SUFFIX="$(date +"%Y%m%d%H")"

INVALIDATE_CACHE=false

BASIC_TOKEN=""
BEARER_TOKEN=""
OAUTH_TOKEN=""
USER=""

AUTH_USED=0

# Default curl arguments:
#   --connect-timeout: maximum time in seconds to wait for a connection.
#   --max-time: maximum time in seconds for the entire request.
#   --silent: suppress progress output.
#   --fail: fail silently on server errors.
#   --header: add a header to accept JSON responses.
CURL_ARGUMENTS=(--connect-timeout 10 --max-time 15 --silent --fail --header "Accept: application/json")

#------------------------------------------------------------------------------
# Command-Line Option Parsing using getopt
#------------------------------------------------------------------------------

if ! OPTIONS=$(getopt -n "$0" -o 'a:b:d:hio:s:u:' -l 'bearer-token:,basic-token:,cache-directory:,help,invalidate-cache,oauth-token:,cache-suffix:,user:' -- "$@"); then
    echo -e "$ERROR_PREFIX Failed to parse options." >&2 ; exit 1
fi

eval set -- "$OPTIONS"

while (( $# > 0 )); do
    case "$1" in
        -a|--bearer-token) BEARER_TOKEN="$2" ; (( AUTH_USED++ )) ; shift 2 ;;
        -b|--basic-token) BASIC_TOKEN="$2" ; (( AUTH_USED++ )) ; shift 2 ;;
        -d|--cache-directory) CACHE_DIRECTORY="$2" ; shift 2 ;;
        -i|--invalidate-cache) INVALIDATE_CACHE=true ; shift ;;
        -o|--oauth-token) OAUTH_TOKEN="$2" ; (( AUTH_USED++ )) ; shift 2 ;;
        -s|--cache-suffix) CACHE_SUFFIX="$2" ; shift 2 ;;
        -u|--user) USER="$2" ; (( AUTH_USED++ )) ; shift 2 ;;
        --) shift ; break ;;
        *) exit 1 ;;
    esac
done

#------------------------------------------------------------------------------
# Validate Input and Prepare Cache
#------------------------------------------------------------------------------

if (( $# != 1 )); then
    echo -e "$ERROR_PREFIX URL must be supplied." >&2 ; exit 1
fi

mkdir -p "$CACHE_DIRECTORY" || {
    echo -e "$ERROR_PREFIX Could not create cache directory." >&2 ; exit 1
}

CACHE_FILE="$CACHE_DIRECTORY/$(echo -n "$1" | tr -cd '[:alnum:]' | md5sum | awk '{print $1}').$CACHE_SUFFIX"

if [[ $INVALIDATE_CACHE == false && -s "$CACHE_FILE" ]]; then
    cat "$CACHE_FILE" ; exit
fi

#------------------------------------------------------------------------------
# Authentication Handling
#------------------------------------------------------------------------------

if (( AUTH_USED > 1 )); then
    echo -e "$ERROR_PREFIX You can only use 0 or 1 auth methods." >&2 ; exit 1
fi

if [[ -n "$OAUTH_TOKEN" ]]; then
    CURL_ARGUMENTS+=(--header "Authorization: OAuth $OAUTH_TOKEN")
elif [[ -n "$BEARER_TOKEN" ]]; then
    CURL_ARGUMENTS+=(--header "Authorization: Bearer $BEARER_TOKEN")
elif [[ -n "$BASIC_TOKEN" ]]; then
    CURL_ARGUMENTS+=(--header "Authorization: Basic $BASIC_TOKEN")
elif [[ -n "$USER" ]]; then
    CURL_ARGUMENTS+=(--user "$USER" --basic)
fi

#------------------------------------------------------------------------------
# Fetch URL Content Using curl
#------------------------------------------------------------------------------

TMPFILE="$(mktemp)"

STATUS_CODE=$(curl "${CURL_ARGUMENTS[@]}" -w "%{http_code}" -o "$TMPFILE" "$1" 2>/dev/null) || {
    echo -e "$ERROR_PREFIX Failed to fetch URL $1." >&2 ; rm -f "$TMPFILE" ; exit 1
}

if (( STATUS_CODE != 200 )); then
     echo -e "$ERROR_PREFIX $STATUS_CODE: Unsupported http status code." ; rm -f "$TMPFILE" ; exit 1
fi

#------------------------------------------------------------------------------
# Validate JSON Response and Cache the Output
#------------------------------------------------------------------------------

if ! jq -e . "$TMPFILE" &>/dev/null; then
    echo -e "$ERROR_PREFIX Response is not valid JSON." >&2; rm -f "$TMPFILE" ; exit 1
fi

tee "$CACHE_FILE" < "$TMPFILE"
rm -f "$TMPFILE"
