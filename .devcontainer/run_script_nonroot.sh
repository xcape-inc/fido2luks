#!/bin/bash
set -e
trap 'catch $? $LINENO' ERR
catch() {
  echo "Error $1 occurred on $2"
}
PARAMS=$1
if [[ "${PARAMS}" == '' ]]; then
  echo 'Script requires parameters'; false
fi
set -euo pipefail
PARAMS=("$@")
if [[ "${#PARAMS[@]}" -gt 1 ]]; then
  NEW_UID="${PARAMS[1]}"
fi
if [[ "${#PARAMS[@]}" -gt 2 ]]; then
  NEW_GID="${PARAMS[2]}"
fi

BASH_SCRIPT_CONTENTS="${PARAMS[0]}"
BASH_SCRIPT_PATH="${PARAMS[3]:-/tmp/bash.script}"

rm -f "${BASH_SCRIPT_PATH}"

printf '%s' "#!/bin/bash -i
set -e
trap 'catch \$? \$LINENO' ERR
catch() {
  echo \"Error \$1 occurred on \$2\"
}

set -euo pipefail
${BASH_SCRIPT_CONTENTS}" > "${BASH_SCRIPT_PATH}"
chmod 777 "${BASH_SCRIPT_PATH}"
username=$(ls /home)

# change the uid for the user if requested
if [[ -n "${NEW_UID:-}" ]]; then
  usermod -u "${NEW_UID}" "${username}"
fi
# change the gid for the user if requested
if [[ -n "${NEW_GID:-}" ]]; then
  groupmod -g "${NEW_GID}" "${username}"
fi
# change ownership of the home and cargo directories and contents if uid or gid have changed
if [[ -n "${NEW_UID:-}" || -n "${NEW_GID:-}" ]]; then
  chown -R "$(id -u ${username}):$(id -g ${username})" "/home/${username}"
  chown -R "$(id -u ${username}):$(id -g ${username})" /usr/local/cargo
fi

chown "$(id -u ${username}):$(id -g ${username})" "${BASH_SCRIPT_PATH}"

exec su -s /bin/bash -c "${BASH_SCRIPT_PATH}" "${username}"
