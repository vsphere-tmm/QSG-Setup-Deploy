COMPUTER_NAME=$(/usr/sbin/scutil --get ComputerName)
NBACKUPS=$(/usr/bin/tmutil listbackups |
      /usr/bin/grep /$COMPUTER_NAME/ |
      /usr/bin/wc -l)
OLDEST_BACKUP=$(/usr/bin/tmutil listbackups |
      /usr/bin/grep /$COMPUTER_NAME/ |
      /usr/bin/head -n1)
LATEST_BACKUP=$(/usr/bin/tmutil latestbackup)
echo Latest backup: $LATEST_BACKUP
if [[ -n "$LATEST_BACKUP" && "$LATEST_BACKUP" != "$OLDEST_BACKUP" ]]
then
  echo -n "$NBACKUPS backups. Delete oldest: ${OLDEST_BACKUP##*/} [y/N]? "
  read answer
  case $answer in
  y*)
    echo Running: /usr/bin/sudo /usr/bin/tmutil delete "$OLDEST_BACKUP"
    /usr/bin/sudo /usr/bin/tmutil delete "$OLDEST_BACKUP"
    ;;
  *)
    echo No change
    ;;
  esac
else
  echo "No backup available for deletion"
fi