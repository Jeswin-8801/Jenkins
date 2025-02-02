# Jenkins

A containerized version of Jenkins server with offline setup (preloaded with required plugins) with reverse proxy

# Installation

Steps to install Apache web server and Docker:

## Apache Web Server Installation

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install apache2 -y
# to start automatically at boot time
sudo systemctl enable apache2
```

### Verifying Installation

> In a new tab open => http://\<your-server-ip\>

## Installing Docker

> Refer => https://docs.docker.com/engine/install/ubuntu/#install-from-a-package

```bash
curl -k -O -L https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/containerd.io_1.7.25-1_amd64.deb \
-O -L https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-buildx-plugin_0.19.3-1~ubuntu.22.04~jammy_amd64.deb \
-O -L https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-ce_27.5.0-1~ubuntu.22.04~jammy_amd64.deb \
-O -L https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-ce-cli_27.5.0-1~ubuntu.22.04~jammy_amd64.deb \
-O -L https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-compose-plugin_2.6.0~ubuntu-jammy_amd64.deb \
-O -L https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-scan-plugin_0.23.0~ubuntu-jammy_amd64.deb

sudo dpkg -i ./*.deb

# to start automatically at boot time
sudo systemctl enable docker
```

> [!Note]
> There is an alternate more intuitive method to install the same but if you are behind a corporate network with strict restrictions, you can try the above method. (Remember to update the above links if outdated)

### Verify Installation

```bash
sudo docker --version
sudo docker run hello-world
```

### Jenkins Setup

Before running jenkins, setup the ssh keys that will be used to fetch the Jenkins pipeline scripts from the private repo in Github.

- In the location where the `docker-compose.yml` file is stored run (Must be an easily accessible location and not be too nested like in the home or root dir):

```bash
mkdir .ssh
ssh-keygen -t ed25519 -f .ssh/id_ed25519.jenkins -P "" -C "jeswin.santosh@sandisk.com"
```

- On a system with a less strict network in the base directory after cloning the repo run:
```bash
docker compose build jenkins
```

- Now either push the jenkins image that gets generated to docker hub or save as a tar file and use it on the server running jenkins.
```bash
# To save to a tarfile
docker save -o jenkins.tar jeswinssandisk/jenkins-with-plugins
# to load the image from tarfile on the server
sudo docker load -i jenkins.tar
```

> [!Note]
> Remember to add this key to your github account: 
> Paste the output of `cat .ssh/id_ed25519.pub` into Github

> Refer for more info => https://www.jenkins.io/doc/book/installing/docker/

# Jenkins as a systemd service

- Save the file `jenkins.service` as `/etc/systemd/system/jenkins.service`

> [!Important]
> Remember to change the `WorkingDirectory` param in `jenkins.service` to the location where `docker-compose.yml` is stored

```bash
# To load the new service file
sudo systemctl daemon-reload
# To start the service, run the command:
sudo systemctl start jenkins
```

*Jenkins should now be up and running. But before accessing the webpage setup reverse proxy by following the steps below*

# Configure Apache to Reverse Proxy Jenkins

### Enable Apache proxy modules

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod headers
# Required for websocket
sudo a2enmod proxy_wstunnel
sudo a2enmod rewrite

sudo systemctl restart apache2
```

### Create a new Apache site configuration to reverse proxy Jenkins

- Copy the file `jenkins.conf` to `/etc/apache2/sites-available/`:

> Refer => https://www.jenkins.io/doc/book/system-administration/reverse-proxy-configuration-with-jenkins/reverse-proxy-configuration-apache/

### Enable the new site configuration

```bash
sudo a2ensite jenkins.conf
sudo systemctl reload apache2
```

#### The site can now be accessed at http://\<your-server-ip\>/jenkins

# How to get Initial Setup Password
When prompted for the admin password, use the below command to get it from the server running jenkins
```bash
sudo docker exec -it $(sudo docker ps -a | grep jenkins | grep -oP "^\w+") cat /var/jenkins_home/secrets/initialAdminPassword
```