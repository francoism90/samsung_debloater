#!/bin/sh

export BLD="\e[01m" RED="\e[01;31m" BLU="\e[01;34m" CYA="\e[01;36m" NRM="\e[00m"
export ADB_BIN='/usr/bin/adb'
export PM_DCMD='pm disable-user --user 0'
export PM_UCMD='pm uninstall --user 0'

command -v ${ADB_BIN} >/dev/null 2>&1 || {
  echo -e "${BLD}${RED}I require adb but it's not installed. Aborting.${NRM}" >&2
  exit 1
}

init_shell() {
  ${ADB_BIN} kill-server
  ${ADB_BIN} start-server
  ${ADB_BIN} wait-for-device

  id=$(${ADB_BIN} shell getprop ro.build.id)

  echo -e "${BLD}${BLU}Device information${NRM}"
  echo -e "${BLD} ${id}${NRM}"
}

kill_shell() {
  ${ADB_BIN} kill-server
}

# Disable apps that may cause issues when being removed.
disable_apks() {
  DISABLE=(
    # Misc
    #com.hiya.star # callerID
    com.samsung.android.aircommandmanager # S Pen?
    com.samsung.android.allshare.service.fileshare # AllShare
    com.samsung.android.allshare.service.mediashare # AllShare
    com.samsung.android.app.notes # Notes
    com.samsung.android.app.simplesharing # TODO: Samsung Sharing Services?
    #com.samsung.android.app.social # Samsung Phone/Contacts
    com.samsung.android.app.taskedge # Tasks
    com.samsung.android.app.watchmanager # Samsung Wearable
    com.samsung.android.app.watchmanagerstub # Samsung Wearable
    com.samsung.android.calendar # Samsung Calendar
    com.samsung.android.kidsinstaller # Samsung Kids
    com.samsung.android.widgetapp.yahooedge.finance # Yahoo widget
    com.samsung.android.widgetapp.yahooedge.sport # Yahoo widget
    com.samsung.android.mateagent # Samsung Galaxy Friends
    #com.sec.android.app.shealth # Samsung Health
    com.sec.android.easyMover # Samsung Smart Switch Mobile
    com.sec.android.easyMover.Agent # Samsung Smart Switch Mobile
    com.sec.android.mimage.gear360editor # Samsung Gear 360
    de.axelspringer.yana.zeropage # upday
    com.sec.android.app.billing # Samsung Billing App
    com.samsung.android.email.provider # Samsung Mail

    # KNOX
    #com.knox.vpn.proxyhandler
    com.samsung.android.knox.analytics.uploader
    #com.samsung.android.knox.containeragent
    #com.samsung.android.knox.containercore
    #com.samsung.android.knox.containerdesktop
    com.sec.enterprise.knox.attestation # TODO: Enterprise only?
    com.sec.enterprise.knox.cloudmdm.smdms # TODO: Enterprise only?

    # Bixby
    com.samsung.android.app.reminder # Bixby Reminder
    com.samsung.android.app.settings.bixby # Samsung Bixby Settings
    com.samsung.android.app.spage # Bixby Home
    com.samsung.android.bixby.agent
    com.samsung.android.bixby.agent.dummy
    com.samsung.android.bixby.es.globalaction
    com.samsung.android.bixby.plmsync
    com.samsung.android.bixby.service
    com.samsung.android.bixby.wakeup
    com.samsung.android.bixbyvision.framework
    com.samsung.systemui.bixby2

    # Samsung Browser
    com.samsung.android.app.sbrowseredge
    com.sec.android.app.sbrowser

    # Input/Samsung Keyboard (WARNING: Install and setup Gboard as alternative!)
    # com.samsung.android.app.talkback # Samsung Voice Assistant
    # com.samsung.android.clipboarduiservice
    # com.samsung.android.app.clipboardedge
    # com.samsung.clipboardsaveservice
    # com.samsung.android.samsungpass # Samsung Pass
    # com.samsung.android.samsungpassautofill # Samsung Pass
    # com.sec.android.inputmethod
    # com.sec.android.inputmethod.beta
  )

  echo -e "${BLD}${CYA}Disabling apps${NRM}"
  for APP in "${DISABLE[@]}"; do
    prepare_apk ${APP}

    result=$(${ADB_BIN} shell ${PM_DCMD} ${APP})
    echo -e "${BLD} ${APP}: ${BLU}${result}${NRM}"
  done
}

# Uninstall apps that are safe* to remove.
uninstall_apks() {
  UNINSTALL=(
    # Samsung Dictionary
    com.diotek.sec.lookup.dictionary

    # Facebook
    com.facebook.appmanager
    com.facebook.katana
    com.facebook.mlite
    com.facebook.services
    com.facebook.system

    # Microsoft Skydrive
    #com.microsoft.skydrive
  )

  echo -e "${BLD}${BLU}Uninstalling apps${NRM}"
  for APP in "${UNINSTALL[@]}"; do
    prepare_apk ${APP}

    result=$(${ADB_BIN} shell ${PM_UCMD} ${APP})
    echo -e "${BLD} ${APP}: ${CYA}${result}${NRM}"
  done
}

prepare_apk() {
  # Force stop everything associated with package
  kill=$(${ADB_BIN} shell am force-stop ${1})

  # Deletes all data associated with a package
  clean=$(${ADB_BIN} shell pm clear ${1})
}

init_shell
disable_apks
uninstall_apks
kill_shell
