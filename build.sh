#!/bin/bash
PROJECT=astroconda/pipeline-nb
PIPELINE="${1}"
if [[ -z ${PIPELINE} ]]; then
    echo "Need a pipeline verison [i.e. hstdp-2018.3a_py###]"
    exit 1
fi
docker build --pull -t ${PROJECT}:${PIPELINE} \
       --build-arg PIPELINE=${PIPELINE} \
       .
