#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
docker ps -a --format "{{.Names}}" >/pg/var/container.running

chown 1000:1000 -R /pg/apps
chmod 0755 -R /pg/apps

sed -i -e "/traefik/d" /pg/var/container.running
sed -i -e "/oauth/d" /pg/var/container.running
sed -i -e "/watchtower/d" /pg/var/container.running
sed -i -e "/wp-*/d" /pg/var/container.running
sed -i -e "/plex/d" /pg/var/container.running
sed -i -e "/jellyfin/d" /pg/var/container.running
sed -i -e "/emby/d" /pg/var/container.running
sed -i -e "/x2go*/d" /pg/var/container.running
sed -i -e "/authclient/d" /pg/var/container.running
sed -i -e "/dockergc/d" /pg/var/container.running

count=$(wc -l </pg/var/container.running)
((count++))
((count--))

tee <<-EOF

	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	⚠️  PG Shield - Rebuilding Containers!
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
sleep 1.5
for ((i = 1; i < $count + 1; i++)); do
	app=$(sed "${i}q;d" /pg/var/container.running)

	tee <<-EOF

		━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		↘️  PG Shield - Rebuilding [$app]
		━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

	EOF
	echo "$app" >/tmp/program_var
	sleep .5

	if [ -e "/pg/apps/programs/$app/start.sh" ]; then /pg/apps/programs/$app/start.sh; fi
done

echo ""
tee <<-EOF
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	✅️  PG Shield - All Containers Rebuilt!
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
read -p 'Continue? | Press [ENTER] ' name </dev/tty
