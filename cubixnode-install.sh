#!/usr/bin/env bash
# Cubixnode installer wrapper
# Branding: Cubixnode — Made by NaughtyGavvy
# This wrapper adapts the upstream JTG installer to use your Cubixnode fork.
# Before using it, publish the fork at NaughtyGavvy/Cubixnode (or edit CUBIXNODE_REPO below).

set -Eeuo pipefail

CUBIXNODE_REPO="${CUBIXNODE_REPO:-NaughtyGavvy/Cubixnode}"
UPSTREAM_INSTALLER="https://raw.githubusercontent.com/JishnuTheGamer/Jtg/refs/heads/main/install.sh"

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required."
  exit 1
fi
if ! command -v sed >/dev/null 2>&1; then
  echo "Error: sed is required."
  exit 1
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/cubixnode-install.XXXXXX")"
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT

echo "Cubixnode — Made by NaughtyGavvy"
echo "Preparing installer..."
if ! curl -fsSL "$UPSTREAM_INSTALLER" -o "$tmp_dir/upstream-install.sh"; then
  echo "Error: could not download the upstream installer."
  exit 1
fi

# Replace branding and repository references in a temporary copy only.
# The original upstream script is not modified.
sed \
  -e "s#https://github.com/JishnuTheGamer/Jtg.git#https://github.com/${CUBIXNODE_REPO}.git#g" \
  -e "s#https://github.com/JishnuTheGamer/Jtg#https://github.com/${CUBIXNODE_REPO}#g" \
  -e "s#JishnuTheGamer/Jtg#${CUBIXNODE_REPO}#g" \
  -e 's/JTG Panel/Cubixnode/g' \
  -e 's/JTG CONTROL PANEL/CUBIXNODE CONTROL PANEL/g' \
  -e 's/Next-Gen Minecraft Server Manager/Cubixnode Server Management/g' \
  -e 's/jtg-main/cubixnode-main/g' \
  -e 's/jtg-admin/cubixnode-admin/g' \
  -e 's#/opt/jtg-java#/opt/cubixnode-java#g' \
  "$tmp_dir/upstream-install.sh" > "$tmp_dir/install.sh"

chmod 700 "$tmp_dir/install.sh"

echo
echo "Repository configured: https://github.com/${CUBIXNODE_REPO}"
echo "NOTE: The repository must exist and contain your Cubixnode fork."
echo "Starting installer..."
echo

bash "$tmp_dir/install.sh" "$@"
