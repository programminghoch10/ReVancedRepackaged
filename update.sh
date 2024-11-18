#!/bin/bash

set -e

[ -f .gitauth ] && source .gitauth

for cmd in curl jq sed git; do
    [ -z "$(command -v $cmd)" ] && echo "missing $cmd" && exit 1
done

source version.sh

REVANCED_PATCHES_TAG=$(curl -s https://api.github.com/repos/revanced/revanced-patches/releases/latest | jq -r '.tag_name')
if [ "$REVANCED_PATCHES" != "$REVANCED_PATCHES_TAG" ]; then
    sed -i "s/^REVANCED_PATCHES=.*$/REVANCED_PATCHES=\"$REVANCED_PATCHES_TAG\"/" version.sh
    echo "Updated REVANCED_PATCHES from $REVANCED_PATCHES to $REVANCED_PATCHES_TAG"
else
    echo "No update for REVANCED_PATCHES $REVANCED_PATCHES found"
fi

REVANCED_CLI_TAG=$(curl -s https://api.github.com/repos/revanced/revanced-cli/releases/latest | jq -r '.tag_name')
if [ "$REVANCED_CLI" != "$REVANCED_CLI_TAG" ]; then
    (
        git submodule update --checkout
        cd revanced-cli
        git fetch --all --quiet
        git checkout "$REVANCED_CLI_TAG"
    )
    sed -i "s/^REVANCED_CLI=.*$/REVANCED_CLI=\"$REVANCED_CLI_TAG\"/" version.sh
    echo "Updated REVANCED_CLI from $REVANCED_CLI to $REVANCED_CLI_TAG"
else
    echo "No update for REVANCED_CLI $REVANCED_CLI found"
fi

echo
source version.sh
cat <<EOF
update ReVanced

* revanced-cli \`$REVANCED_CLI\`
* revanced-patches \`$REVANCED_PATCHES\`
EOF
