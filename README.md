# tmp-ssh

Create temporary local SSH servers for testing.

### Usage

```shell
# Start servers in temporary containers
./tmp-ssh.sh start     # starts 3 servers by default
./tmp-ssh.sh start 7   # starts 7 servers

# It also adds in the ssh config "StrictHostKeyChecking no" for each server


# Stop servers
./tmp-ssh.sh stop      # Stop all servers and clean ssh known_hosts and config
```

### Build

Build from the Dockerfile. This will create a new image with the name `tmp-ssh`.

```shell
./tmp-ssh.sh build                   # Username/password will be thomas
./tmp-ssh.sh build myusername        # Username/password will be myusername

./tmp-ssh.sh --image tmp-ssh start   
```

