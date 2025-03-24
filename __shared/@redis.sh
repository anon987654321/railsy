# -- ENSURE REDIS IS INSTALLED AND RUNNING --

if ! command -v redis-server &>/dev/null; then
  doas pkg_add redis
  doas rcctl enable redis
fi
doas rcctl start redis
echo "Ensure Redis is installed and running"
