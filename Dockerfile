FROM alpine:3.6

ENV PUPPET_VERSION="5.3.2" \
	  FACTER_VERSION="2.5.1" \
    CONFIG_DIR="/var/docker/conf" \
    LOGS_DIR="/var/docker/logs"

ENV PUPPET_CONFIG=${CONFIG_DIR}"/puppetagent.config" \
	  SUPERVISORCONF=${CONFIG_DIR}"/supervisord.conf"

LABEL org.label-schema.author="xxx@xxx.com" \
      org.label-schema.vendor="Puppet/Bind" \
      org.label-schema.name="Puppet Agent/Bind (Alpine)" \
      org.label-schema.version=$PUPPET_VERSION \
      org.label-schema.build-date="2017-12-28 12:40" \
      org.label-schema.schema-version="1.0" \
      com.puppet.dockerfile="/Dockerfile"

RUN apk add --update \
    ca-certificates \
    pciutils \
    ruby \
    ruby-irb \
    ruby-rdoc \
	  bind \
	  python \
	  py-pip \
	  && pip install supervisor \
	  && mkdir -p ${LOGS_DIR} ${CONFIG_DIR} \
    && apk add --update shadow \
    && rm -rf /var/cache/apk/* \
    && rm -rf /etc/bind/* \
    && adduser bind -D

RUN gem install puppet:"$PUPPET_VERSION" facter:"$FACTER_VERSION" \
    && /usr/bin/puppet module install puppetlabs-apk

# Supervisord config
COPY supervisord.conf $SUPERVISORCONF

# Anonymouse volume
VOLUME ["/var/docker", "/etc/bind", "/var/lib/bind"]

ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/bin/sh","/entrypoint.sh"]
EXPOSE 53

COPY Dockerfile /
# test cli command
# docker run -it --name dns --env PUPPET_SERVER_IP=xx.xx.xx.xx --env PUPPET_SERVER_HOSTNAME=puppet --env PUPPET_CERTNAME=test \
  -p 53:53/tcp -p 53:53/udp -v /volume1/docker/dns/bind/etc:/etc/bind -v /volume1/docker/dns/bind/db:/var/lib/bind \
  -v /volume1/docker/dns/logs:/var/docker/logs [--entrypoint /bin/sh] <container>
