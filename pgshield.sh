#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705 - Deiteq
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
badinput() {
  echo
  read -p '⛔️ ERROR - Bad Input! | Press [ENTER] ' typed </dev/tty
}

badinput1() {
  echo
  read -p '⛔️ ERROR - Bad Input! | Press [ENTER] ' typed </dev/tty
  question1
}

variable() {
  file="$1"
  if [ ! -e "$file" ]; then echo "$2" >$1; fi
}

question1() {
  touch /pg/var/auth.bypass

  a7=$(cat /pg/var/auth.bypass)
  if [[ "$a7" != "good" ]]; then shieldcheck; fi
  echo good >/pg/var/auth.bypass

  touch /pg/var/pgshield.emails
  mkdir -p /pg/var/auth/

  domain=$(cat /pg/var/server.domain)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PG Shield | http://pgshield.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💬  PG Shield requires Google Web Auth Keys! Visit the link above!

[1] Set Web Client ID & Secret
[2] Authorize User(s)
[3] Protect / UnProtect PG Apps
[4] Deploy PG Shield
[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  phase1
}

phase1() {

  read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty

  case $typed in
  1)
    webid
    phase1
    ;;
  2)
    email
    phase1
    ;;
  3)
    appexempt
    phase1
    ;;
  4)
    # Sanity Check to Ensure At Least 1 Authorized User Exists
    touch /pg/var/pgshield.emails
    efg=$(cat "/pg/var/pgshield.emails")
    if [[ "$efg" == "" ]]; then
      echo
      echo "SANITY CHECK: No Authorized Users have been Added! Exiting!"
      read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
      question1
    fi

    # Sanity Check to Ensure that Web ID ran domaincheck
    file="/pg/var/auth.idset"
    if [ ! -e "$file" ]; then
      echo
      echo "SANITY CHECK: You Must @ Least Run the Web ID Interface Once!"
      read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
      question1
    fi

    # Sanity Check to Ensure Ports are closed
    touch /pg/var/server.ports
    ports=$(cat "/pg/var/server.ports")
    if [ "$ports" != "127.0.0.1:" ]; then
      echo
      echo "SANITY CHECK: Ports are open, PGShield cannot be enabled until they are closed due to security risks!"
      read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
      question1
    fi

    touch /pg/var/pgshield.compiled
    rm -r /pg/var/pgshield.compiled
    while read p; do
      echo -n "$p," >>/pg/var/pgshield.compiled
    done </pg/var/pgshield.emails

    ansible-playbook /pg/pgshield/pgshield.yml

    pgstatus=$(docker ps | grep "\<thomseddon\>" | awk '{ print $2}')
    if [[ "$pgstatus" != "" ]]; then touch /pg/var/oauth.exists
    else rm -rf /pg/var/oauth.exists; fi

    bash /pg/pgshield/rebuild.sh
    question1
    ;;
  z)
    exit
    ;;
  Z)
    exit
    ;;
  *)
    question1
    ;;
  esac
}

appexempt() {
  bash /pg/apps/_appsgen.sh
  ls -l /pg/var/auth | awk '{ print $9 }' >/pg/var/pgshield.ex15

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PG Shield ~ App Protection | http://pgshield.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Disable PGShield for a single app
2. Enable PGShield for a single app
3. Reset & Enable PGShield for all apps
Z. Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  phase3
}

