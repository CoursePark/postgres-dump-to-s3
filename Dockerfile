FROM alpine

ARG pg_alpine_branch
ARG pg_version

# python for aws-cli, for s3 uploading
RUN apk --no-cache add python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip

# postgresql for pg_dump
RUN echo "http://dl-cdn.alpinelinux.org/alpine/${pg_alpine_branch}/main" >> /etc/apk/repositories
RUN echo ${pg_version}; apk --no-cache add postgresql=${pg_version}

COPY action.sh /
RUN chmod +x action.sh

CMD echo "${CRON_MINUTE:-$(shuf -i 0-59 -n1)} ${CRON_HOUR:-*} * * * /action.sh" > /var/spool/cron/crontabs/root && crond -d 8 -f
