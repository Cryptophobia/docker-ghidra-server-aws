# Ghidra Docker Server on EC2

## Why?

Standing up a Ghidra Server in the cloud is a pain. It doesn't have to be. If you're new to Ghidra Server, [this primer](https://byte.how/posts/collaborative-reverse-engineering/) is a good introduction.

## On AWS EC2 (for CS6747):

Provision a new t2.micro (free tier) or t3.micro instance on AWS in a new or default VPC. On the "Choose AMI" pick Ubuntu 18.04 x86_64. On "Configure Instance" page, pick the default/new VPC and enable "Auto-assign Public IP" option. Keep all other default settings. On next page "Add Storage", add the default storage storage of 8GB. On next page "Add Tags", tag Name something set to "ghidra-server..." or whatever you want to name it, this will set the name in the AWS console.

On the next page "Configure Security Group", select create new security group and add the IP of your current computer you will be SSH-ing from to the SSH protocol inbound connections. To find out your outbound IP `curl -4 ifconfig.me` in case you are using AWS workspace instance or you don't know your external IP.

On this page also add the inbound IPs for the AWS Workspace Instances that you and your group members will be connecting from. Ask your group members to run `curl -4 ifconfig.me` and whitelist those IPs.

For each group member IP, if a group member gives you `35.255.1.255`, then you set protocol TCP and ports to `13100-13102` (these are the ports for ghidra server/client protocol) whitelist and the CIDR `35.255.1.255/32`. This way only one single IP is able to connect per each rule. If you have a group of 2 as is the standard of CS6747, you should have 3 rules in the inbound rules of the new security group.

On the next page, you will need an SSH key to connect to the instance. Either create a new one or use one that you already have on the account. If you create a new SSH key, make sure to download it and save it.

Provision the instance by clicking "Launch Instance". Wait a couple mins for instance to be available. Make ssh connection to EC2 instance (find the public ip of instance in console and ssh) and run these commands:

```bash
ssh -i "{your_ssh_key.pem}" ubuntu@3.5.12.13

git clone https://github.com/Cryptophobia/docker-ghidra-server-aws

cd docker-ghidra-server-aws

# this script will install docker and build the image:
chmod +x ec2-setup.sh && sudo ./ec2-setup.sh

# here substitute the GHIDRA_USERS that you would like to create:
docker run -d --rm --name ghidra-server -e GHIDRA_USERS="anton jamie" -v /home/ubuntu/repos:/repos -p 13100-13102:13100-13102 cs6747/ghidra-server:10.1.1

# docker image is now running to see:
docker ps -a

# docker logs available via:
docker logs {container_image_id}
```

Ghidra-server is now running in docker on the EC2 instance. To connect as ghidra user use the public IP of EC2 instance from the AWS Workspace instance and use port 13100. Default password is "changeme" for each user and ghidra server will ask you to change it.

## Images

```bash
ghidra-server   latest
ghidra-server   10.1.1
```

> **NOTE:** tag `beta` is built by compiling Ghidra from its `master` branch source

## Getting Started

Start the server and connect to port 13100 with a Ghidra client that has a **matching** version. All users will be created as admins and will have initial password `changeme`, which Ghidra will require you to change after you login.

### Quick run

The start script will build the container if it's not already built.

```bash
./start.sh -h

./start.sh -u "admin bytehow" # Starts server with users "admin" and "noop"
./start.sh -l # Starts server as Local-only
```


### Public Server

```bash
$ docker run -it --rm \
    --name ghidra-server \
    -e GHIDRA_USERS="admin bytehow" \
    -v /path/to/repos:/repos \
    -p 13100-13102:13100-13102 \
    bytehow/ghidra-server
```

### Local-only Server

```bash
$ docker run -it --rm \
    --name ghidra-server \
    -e GHIDRA_USERS="admin bytehow" \
    -e GHIDRA_PUBLIC_HOSTNAME="0.0.0.0" \
    -v /path/to/repos:/repos \
    -p 13100-13102:13100-13102 \
    bytehow/ghidra-server
```


## Environment Variables

| Name | Description | Required | Default |
| - | - | - | - |
|`GHIDRA_USERS` | Space seperated list of users to create | No | `admin` |
|`GHIDRA_PUBLIC_HOSTNAME` | IP or hostname that remote users will use to connect to server. Set to `0.0.0.0` if hosting locally. If not set, it will try to discover your public ip by querying OpenDNS | No | Your public IP |

## Additional information

Additional information such as capacity planning and other server configuration aspects can be found by consulting the server documentation provided at `/<GhidraInstallDir>/server/svrREADME.html`


## Issues

Find a bug? Want more features? Find something missing in the documentation? Let me know! Please don't hesitate to [file an issue](https://github.com/johnameen/docker-ghidra-server/issues/new)

## Credits

- NSA Research Directorate [https://www.ghidra-sre.org/](https://www.ghidra-sre.org/)
- blacktop's [docker-ghidra](https://github.com/blacktop/ghidra-server) project

### License

Apache License (Version 2.0)
