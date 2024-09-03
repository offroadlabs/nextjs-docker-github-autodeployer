#!/bin/bash

BRANCH="${BRANCH:-main}"
CLONE_DIR="/app"

manage_repo() {
    if [ -z "$REPO_URL" ]; then
        echo "REPO_URL is not set. Exiting..."
        exit 1
    fi

    if [ -d "$CLONE_DIR/.git" ]; then
        echo "Repository already exists. Pulling latest changes from branch $BRANCH..."
        git -C $CLONE_DIR fetch --all --force --prune
        git -C $CLONE_DIR reset --hard origin/$BRANCH
    else
        echo "Cloning repository from $REPO_URL (branch $BRANCH)..."
        git clone --branch $BRANCH $REPO_URL $CLONE_DIR
    fi

    echo "Installing dependencies..."
    pnpm install --frozen-lockfile

    echo "Building the Next.js application..."
    pnpm run build

    if [ ! -z "$POST_BUILD_COMMANDS" ]; then
        echo "Executing post-build commands..."
        IFS='&&' read -r -a commands <<< "$POST_BUILD_COMMANDS"
        for cmd in "${commands[@]}"; do
            echo "Executing: $cmd"
            eval $cmd
        done
    fi
}

manage_repo