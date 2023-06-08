#!/bin/bash

source  functions.sh
source  log-functions.sh
source  str-functions.sh
source  file-functions.sh
source  aws-functions.sh

code="$WORKSPACE/$CODEBASE_DIR"
echo "${code}/${CODE_PATH}"

logInfoMessage "I'll share infra cost"
sleep $SLEEP_DURATION
logInfoMessage "Executing command"
logInfoMessage "Calculatig Cost !!!"

cd $code/${CODE_PATH}
output=`infracost breakdown --path .`
echo "${output}"

