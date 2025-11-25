#!/usr/bin/env fish

function log
    printf "[caelestia-shell] %s\n" "$argv"
end

set script_dir (dirname (status --current-filename))
set repo_root (realpath "$script_dir")

if set -q CAELESTIA_INSTALL_QSCONFDIR
    set install_qsconfdir "$CAELESTIA_INSTALL_QSCONFDIR"
else
    set install_qsconfdir "$HOME/.config/quickshell/caelestia"
end

cd "$repo_root" || exit 1

log "Working directory: $repo_root"
log "INSTALL_QSCONFDIR -> $install_qsconfdir"

log "Cleaning existing build directory"
rm -rf build

log "Ensuring scripts are executable"
chmod +x assets/wrap_term_launch.sh

log "Ensuring Quickshell config directory exists"
mkdir -p "$install_qsconfdir"

log "Configuring CMake (Release/Ninja)"
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/ "-DINSTALL_QSCONFDIR=$install_qsconfdir"
or begin
    log "CMake configure failed"
    exit 1
end

log "Building"
cmake --build build
or begin
    log "Build failed"
    exit 1
end

log "Installing (sudo required)"
if command -q sudo
    sudo cmake --install build
    or begin
        log "Install failed"
        exit 1
    end
else
    log "sudo is not available; run 'cmake --install build' manually from $repo_root/build"
    exit 1
end

log "Done"
