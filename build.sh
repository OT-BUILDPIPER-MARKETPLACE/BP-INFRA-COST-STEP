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

cd $code/${CODE_PATH}

output=`infracost breakdown --path .`

echo "${output}"

