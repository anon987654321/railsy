# -- INSTALL YARN --

if ! command -v yarn &>/dev/null; then
  doas npm install yarn -g
fi
echo "Ensure Yarn is installed"
