#!/bin/sh
set -eu

gemfile="${GEMFILE:-/home/fluent/fluentd/Gemfile}"
smoke_conf="${SMOKE_CONF:-/fluentd/etc/smoke.conf}"

ruby - "$gemfile" <<'RUBY'
gemfile = ARGV.fetch(0)
names = File.read(gemfile).scan(/^\s*gem\s+['"]([^'"]+)['"]/).flatten
abort("no gems declared in #{gemfile}") if names.empty?
missing = names.select { |name| Gem::Specification.find_all_by_name(name).empty? }
abort("missing gems: #{missing.join(', ')}") unless missing.empty?
puts "verified #{names.size} Gemfile gems"
RUBY

test -x /fluentd/entrypoint.sh
sh -n /fluentd/entrypoint.sh

fluentd --dry-run -c "${smoke_conf}" -p /fluentd/plugins

if ! command -v timeout >/dev/null 2>&1; then
    echo "timeout is unavailable; skipped entrypoint start check"
    exit 0
fi

set +e
timeout 12 sh /fluentd/entrypoint.sh
status=$?
set -e

if [ "${status}" -eq 124 ] || [ "${status}" -eq 0 ]; then
    echo "entrypoint started fluentd (status ${status})"
    exit 0
fi

echo "entrypoint failed (status ${status})" >&2
exit 1
