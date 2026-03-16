#!/usr/bin/env bash
set -euo pipefail

ROSLYN_LS_VERSION="${ROSLYN_LS_VERSION:-5.0.0-1.25277.114}"
ROSLYN_LS_BASE_DIR="${ROSLYN_LS_BASE_DIR:-$HOME/.local/share/roslyn-ls}"
ROSLYN_LS_BIN_DIR="${ROSLYN_LS_BIN_DIR:-$HOME/.local/bin}"
FORCE_INSTALL=0

log() {
  printf "\n==> %s\n" "$1"
}

warn() {
  printf "\n[warn] %s\n" "$1"
}

exists() {
  command -v "$1" >/dev/null 2>&1
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --force)
        FORCE_INSTALL=1
        ;;
      *)
        echo "Unknown argument: $1" >&2
        echo "Usage: $0 [--force]" >&2
        return 1
        ;;
    esac
    shift
  done
}

detect_platform_suffix() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin) os="osx" ;;
    Linux) os="linux" ;;
    *)
      echo "Unsupported OS: $os" >&2
      return 1
      ;;
  esac

  case "$arch" in
    arm64|aarch64) arch="arm64" ;;
    x86_64|amd64) arch="x64" ;;
    *)
      echo "Unsupported architecture: $arch" >&2
      return 1
      ;;
  esac

  printf "%s-%s" "$os" "$arch"
}

download_and_extract() {
  local package_suffix version install_dir tmp_dir package_url package_file
  package_suffix="$1"
  version="$2"
  install_dir="$3"

  tmp_dir="$(mktemp -d)"
  package_file="$tmp_dir/roslyn-ls.nupkg"
  package_url="https://www.nuget.org/api/v2/package/Microsoft.CodeAnalysis.LanguageServer.${package_suffix}/${version}"

  log "Downloading Roslyn Language Server ${version} (${package_suffix})"
  curl -fL "$package_url" -o "$package_file"

  log "Extracting package"
  rm -rf "$install_dir"
  mkdir -p "$install_dir"
  unzip -q "$package_file" -d "$install_dir"

  rm -rf "$tmp_dir"
}

write_wrapper() {
  local install_dir platform_suffix bin_dir wrapper_path server_dll
  install_dir="$1"
  platform_suffix="$2"
  bin_dir="$3"
  wrapper_path="$bin_dir/roslyn-language-server"
  server_dll="$(_resolve_server_dll "$install_dir" "$platform_suffix")"

  mkdir -p "$bin_dir"

  cat > "$wrapper_path" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec dotnet "$server_dll" "\$@"
EOF

  chmod +x "$wrapper_path"
}

_resolve_server_dll() {
  local install_dir platform_suffix
  install_dir="$1"
  platform_suffix="$2"

  local candidate
  candidate="$install_dir/content/LanguageServer/$platform_suffix/Microsoft.CodeAnalysis.LanguageServer.dll"
  if [ -f "$candidate" ]; then
    printf "%s" "$candidate"
    return
  fi

  candidate="$install_dir/lib/net9.0/Microsoft.CodeAnalysis.LanguageServer.dll"
  if [ -f "$candidate" ]; then
    printf "%s" "$candidate"
    return
  fi

  echo "Could not locate Microsoft.CodeAnalysis.LanguageServer.dll in $install_dir" >&2
  return 1
}

is_installed() {
  local install_dir platform_suffix
  install_dir="$1"
  platform_suffix="$2"

  if [ -f "$install_dir/content/LanguageServer/$platform_suffix/Microsoft.CodeAnalysis.LanguageServer.dll" ]; then
    return 0
  fi

  if [ -f "$install_dir/lib/net9.0/Microsoft.CodeAnalysis.LanguageServer.dll" ]; then
    return 0
  fi

  return 1
}

verify_install() {
  local wrapper_path
  wrapper_path="$1"

  if [ ! -x "$wrapper_path" ]; then
    echo "Roslyn wrapper not executable: $wrapper_path" >&2
    return 1
  fi

  "$wrapper_path" --help >/dev/null 2>&1 || true

  if exists roslyn-language-server; then
    log "Roslyn language server available in PATH"
  else
    warn "roslyn-language-server installed at $wrapper_path but not in PATH"
  fi
}

main() {
  local platform_suffix install_dir wrapper_path

  parse_args "$@"

  if ! exists dotnet; then
    warn "dotnet not found, skipping Roslyn language server install"
    return
  fi

  if ! exists curl; then
    warn "curl not found, skipping Roslyn language server install"
    return
  fi

  if ! exists unzip; then
    warn "unzip not found, skipping Roslyn language server install"
    return
  fi

  platform_suffix="$(detect_platform_suffix)"
  install_dir="$ROSLYN_LS_BASE_DIR/$ROSLYN_LS_VERSION/$platform_suffix"

  if [ "$FORCE_INSTALL" -eq 1 ]; then
    log "Forcing Roslyn language server reinstall"
    download_and_extract "$platform_suffix" "$ROSLYN_LS_VERSION" "$install_dir"
  elif is_installed "$install_dir" "$platform_suffix"; then
    log "Roslyn language server already installed: $install_dir"
  else
    download_and_extract "$platform_suffix" "$ROSLYN_LS_VERSION" "$install_dir"
  fi

  write_wrapper "$install_dir" "$platform_suffix" "$ROSLYN_LS_BIN_DIR"

  wrapper_path="$ROSLYN_LS_BIN_DIR/roslyn-language-server"
  verify_install "$wrapper_path"

  log "Roslyn language server installed: $install_dir"
}

main "$@"
