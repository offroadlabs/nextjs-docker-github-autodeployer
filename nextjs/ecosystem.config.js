module.exports = {
  apps: [
    {
      name: 'nextjs-app',
      script: 'pnpm',
      args: 'start',
      cwd: '/app/current',
    },
    {
      name: 'webhook-server',
      script: '/github-webhook-server/webhook-server.js',
      watch: true
    }
  ]
};