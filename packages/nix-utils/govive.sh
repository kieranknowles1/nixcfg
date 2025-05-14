#!/usr/bin/env bash
set -euo pipefail

# Upscale frames while working on them
export XRT_COMPOSITOR_SCALE_PERCENTAGE=140
# Composite frames in a compute shader
export XRT_COMPOSITOR_COMPUTE=1

showhelp() {
  cat <<EOF
Start necessary services for VR games. Not run on startup due to CPU overhead

To run a Steam game through monado, change its launch command to the following:
XR_RUNTIME_JSON=/run/current-system/sw/share/openxr/1/openxr_monado.json PRESSURE_VESSEL_FILESYSTEMS_RW=\$XDG_RUNTIME_DIR/monado_comp_ipc %command%

If startup is failing, try rebooting

Usage: $0
  -h|--help:
    Show this help message and exit
EOF
  exit
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      showhelp
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

if pidof monado-service > /dev/null; then
  echo "monado-service is already running. Please reboot if VR is not working" >&2
  exit 1
fi

# This is kept after unexpected shutdowns
if [[ -f /run/user/1000/monado.pid ]]; then
  rm /run/user/1000/monado.pid
fi

# TODO: What do these vars do and should they be changed
SURVIVE_GLOBALSCENESOLVER=0 SURVIVE_TIMECODE_OFFSET_MS=-6.94 monado-service
