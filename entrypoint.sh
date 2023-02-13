#!/bin/bash
set -euo pipefail

SUDO="sudo -EH -u ansible --"
export PATH=$PATH:/home/ansible/.local/bin
if [[ "$#" -ne 0 ]]; then
  ${SUDO} "$@"
else
  ${SUDO} /bin/bash --login
fi
exit $?
