#!/bin/bash
HUB=${2:-astroconda}
PROJECT=${HUB}/datb-tc-pipeline-nb
PROJECT_VERSION="${1}"
TAGS=()
image_tag="${PROJECT_VERSION}"

if [[ -z ${PROJECT_VERSION} ]]; then
    echo "Pipeline version required [e.g. hstdp-snapshot, hstdp-2018.3_py###]"
    exit 1
fi

case "${HUB}" in
    *amazonaws\.com)
        if ! type -p aws; then
            echo "awscli client not installed"
            exit 1
        fi
        REGION="$(awk -F'.' '{print $(NF-2)}' <<< ${HUB})"
        $(aws ecr get-login --no-include-email --region ${REGION})
        unset REGION
        ;;
    *)
        # Assume default index
        docker login
        ;;
esac
set -x

TAGS+=( "-t ${PROJECT}:${image_tag}" )
PIPELINE="${PROJECT_VERSION}"
docker build ${TAGS[@]} \
    --build-arg HUB="${HUB}" \
    --build-arg PIPELINE="${PROJECT_VERSION}" \
    .

rv=$?
if (( rv > 0 )); then
    echo "Failed... Image not published"
    exit ${rv}
fi


max_retry=4
retry=0
set +e
while (( retry != max_retry ))
do
    echo "Push attempt #$(( retry + 1 ))"
    docker push "${PROJECT}:${image_tag}"
    rv=$?
    if [[ ${rv} == 0 ]]; then
        break
    fi
    (( retry++ ))
done

exit ${rv}