phase3() {
  read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty

  case $typed in
  1)
    phase31
    appexempt
    ;;
  2)
    phase21
    appexempt
    ;;
  3)
    emptycheck=$(cat /pg/var/pgshield.ex15)
    if [[ "$emptycheck" == "" ]]; then
      echo
      read -p 'No Apps have PGShield Disabled! Exiting | Press [ENTER]'
      appexempt
    fi
    rm -rf /pg/var/auth/*
    echo ""
    echo "NOTE: Does not take effect until PG Shield is redeployed!"
    read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
    email
    appexempt
    ;;
  z)
    question1
    ;;
  Z)
    question1
    ;;
  *)
    appexempt
    ;;
  esac

}

phase31() {
  touch /pg/var/app.list
  while read p; do
    sed -i -e "/$p/d" /pg/var/app.list
  done </pg/var/pgshield.ex15

  ### Blank Out Temp List
  rm -rf /pg/var/program.temp && touch /pg/var/program.temp

  ### List Out Apps In Readable Order (One's Not Installed)
  num=0
  while read p; do
    echo -n $p >>/pg/var/program.temp
    echo -n " " >>/pg/var/program.temp
    num=$((num + 1))
    if [ "$num" == 7 ]; then
      num=0
      echo " " >>/pg/var/program.temp
    fi
  done </pg/var/app.list

  notrun=$(cat /pg/var/program.temp)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PG Shield ~ Disable Shield for an app | http://pgshield.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Apps currently protected by PGShield:

$notrun

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Z] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -p '🌍 Type APP to disable PGShield | Press [ENTER]: ' typed </dev/tty

  if [[ "$typed" == "exit" || "$typed" == "Exit" || "$typed" == "EXIT" || "$typed" == "z" || "$typed" == "Z" ]]; then appexempt; fi

  grep -w "$typed" /pg/var/program.temp >/pg/var/check55.sh
  usercheck=$(cat /pg/var/check55.sh)

  if [[ "$usercheck" == "" ]]; then
    echo
    read -p 'App does not exist! | Press [ENTER] ' note </dev/tty
    appexempt
  fi

  touch /pg/var/auth/$typed
  echo
  echo "NOTE: No effect until PGShield or the app is redeployed!"
  read -p '🌍 Acknowledge! | Press [ENTER] ' note </dev/tty
  appexempt
}

phase21() {

  emptycheck=$(cat /pg/var/pgshield.ex15)
  if [[ "$emptycheck" == "" ]]; then
    echo
    read -p 'No apps are exempt! Exiting | Press [ENTER]'
    appexempt
  fi
  ### Blank Out Temp List
  rm -rf /pg/var/program.temp && touch /pg/var/program.temp

  ### List Out Apps In Readable Order (One's Not Installed)
  num=0
  while read p; do
    echo -n $p >>/pg/var/program.temp
    echo -n " " >>/pg/var/program.temp
    num=$((num + 1))
    if [ "$num" == 7 ]; then
      num=0
      echo " " >>/pg/var/program.temp
    fi
  done </pg/var/pgshield.ex15

  notrun=$(cat /pg/var/program.temp)

  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PG Shield ~ Enable Shield for an app | http://pgshield.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Apps NOT currently protected by PGShield:

$notrun

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Z] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -p '🌍 Type app to enable PGShield | Press [ENTER]: ' typed </dev/tty

  if [[ "$typed" == "exit" || "$typed" == "Exit" || "$typed" == "EXIT" || "$typed" == "z" || "$typed" == "Z" ]]; then appexempt; fi

  grep -w "$typed" /pg/var/pgshield.ex15 >/pg/var/check55.sh
  usercheck=$(cat /pg/var/check55.sh)

  if [[ "$usercheck" == "" ]]; then
    echo
    read -p 'App does not exist! | Press [ENTER] ' note </dev/tty
    appexempt
  fi

  rm -rf /pg/var/auth/$typed
  echo
  echo "NOTE: No effect until PG Shield or the app is redeployed!"
  read -p '🌍 Acknoweldge! | Press [ENTER] ' note </dev/tty
  appexempt
}

webid() {
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔑 Google Web Keys - Client ID       📓 Reference: pgshield.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NOTE: Visit reference for Google Web Auth Keys

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Z] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  read -p '↘️  Web Client ID     | Press [Enter]: ' public </dev/tty
  if [ "$public" = "exit" ]; then question1; fi
  echo "$public" >/pg/var/shield.clientid

  read -p '↘️  Web Client Secret | Press [Enter]: ' secret </dev/tty
  if [ "$secret" = "exit" ]; then question1; fi
  echo "$secret" >/pg/var/shield.clientsecret

  echo ""
  read -p '🔑 Client ID & Secret Set |  Press [ENTER] ' public </dev/tty
  touch /pg/var/auth.idset
  question1
}

email() {
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PG Shield ~ Trusted Users | http://pgshield.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. E-Mail: Add User
2. E-Mail: Remove User
3. E-Mail: View Authorization List
4. E-Mail: Remove All Users (Stops PG Shield)
Z. Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
  phase2
}

phase2() {

  read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty

  case $typed in
  1)
    echo
    read -p 'User Email to Add | Press [ENTER]: ' typed </dev/tty

    emailcheck=$(echo $typed | grep "@")
    if [[ "$emailcheck" == "" ]]; then
      read -p 'Invalid E-Mail! | Press [ENTER] ' note </dev/tty
      email
    fi

    usercheck=$(cat /pg/var/pgshield.emails | grep $typed)
    if [[ "$usercheck" != "" ]]; then
      read -p 'User Already Exists! | Press [ENTER] ' note </dev/tty
      email
    fi
    read -p 'User Added | Press [ENTER] ' note </dev/tty
    echo "$typed" >>/pg/var/pgshield.emails
    email
    ;;
  2)
    echo
    read -p 'User Email to Remove | Press [ENTER]: ' typed </dev/tty
    testremove=$(cat /pg/var/pgshield.emails | grep $typed)
    if [[ "$testremove" == "" ]]; then
      read -p 'User does not exist | Press [ENTER] ' typed </dev/tty
      email
    fi
    sed -i -e "/$typed/d" /pg/var/pgshield.emails
    echo ""
    echo "NOTE: Does not take effect until PG Shield is redeployed!"
    read -p 'Removed User | Press [ENTER] ' typed </dev/tty
    email
    email
    ;;
  3)
    echo
    echo "Current Authorized E-Mail Addresses"
    echo ""
    cat /pg/var/pgshield.emails
    echo
    read -p 'Finished? | Press [ENTER] ' typed </dev/tty
    email
    email
    ;;
  4)
    test=$(cat /pg/var/pgshield.emails | grep "@")
    if [[ "$test" == "" ]]; then email; fi
    docker stop oauth
    rm -r /pg/var/pgshield.emails
    touch /pg/var/pgshield.emails
    echo
    docker stop oauth
    read -p 'All Prior Users Removed! | Press [ENTER] ' typed </dev/tty
    email
    ;;
  z)
    question1
    ;;
  Z)
    question1
    ;;
  *)
    email
    ;;
  esac
}

shieldcheck() {
  domaincheck=$(cat /pg/var/server.domain)
  touch /pg/var/server.domain
  touch /tmp/portainer.check
  rm -r /tmp/portainer.check
  cname="portainer"
  if [[ -f "/pg/var/portainer.cname" ]]; then
    cname=$(cat "/pg/var/portainer.cname")
  fi

  wget -q "https://${cname}.${domaincheck}" -O /tmp/portainer.check
  domaincheck=$(cat /tmp/portainer.check)
  if [ "$domaincheck" == "" ]; then

    tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️  PG Shield ~ Unable to talk to Portainer | pgshield.pgblitz.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Did you forget to enable Traefik?"
2. Valdiate if the portainer subdomain is working?"
3. Validate Portainer is deployed?"
4. oauth.${domain} cname in your DNS? (CloudFlare Users)"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    read -p 'Acknowledge Info | Press [ENTER] ' typed </dev/tty
    exit
  fi
}

question1
