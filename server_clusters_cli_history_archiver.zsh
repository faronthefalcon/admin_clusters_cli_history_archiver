#!/bin/zsh


if ! command -v uuidgen >/dev/null 2>&1; then
  sudo apt install uuid-runtime
fi
__CONFIRM_UUID=$(uuidgen)


fs.history.cleanup() {
  LOCATION="${HOME}/.bin/history"
  DISCARD="${LOCATION}/discard"
  CONCAT="${LOCATION}/File_$(uuidgen)"

  mkdir -p "$DISCARD"

  # Concatenate all files except CONCAT and discard into one
  find "$LOCATION" -maxdepth 1 -type f ! -name "$(basename "$CONCAT")" ! -name "discard" -print0 |
    xargs -0 cat >> "$CONCAT"

  # Move all originals (except CONCAT and discard) into discard folder
  find "$LOCATION" -maxdepth 1 -type f ! -name "$(basename "$CONCAT")" ! -name "discard" -print0 |
    xargs -0 -I{} mv "{}" "$DISCARD"

  # Sort the result into a new archive
  ARCHIVE="$LOCATION/history_$(uuidgen)"
  sort -t ':' -k2,2n "$CONCAT" | uniq >  "$ARCHIVE"

  rm -f "$CONCAT"

  echo "Archive created: $ARCHIVE"
}



fs.history.send() { 

  if [[ ! "$(hostname -s)" == "f5" ]] ; then 
    return 1
  fi

  servers=(srv1 srv2 srv3 srv4)
  hosts=(f7 f9)
  domainset="signavision.ca"

  for server in "${servers[@]}"; do
    DESTINATION="${server}.${domainset}:~/"
    scp "$HOME/.zsh_history" "$DESTINATION"
    rsync -av --update "${HOME}/.bin/history" "${server}.${domainset}:~/.bin/history/"
    echo "Added history to $server"
  done

  for host in "${hosts[@]}"; do
    DESTINATION="${host}:~/"
    scp "$HOME/.zsh_history" "${DESTINATION}"
    rsync -av --update "${HOME}/.bin/history" "${host}:~/.bin/history/"
    echo "Added history to ${host}"
  done
  echo "success! All history sent to servers and hosts"

}





function fs.collect.history() {
  FRABFILE=".zsh_history"
  MASTER="/tmp/totalhistory"

  # Start fresh every run
  : > "$MASTER"

  # Always add your own local history first
  cp "$HOME/.zsh_history" "$MASTER"

  servers=(srv1 srv2 srv3 srv4)
  hosts=(f7 f9)
  domainset="signavision.ca"

  for server in "${servers[@]}"; do
    DESTINATION="${server}.${domainset}:~/${FRABFILE}"
    scp "$DESTINATION" "/tmp/$FRABFILE"
    echo "Collected history from $server"
    cat "/tmp/$FRABFILE" >> "$MASTER"
    echo "Added history from $server to master file"
  done

  for host in "${hosts[@]}"; do
    DESTINATION="${host}:~/${FRABFILE}"
    scp "$DESTINATION" "/tmp/$FRABFILE"
    echo "Collected history from $host"
    cat "/tmp/$FRABFILE" >> "$MASTER"
    echo "Added history from $host to master file"
  done

  # Ensure archive dir exists
  if [[ ! -d "$HOME/.bin/history" ]]; then
    mkdir -p "$HOME/.bin/history"
  fi

  # Split into archive and active
  cat "$MASTER" | sort -t ':' -k2,2n | uniq  |  head -n -400 > "$HOME/.bin/history/zsh_history-$(date +'%Y-%m-%d_%H-%M-%S')"
  cat "$MASTER" | sort -t ':' -k2,2n | uniq |  tail -n 400 > "$HOME/.zsh_history"

  # Optionally remove temp files
  # rm -f /tmp/$FRABFILE "$MASTER"

  echo "success! All history caught up"

  fs.history.cleanup

  fs.history.send

}




fs.find.history() {
    CACHE="$HOME/.bin/history"
    grep -r --color=auto -i "$@" "$CACHE"
}






fs.history.evaluate() { 

  CHECKFILE="$( wc -l $HOME/.zsh_history | awk '{print $1}' )"
  if [[ ${CHECKFILE} -gt 1000 ]]; then 
    echo "Cleaning history..."
    fs.collect.history 
  fi




  fs.history.send

}


