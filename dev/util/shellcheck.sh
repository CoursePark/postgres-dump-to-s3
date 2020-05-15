#!/usr/bin/env sh

printf '\n%s\n' "Checking shell scripts..."

SHELLCHECK_OPTS=""

RUN_SHELLCHECK="shellcheck ${ALLOW_EXTERNAL_SOURCE:-} ${SHELLCHECK_OPTS} {} +"
eval "find ./*.sh -type f -exec ${RUN_SHELLCHECK}"
