#!/bin/bash
if [[ ${#} == 0 ]]; then
    exec "bash"
else
    exec "${@}"
fi
