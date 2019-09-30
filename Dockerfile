ARG alpine_version
FROM alpine:${alpine_version}

ARG alpine_version
ARG pg_package_version

#--------------------------------------------------------------------------------
# Install dependencies
#--------------------------------------------------------------------------------
# "postgresql" is required for "pg_restore"
# "py-pip" is required for "aws-cli"
#--------------------------------------------------------------------------------
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${alpine_version}/main" >> /etc/apk/repositories

RUN apk --no-cache --update add dumb-init postgresql=${pg_package_version} curl python3 && \
	curl https://bootstrap.pypa.io/get-pip.py | python3 && \
	pip install awscli && \
	rm -f /usr/bin/pip && \
	apk --purge -v del curl

#--------------------------------------------------------------------------------
# Set script permissions and create required directories
#--------------------------------------------------------------------------------
COPY action.sh /
RUN chmod +x action.sh

#--------------------------------------------------------------------------------
# Use the `dumb-init` init system (PID 1) for process handling
#--------------------------------------------------------------------------------
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

#--------------------------------------------------------------------------------
# Configure and apply a cronjob
#--------------------------------------------------------------------------------
CMD echo "${CRON_MINUTE:-$(shuf -i 0-59 -n1)} ${CRON_HOUR:-*} * * * /action.sh" > /var/spool/cron/crontabs/root && crond -d 8 -f
