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

add_event "INITIALIZATION" "Successful" \
      "Task initialization completed" \
      "Target Path: ${code}/${CODE_PATH}"

logInfoMessage "Executing command"
logInfoMessage "Calculatig Cost !!!"

if [[ -z "${INFRACOST_API_KEY}" ]]; then
    logErrorMessage "Infracost API key not found."
    logErrorMessage "Please set INFRACOST_API_KEY environment variable"
    add_event "API KEY VALIDATION" "Failed" \
          "Infracost API key missing" \
          "Set INFRACOST_API_KEY in environment"
    exit 1
fi

add_event "API KEY VALIDATION" "Successful" \
      "Infracost API key found" \
      "Authentication ready"


TARGET_DIR="$code/${CODE_PATH}"

if [[ ! -d "$TARGET_DIR" ]]; then
    logErrorMessage "Directory does not exist: $TARGET_DIR"
    add_event "WORKSPACE NAVIGATION" "Failed" \
          "Directory not found" \
          "Path: $TARGET_DIR"
    exit 1
else
    if cd "$TARGET_DIR"; then
        logInfoMessage "Changed directory to $TARGET_DIR"
        add_event "WORKSPACE NAVIGATION" "Successful" \
              "Successfully navigated to target directory" \
              "Path: $TARGET_DIR"
    else
        logErrorMessage "Failed to change directory to $TARGET_DIR"
        add_event "WORKSPACE NAVIGATION" "Failed" \
              "Failed to change directory" \
              "Path: $TARGET_DIR"
        exit 1
    fi
fi

output=`infracost breakdown --path .`

echo "${output}"

TASK_STATUS=$?

if [ "$TASK_STATUS" -eq 0 ]; then
    add_event "COST CALCULATION" "Successful" \
          "Infrastructure cost breakdown generated" \
          "Scan completed successfully"
else
    add_event "COST CALCULATION" "Failed" \
          "Failed to generate cost breakdown" \
          "Check Infracost logs for details"
fi

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
add_event "TASK EXECUTION" "Successful" \
      "Infra cost task completed" \
      "Status: $( [ $TASK_STATUS -eq 0 ] && echo "Success" || echo "Failure" )"

