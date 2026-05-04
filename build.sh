#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh

code="$WORKSPACE/$CODEBASE_DIR"

# 1. Initialization Phase
logInfoMessage "> Initiating Infracost breakdown process..."
logInfoMessage "> Target path: ${code}/${CODE_PATH}"
logInfoMessage "> I'll share infra cost"

sleep $SLEEP_DURATION

add_event "INITIALIZATION" "Successful" \
    "Task initialization completed" \
    "Target Path: ${code}/${CODE_PATH}"

# 2. API Key Validation
logInfoMessage "> Validating Infracost API key..."

if [[ -z "${INFRACOST_API_KEY}" ]]; then
    logErrorMessage "> Infracost API key not found"
    logErrorMessage "> Please set INFRACOST_API_KEY environment variable"
    add_event "API_KEY_VALIDATION" "Failed" \
        "Infracost API key missing" \
        "Set INFRACOST_API_KEY in environment"
    saveTaskStatus 1 ${ACTIVITY_SUB_TASK_CODE}
    exit 1
fi

logInfoMessage "> Infracost API key found - Authentication ready"
add_event "API_KEY_VALIDATION" "Successful" \
    "Infracost API key found" \
    "Authentication ready"

# 3. Directory Navigation
TARGET_DIR="$code/${CODE_PATH}"
logInfoMessage "> Navigating to target directory: ${TARGET_DIR}"

if [[ ! -d "$TARGET_DIR" ]]; then
    logErrorMessage "> Directory does not exist: ${TARGET_DIR}"
    add_event "DIRECTORY_ACCESS" "Failed" \
        "Directory not found" \
        "Path: ${TARGET_DIR}"
    saveTaskStatus 1 ${ACTIVITY_SUB_TASK_CODE}
    exit 1
fi

if cd "$TARGET_DIR"; then
    logInfoMessage "> Changed directory to ${TARGET_DIR}"
    add_event "DIRECTORY_ACCESS" "Successful" \
        "Successfully navigated to target directory" \
        "Path: ${TARGET_DIR}"
else
    logErrorMessage "> Failed to change directory to ${TARGET_DIR}"
    add_event "DIRECTORY_ACCESS" "Failed" \
        "Failed to change directory" \
        "Path: ${TARGET_DIR}"
    saveTaskStatus 1 ${ACTIVITY_SUB_TASK_CODE}
    exit 1
fi

# 4. Cost Calculation
logInfoMessage "> Executing Infracost breakdown..."
logInfoMessage "> Calculating Cost !!!"

add_event "COST_CALCULATION_INITIATION" "Successful" \
    "Infracost breakdown started" \
    "Path: ${TARGET_DIR}"

output=$(infracost breakdown --path .)
TASK_STATUS=$?

echo "${output}"

logInfoMessage "> Infracost exit code: ${TASK_STATUS}"

# parse total cost from output
# AFTER
MONTHLY_COST=$(echo "$output" | grep -i "OVERALL TOTAL" | awk '{print $NF}' | tail -1)
MONTHLY_COST=${MONTHLY_COST:-"N/A"}

# print summary table
echo ""
echo "> Infracost Summary"
printf '+%-25s+%-45s+\n' '-------------------------' '---------------------------------------------'
printf '| %-23s | %-43s |\n' "Parameter" "Value"
printf '+%-25s+%-45s+\n' '-------------------------' '---------------------------------------------'
printf '| %-23s | %-43s |\n' "Scan Path" "${TARGET_DIR}"
printf '+%-25s+%-45s+\n' '-------------------------' '---------------------------------------------'
printf '| %-23s | %-43s |\n' "Exit Code" "${TASK_STATUS}"
printf '+%-25s+%-45s+\n' '-------------------------' '---------------------------------------------'
echo ""

# 5. Result Phase
if [ "$TASK_STATUS" -eq 0 ]; then
    logInfoMessage "> Infrastructure cost breakdown generated successfully"
    add_event "COST_CALCULATION" "Successful" \
        "Infrastructure cost breakdown generated" \
        "Monthly Cost: ${MONTHLY_COST} | Scan completed successfully"
else
    logErrorMessage "> Failed to generate infrastructure cost breakdown"
    add_event "COST_CALCULATION" "Failed" \
        "Failed to generate cost breakdown" \
        "Check Infracost logs for details"
fi

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}

TASK_LABEL=$( [ $TASK_STATUS -eq 0 ] && echo "Success" || echo "Failure" )
logInfoMessage "> Task completed with status: ${TASK_LABEL}"

add_event "TASK_EXECUTION" "Successful" \
    "Infra cost task completed" \
    "Status: ${TASK_LABEL}"