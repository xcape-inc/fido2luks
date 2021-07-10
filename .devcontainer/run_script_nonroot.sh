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
#if [[ "${#PARAMS[@]}" -lt 2 ]]; then
#  echo 'Script requires atleast 2 parameters'; echo "$0 IMAGE_PATH DEVICE_PATH"; false
#fi

BASH_SCRIPT_CONTENTS="${PARAMS[0]}"
BASH_SCRIPT_PATH="${PARAMS[1]:-/tmp/bash.script}"

printf '%s' "#!/bin/bash
set -e
trap 'catch \$? \$LINENO' ERR
catch() {
  echo \"Error \$1 occurred on \$2\"
}

set -euo pipefail
${BASH_SCRIPT_CONTENTS}" > "${BASH_SCRIPT_PATH}"
chmod 777 "${BASH_SCRIPT_PATH}"
username=$(ls /home)
exec su -s /bin/bash -c "${BASH_SCRIPT_PATH}" "${username}"
