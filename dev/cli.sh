export VSCODE_CLI_APP_NAME="prism"
export VSCODE_CLI_BINARY_NAME="prism-server"
export VSCODE_CLI_DOWNLOAD_URL="https://github.com/Danielkayode/binaries/releases"
export VSCODE_CLI_QUALITY="stable"
export VSCODE_CLI_UPDATE_URL="https://raw.githubusercontent.com/Danielkayode/versions/refs/heads/main"

cargo build --release --target aarch64-apple-darwin --bin=code

cp target/aarch64-apple-darwin/release/code "../../VSCode-darwin-arm64/Prism.app/Contents/Resources/app/bin/prism-tunnel"

"../../VSCode-darwin-arm64/Prism.app/Contents/Resources/app/bin/prism-tunnel" serve-web


# export CARGO_NET_GIT_FETCH_WITH_CLI="true"
# export VSCODE_CLI_APP_NAME="prism-insiders"
# export VSCODE_CLI_BINARY_NAME="prism-server-insiders"
# export VSCODE_CLI_DOWNLOAD_URL="https://github.com/Danielkayode/binaries-insiders/releases"
# export VSCODE_CLI_QUALITY="insider"
# export VSCODE_CLI_UPDATE_URL="https://raw.githubusercontent.com/Danielkayode/versions/refs/heads/master"

# cargo build --release --target aarch64-apple-darwin --bin=code

# cp target/aarch64-apple-darwin/release/code "../../VSCode-darwin-arm64/Prism - Insiders.app/Contents/Resources/app/bin/prism-tunnel-insiders"

# "../../VSCode-darwin-arm64/Prism - Insiders.app/Contents/Resources/app/bin/prism-insiders" serve-web
