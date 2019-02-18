#!/bin/bash
set -vxe
if [[ "${@}" == bash* ]]; then
    exec "${@}"
fi

if [[ -n ${JUPYTER_API_TOKEN} ]]; then
    exec jupyterhub-singleuser --ip=0.0.0.0 "${@}"
elif [[ -n ${JUPYTER_ENABLE_LAB} ]]; then
    exec jupyter labhub --ip=0.0.0.0 "${@}"
else
    exec jupyter notebook --ip=0.0.0.0 "${@}"
fi
