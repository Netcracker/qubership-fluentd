#/bin/sh

sysconfig_driver=$(cat /etc/sysconfig/docker | grep -Eo 'log-driver=[a-z,-]*' | tail -1)
daemon_driver=$(cat /etc/docker/daemon.json | grep '"log-driver"\s*:\s*"[a-z,-]*"')
driver="json-file"

if [ "${sysconfig_driver}" = "null" ]; then
  sysconfig_driver=""
fi

if [ "${daemon_driver}" = "null" ]; then
  daemon_driver=""
fi

echo "Log-driver from sysconfig: ${sysconfig_driver}"
echo "Log-driver from daemon.json: ${daemon_driver}"

if [ ! -z "${sysconfig_driver}" ] && [ ! -z "${daemon_driver}" ]; then
  >&2 echo "[ERROR] the log-driver found in both config files (/etc/sysconfig/docker, /etc/docker/daemon.json)"
  exit 1;
elif [ -z "${sysconfig_driver}" ] && [ ! -z "${daemon_driver}" ] && [ -z "$(echo $daemon_driver | grep $driver)" ]; then
  >&2 echo "[ERROR] the log-driver in /etc/docker/daemon.json doesn't match json-file"
  exit 1;
elif [ ! -z "${sysconfig_driver}" ] && [ -z "${daemon_driver}" ] && [ -z "$(echo $sysconfig_driver | grep $driver)" ]; then
  >&2 echo "[ERROR] the log-driver in /etc/sysconfig/docker doesn't match json-file"
  exit 1;
fi

fluentd -c /fluentd/etc/fluent.conf -p /fluentd/plugins
