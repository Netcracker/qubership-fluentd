FROM fluent/fluentd:v1.18.0-debian-1.2

ENV GEM_HOME="/fluentd/vendor/bundle/ruby/3.2.0" \
    BUNDLE_VERSION="2.5.22"

ENV GEM_PATH="${GEM_HOME}" \
    PATH="${GEM_HOME}:${PATH}"

USER root

# Workaround to avoid segmentation fault in systemd plugin
# References:
# https://github.com/fluent-plugins-nursery/fluent-plugin-systemd/issues/110
# https://github.com/fluent/fluent-package-builder/issues/369#issuecomment-1275705256
ENV LD_PRELOAD=""

WORKDIR /home/fluent

COPY Gemfile* fluentd/

# Do not split this step because docker create layer per each RUN (or other keyword)
# and apt-get purge won't work in another layer
RUN \
  # The base image "fluent/fluentd:v1.18.0-debian-1.0" use the "ruby:3.2-slim-bookworm" as it base image
  # Update tools in the base image to close vulnerabilities
  apt-get update -y \
  && apt-get upgrade -y \
  # Install build dependencies for build ruby
  && buildDeps=" \
      make \
      jq \
      gcc \
      g++ \
      libc-dev \
      wget \
      bzip2 \
      gnupg \
      dirmngr \
      ruby-dev" \
  && apt-get install -y --no-install-recommends $buildDeps \
  # Install Bundle
  && gem install bundler --version "${BUNDLE_VERSION}" \
  # Configure Bundle
  && bundle config set --local path "/fluentd/vendor/bundle" \
  # Install all plugins and dependencies
  && bundle install --jobs=4 --gemfile="fluentd/Gemfile" \
  # Cleanup layer from build artifacts
  && gem sources --clear-all \
  && apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY ./entrypoint.sh /fluentd/entrypoint.sh

RUN \
# Add execute privileges for entrypoint
  chmod +x /fluentd/entrypoint.sh \
# TODO: Do we really need to create all these directories?
# Prepare general environment
  && mkdir \
    /etc/sysconfig \
    /etc/docker \
  && touch \
    /etc/sysconfig/docker \
    /etc/docker/daemon.json \
# Prepare environment for dedicated fluentd
  && mkdir \
    /fluentd/etc/conf.d/ \
    /fluentd/etc/certs/ \
    /var/log/audit/ \
    /var/log/td-agent/ \
    /var/lib/docker/ \
    /var/lib/docker/containers/ \
  && touch \
    /var/log/audit/audit.log \
    /var/log/audit/audit.log.pos \
    /var/log/td-agent/docker.log.pos \
    /var/log/messages \
    /var/log/messages.pos \
    /etc/logrotate.d/td-agent \
# Prepare environment for system logging
  && mkdir \
    /var/log/glusterfs/ \
    /var/lib/origin/ \
  && touch \
    /var/log/glusterfs.log.pos \
    /var/log/ocp-audit.log.pos \
    /var/lib/origin/ocp-audit.log

EXPOSE 24220 24224 24231

CMD /fluentd/entrypoint.sh
