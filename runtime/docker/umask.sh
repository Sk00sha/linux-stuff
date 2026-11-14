# Default umask for interactive sessions (docker exec bypasses PAM).
if [ "$(id -u)" -ge 1000 ]; then umask 0002; else umask 0022; fi
