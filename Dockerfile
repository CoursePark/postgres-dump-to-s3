FROM alpine

# curl for S3 upload
# openssl for S3 upload
# postgresql for pg_dump
RUN apk --no-cache add curl openssl postgresql

COPY action.sh /

RUN chmod +x action.sh

CMD echo "$PG_TO_S3_CRON_MINUTE $PG_TO_S3_CRON_HOUR * * * /action.sh" > /var/spool/cron/crontabs/root && crond -d 8 -f
