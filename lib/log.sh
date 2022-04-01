#!/usr/bin/env bash

# Various logging functions and helpers to make logging nice.

# ANSI Formatting Codes
########################################################################
# Because who wants to remember all those fiddly details?

# CSI = "Control Sequence Introducer"
CSI="\e["
END=m

NORMAL=0
BOLD=1

WHITE=37

RESET="${CSI}${NORMAL}${END}"

function _bold_color() {
    color="${1}"
    shift
    echo "${CSI}${BOLD};${color}${END}${*}${RESET}"
}

function bright_white() {
    _bold_color "${WHITE}" "${@}"
}

# Logging
########################################################################
# NOTE: All logs get sent to standard error

function log() {
    echo -e "${@}" >&2
}

# Handy for logging the exact command to be run, and then running it
function log_and_run() {
    log ❯❯ "$(bright_white "$(printf "%q " "${@}")")"
    "$@"
}

raise_error() {
    log "--- :rotating_light:" "${@}"
    # Yes, these numbers are correct :/
    if [ -z "${BASH_SOURCE[2]:-}" ]; then
        # If we're calling raise_error from a script directly, we'll
        # have a shorter call stack.
        log "Failed in ${FUNCNAME[1]}() at [${BASH_SOURCE[1]}:${BASH_LINENO[0]}]"
    else
        log "Failed in ${FUNCNAME[1]}() at [${BASH_SOURCE[1]}:${BASH_LINENO[0]}], called from [${BASH_SOURCE[2]}:${BASH_LINENO[1]}]"
    fi
    exit 1
}
