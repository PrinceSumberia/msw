COMMIT_HASH=$(git rev-parse HEAD)
TARBALL_FILENAME="msw-$COMMIT_HASH.tgz"
LOCAL_PACKAGE_PATH="$PWD/$TARBALL_FILENAME"

echo "Mock Service Worker snapshot at: $COMMIT_HASH"

# Pack the local build of the `msw` package
echo "Packing 'msw' into $LOCAL_PACKAGE_PATH"
yarn pack --filename "$LOCAL_PACKAGE_PATH"

mv $LOCAL_PACKAGE_PATH ~/$TARBALL_FILENAME
cd ~

# Clone the examples repo.
# Use HTTPS protocol, because SSH would require a valid SSH key
# configured on the CircleCI side, which is unnecessary.
echo "Cloning the examples repository..."
git clone https://github.com/mswjs/examples.git

# Bootstrap the examples monorepo
echo "Installing dependencies..."
cd ~/examples
yarn install --frozen-lockfile

# Use the local build of the `msw` package.
echo "Installing the local build of the 'msw' package..."
yarn workspaces run add file:../../../$TARBALL_FILENAME

# Test all the examples.
echo "Testing examples..."
yarn test

# Clean up
echo "Cleaning up..."
rm -rf ~/examples
