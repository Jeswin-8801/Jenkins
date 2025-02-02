#!/bin/bash

cat << 'EOF' > /var/jenkins_home/.ssh/config
Host github github.com ssh.github.com
        HostName ssh.github.com
        User git
        port 443
        IdentityFile ~/.ssh/id_ed25519.jenkins
EOF

# https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
ssh-keyscan github.com ssh.github.com >> /var/jenkins_home/.ssh/known_hosts

./usr/local/bin/jenkins.sh