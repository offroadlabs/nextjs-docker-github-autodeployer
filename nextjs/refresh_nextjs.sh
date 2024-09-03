#!/bin/bash

refresh_nextjs() {
    /scripts/manage_repo.sh

    if command -v pm2 > /dev/null 2>&1; then
        echo "Restarting Next.js application with pm2..."
        pm2 restart nextjs-app
    fi
}

refresh_nextjs