#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh


code="$WORKSPACE/$CODEBASE_DIR"
logInfoMessage "${code}/${CODE_PATH}"

logInfoMessage "I'll share infra cost"

sleep $SLEEP_DURATION

logInfoMessage "Executing command"
logInfoMessage "Calculatig Cost !!!"

if [[ -z "${INFRACOST_API_KEY}" ]]; then
    logErrorMessage "Infracost API key not found."
    logErrorMessage "Please set INFRACOST_API_KEY environment variable"
    exit 1
fi


TARGET_DIR="$code/${CODE_PATH}"

if [[ ! -d "$TARGET_DIR" ]]; then
    logErrorMessage "Directory does not exist: $TARGET_DIR"
    exit 1
else
    if cd "$TARGET_DIR"; then
        logInfoMessage "Changed directory to $TARGET_DIR"
    else
        logErrorMessage "Failed to change directory to $TARGET_DIR"
        exit 1
    fi
fi

output=`infracost breakdown --path .`

echo "${output}"

TASK_STATUS=$?
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}

