FROM alpine

# python for aws-cli, for s3 uploading
# postgresql for pg_dump
RUN apk --no-cache add postgresql python py-pip && \
	pip install awscli && \
	apk --purge -v del py-pip

COPY action.sh /

RUN chmod +x action.sh

CMD echo "${CRON_MINUTE:-$(shuf -i 0-59 -n1)} ${CRON_HOUR:-*} * * * /action.sh" > /var/spool/cron/crontabs/root && crond -d 8 -f
