#!/bin/bash

set -e

[ -f .gitauth ] && source .gitauth

for cmd in jq curl; do
    [ -z "$(command -v $cmd)" ] && echo "missing $cmd" && exit 1
done

REVANCED_PATCHES_TAG=$(curl -s https://api.github.com/repos/revanced/revanced-patches/releases/latest | jq -r '.tag_name')
REVANCED_INTEGRATIONS_TAG=$(curl -s https://api.github.com/repos/revanced/revanced-integrations/releases/latest | jq -r '.tag_name')
REVANCED_CLI_TAG=$(curl -s https://api.github.com/repos/revanced/revanced-cli/releases/latest | jq -r '.tag_name')

(
    cd revanced-cli
    git submodule update --checkout
    git checkout "$REVANCED_CLI_TAG"
)

sed -i "s/^REVANCED_PATCHES=.*$/REVANCED_PATCHES=\"$REVANCED_PATCHES_TAG\"/" version.sh
sed -i "s/^REVANCED_INTEGRATIONS=.*$/REVANCED_INTEGRATIONS=\"$REVANCED_INTEGRATIONS_TAG\"/" version.sh
sed -i "s/^REVANCED_CLI=.*$/REVANCED_CLI=\"$REVANCED_CLI_TAG\"/" version.sh
