#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
touch /var/plexguide
if [[ $(docker ps | grep oauth) == "" ]]; then
  echo null >/pg/var/auth.var
else
  echo good >/pg/var/auth.var
fi
