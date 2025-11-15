#!/bin/bash

set -o errexit -o pipefail -o nounset

PACKAGE_NAME=$INPUT_PACKAGE_NAME
COMMIT_USERNAME=$INPUT_COMMIT_USERNAME
COMMIT_EMAIL=$INPUT_COMMIT_EMAIL
SSH_PRIVATE_KEY=$INPUT_SSH_PRIVATE_KEY

NEW_RELEASE=${GITHUB_REF##*/v}

export HOME=/home/builder

ssh-keyscan -t ed25519 aur.archlinux.org >> $HOME/.ssh/known_hosts
echo -e "${SSH_PRIVATE_KEY//_/\\n}" > $HOME/.ssh/aur
chmod 600 $HOME/.ssh/aur*

git config --global user.name "$COMMIT_USERNAME"
git config --global user.email "$COMMIT_EMAIL"

REPO_URL="ssh://aur@aur.archlinux.org/${PACKAGE_NAME}.git"

cd /tmp
git clone "$REPO_URL"
cd "$PACKAGE_NAME"

sed -i "s/pkgver=.*$/pkgver=$NEW_RELEASE/" PKGBUILD
sed -i "s/pkgrel=.*$/pkgrel=1/" PKGBUILD
updpkgsums

# Install deps
makepkg --syncdeps --noextract --nobuild --noconfirm
# Build package and install it
makepkg --cleanbuild --clean --install --noconfirm

# Update srcinfo
makepkg --printsrcinfo > .SRCINFO

# Update aur
git add PKGBUILD .SRCINFO
git commit --allow-empty -m "Update to $NEW_RELEASE"
git push
