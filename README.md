# Qubership FluentD

* [Qubership FluentD](#qubership-fluentd)
  * [Documentation](#documentation)
  * [Installed plugins](#installed-plugins)
  * [Contribute](#contribute)
    * [Why do we use a bundler?](#why-do-we-use-a-bundler)
  * [How to build](#how-to-build)
    * [Local build](#local-build)
  * [Update dependencies in Gemfile.lock](#update-dependencies-in-gemfilelock)

This is a custom FluentD image with additional installed plugins.

Based on FluentD vanilla image (Debian based):

* Image

  ```bash
  fluent/fluentd:v1.18.0-debian-1.0
  ```

* Image on Docker Hub - [https://hub.docker.com/r/fluent/fluentd/](https://hub.docker.com/r/fluent/fluentd/)
* Original Dockerfile on GitHub - [https://github.com/fluent/fluentd-docker-image/tree/master/v1.16/debian](https://github.com/fluent/fluentd-docker-image/tree/master/v1.18/debian)

## Documentation

Official documentation about configuration and default plugins can be found by link
[https://docs.fluentd.org/](https://docs.fluentd.org/)

## Installed plugins

The actual list of installed plugins in the custom image always can be found in the `Gemfile`.

Input plugins:

* [fluent-plugin-input-gelf >= 0.3.2](https://github.com/MerlinDMC/fluent-plugin-input-gelf)
* [fluent-plugin-systemd >= 1.0.5](https://github.com/fluent-plugins-nursery/fluent-plugin-systemd)

Filter and parse plugins:

* [fluent-plugin-concat >= 2.5.0](https://github.com/fluent-plugins-nursery/fluent-plugin-concat)
* [fluent-plugin-detect-exceptions >= 0.0.14'](https://github.com/GoogleCloudPlatform/fluent-plugin-detect-exceptions)
* [fluent-plugin-fields-parser >= 0.1.2](https://github.com/tomas-zemres/fluent-plugin-fields-parser)
* [fluent-plugin-filter-docker_metadata >= 0.0.1](https://github.com/fabric8io/fluent-plugin-docker_metadata_filter)
* [fluent-plugin-kubernetes_metadata_filter >= 3.1.3](https://github.com/fabric8io/fluent-plugin-kubernetes_metadata_filter)
* [fluent-plugin-multi-format-parser >= 1.0.0](https://github.com/repeatedly/fluent-plugin-multi-format-parser)
* [fluent-plugin-record-modifier >= 2.1.1](https://github.com/repeatedly/fluent-plugin-record-modifier)
* [fluent-plugin-rewrite-tag-filter >= 2.4.0](https://github.com/fluent/fluent-plugin-rewrite-tag-filter)

Output plugins:

* [fluent-plugin-gelf-hs >= 1.0.8](https://github.com/hotschedules/fluent-plugin-gelf-hs)
* [fluent-plugin-grafana-loki ~> 1.0](https://github.com/grafana/loki/tree/main/clients/cmd/fluentd)
* [fluent-plugin-kafka >= 0.19.1](https://github.com/fluent/fluent-plugin-kafka)
* [fluent-plugin-prometheus >= 2.0.3](https://github.com/fluent/fluent-plugin-prometheus)
* [fluent-plugin-remote_syslog >= 1.1.0](https://github.com/fluent-plugins-nursery/fluent-plugin-remote_syslog)
* [fluent-plugin-s3 >= 1.7.2](https://github.com/fluent/fluent-plugin-s3)
* [fluent-plugin-secure-forward >= 0.4.5](https://github.com/tagomoris/fluent-plugin-secure-forward)
* [fluent-plugin-splunk-hec >= 1.3.2](https://github.com/splunk/fluent-plugin-splunk-hec)
* [fluent-plugin-syslog_rfc5424 >= 0.8.0](https://github.com/cloudfoundry/fluent-plugin-syslog_rfc5424)

## Contribute

You **must** update `Gemfile.lock` if you want to add or update the plugin for FluentD,
or make other changes that will relate to Ruby dependencies.

Other changes in the repository or build image don't require updating `Gemfile.lock`.

How to install `ruby`, build locally and update `Gemfile.lock` you can read in the section
[Local build](#local-build).

### Why do we use a bundler?

Why do we use a `bundler` although the original FluentD docker image installs all dependencies
using a simple `gem install ...`?

We are using it to reduce build time, freeze and minimize the list of downloaded dependencies.
But the main purpose is a build time.

You can compare it:

* Without using a `bundler` (using `gem install ...`) the average build time is 30-50 minutes
* With using a `bundler` the average build time is 3-4 minutes

## How to build

### Local build

To build FluentD in the local environment you should have the following tools:

* [`ruby >= 3`](https://www.ruby-lang.org/)
* [`bundler >=2.4.19`](https://bundler.io/)

**Note:** Recommended use the WSL2.

**Warning!** Currently, `ruby 3.x` can't be installed on the `Ubuntu 22.04`.
Issue [https://github.com/rvm/rvm/issues/5209](https://github.com/rvm/rvm/issues/5209).
As a workaround, you can use the following commands:

```bash
rvm pkg install openssl
rvm install ruby-3 --with-openssl-dir=$HOME/.rvm/usr
```

To install Ruby you can use an [RVM](https://rvm.io/).

Next, you need to install Ruby using `rvm`:

```bash
rvm list known
rvm install ruby-3
```

Next, install `bundler`:

```bash
gem install bundler
```

After that, you can install all Ruby dependencies and/or update `Gemfile.lock`.
To install all dependencies you can run:

```bash
bundle install --jobs=4
```

## Update dependencies in Gemfile.lock

To update dependencies you first of all need to install `ruby` and `bundler` as described in the section
[Local build](#local-build).

Next, to update dependencies (and create or update `Gemfile.lock` file) you can run the following command:

```bash
bundle update
```

and next:

```bash
bundle lock
```
