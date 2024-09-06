#!/bin/bash

BRANCH="${BRANCH:-main}"
BASE_DIR="/app"
CLONE_BASE="/app"
LINK_NAME="/app/current"

generate_unique_dir() {
    echo "$CLONE_BASE/repo_$(date +%Y%m%d_%H%M%S)"
}

manage_symlink() {
    if [ -L "$LINK_NAME" ]; then
        CURRENT_DIR=$(readlink "$LINK_NAME")

        echo "Removing existing symlink..."
        rm "$LINK_NAME"

        #if [ -d "$CURRENT_DIR" ]; then
        #    echo "Removing previous clone directory $CURRENT_DIR..."
        #    rm -rf "$CURRENT_DIR"
        #fi
    fi

    echo "Creating new symlink from $1 to $LINK_NAME"
    ln -s "$1" "$LINK_NAME"
}

manage_repo() {
    if [ -z "$REPO_URL" ]; then
        echo "REPO_URL is not set. Exiting..."
        exit 1
    fi

    CLONE_DIR=$(generate_unique_dir)
    mkdir -p "$CLONE_BASE"

    echo "Cloning repository from $REPO_URL (branch $BRANCH) into $CLONE_DIR..."
    git clone --branch $BRANCH $REPO_URL $CLONE_DIR

    echo "Purge pnpm"
    rm -rf $(pnpm store path)

    echo "Installing dependencies in $CLONE_DIR..."
    pnpm --prefix $CLONE_DIR install --frozen-lockfile

    echo "Building the Next.js application in $CLONE_DIR..."
    pnpm --prefix $CLONE_DIR run build

    if [ ! -z "$POST_BUILD_COMMANDS" ]; then
        echo "Executing post-build commands in /app/current..."
        cd "$CLONE_DIR"
        IFS='&&' read -r -a commands <<< "$POST_BUILD_COMMANDS"
        for cmd in "${commands[@]}"; do
            echo "Executing: $cmd"
            eval $cmd
        done
    fi

    manage_symlink "$CLONE_DIR"
}

manage_repo