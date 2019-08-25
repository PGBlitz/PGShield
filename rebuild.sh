#!/bin/bash
#
# [Rebuilding Containers]
#
# GitHub:   https://github.com/PGBlitz/PGBlitz.com
# Author:   Admin9705 - Deiteq
# URL:      https://pgblitz.com
#
# PGBlitz Copyright (C) 2018 PGBlitz.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################
docker ps -a --format "{{.Names}}" >/pg/var/container.running

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
	sleep 1.5

	if [ -e "/pg/apps/programs/$app/start.sh" ]; then /pg/apps/programs/$app/start.sh; fi
done

echo ""
tee <<-EOF
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	✅️  PG Shield - All Containers Rebuilt!
	━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
read -p 'Continue? | Press [ENTER] ' name </dev/tty
