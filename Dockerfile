FROM infracost/infracost:ci-latest
USER root
RUN apk add --no-cache --upgrade bash
RUN apk add jq
COPY build.sh .
COPY BP-BASE-SHELL-STEPS .
RUN chmod +x build.sh
ENV ACTIVITY_SUB_TASK_CODE BP-INFRA-COST-TASK
ENV INFRACOST_API_KEY xxxx
ENV CODE_PATH network_skeleton
ENV SLEEP_DURATION 5s
ENTRYPOINT [ "./build.sh" ]
