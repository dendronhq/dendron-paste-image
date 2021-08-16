#!/bin/sh

# Paste an image from the display system's clipboard to a file for use in Dendron
#
# This script attempts to determine if X11/Xorg or Wayland are in use, and utilize an
# appropriate/common command-line utility for each to interact with the clipboard.

cleanup_bad_image_write() {
  # Check if the file exists
  if [ -r "${1}" ] ; then
    # Check if the file is larger than 0 bytes, if not, it was probably a write from a command's
    # redirect that had an error - delete it
    if ! [ -s "${1}" ] ; then
      rm -f "${1}"
    fi
  fi
}

paste_xclip() {
  # require xclip (see http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script/677212#677212)
  if ! command -v xclip >/dev/null 2>&1 ; then
    echo "no xclip"
    exit 1
  fi

  # write image in clipboard to file (see http://unix.stackexchange.com/questions/145131/copy-image-from-clipboard-to-file)
  if xclip -selection clipboard -target image/png -o > "${1}" 2>/dev/null ; then
    echo "${1}"
    exit 0
  else
    echo "no image"
    cleanup_bad_image_write "${1}"
    exit 1
  fi
}

paste_wlclipboard() {
  # require wl-paste from the wl-clipboard package
  if ! command -v wl-paste >/dev/null 2>&1 ; then
    echo "no wl-paste"
    exit 1
  fi

  # write image in clipboard to file
  if wl-paste --type image/png > "${1}" 2>/dev/null; then
    echo "${1}"
    exit 0
  else
    echo "no image"
    cleanup_bad_image_write "${1}"
    exit 1
  fi
}

main() {
  # Determine the Linux display type (X11, Wayland, etc)
  # https://unix.stackexchange.com/questions/202891/how-to-know-whether-wayland-or-x11-is-being-used#comment1133584_371164
  if command -v loginctl >/dev/null 2>&1 ; then
    display_type="$(loginctl show-session $(loginctl show-user ${USER} -p Display --value) -p Type --value)"
  else
    echo "no loginctl command present, unable to determine display type - default will assume X11/Xorg" >&2
  fi

  case "${display_type}" in
    wayland)
      paste_wlclipboard "${1}"
      ;;
    x11)
      paste_xclip "${1}"
      ;;
    *)
      # To maintain backwards compatabiltiy after adding Wayland suport, assume
      # any unknown display type uses xclip
      paste_xclip "${1}"
      ;;
  esac
}

main "$@"
