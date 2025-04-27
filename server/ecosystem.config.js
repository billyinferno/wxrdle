module.exports = {
    apps: [
        {
            name: 'wxrdle-api',
            interpreter: '/home/adimartha/.nvm/versions/node/v20.19.1/bin/node',
            script: 'index.js',
            instances: 1,
            exec_mode: 'fork',
            watch: false,
            autorestart: true,
            env: {
              NODE_ENV: 'production',
            }
        },
    ],
};