# Print a short hint for interactive shells without being noisy in scripts.
case "$-" in
  *i*)
    if [ -z "${XAIBOOT_HELP_SHOWN:-}" ]; then
      export XAIBOOT_HELP_SHOWN=1
      echo "XaiBoot: run 'xaihelp' for rescue commands or 'xaidesktop' to start XFCE."
    fi
    ;;
esac
