Foreman Remote Execution test setup
===================================

Spawns docker containers running sshd and registers them inside the Foreman to test
remote execution functionality.

Setup
-----

```
cp settings.sh.example settings.sh
# edit settings to update paths to foreman and proxy 
# check if port where smart proxy running  is same as port in settings.sh (e.g 8000)

# build certs and docker image
./test.sh build

#copy foreman_remote_execution_testenv/ssh/id_rsa_foreman_proxy  
#and foreman_remote_execution_testenv/ssh/id_rsa_foreman_proxy.pub 
#to directory ~/.ssh

```

Usage
-----

```
# run a conainer ('client.foreman.test' by default)
./test.sh run

# re-build
./test.sh build && ./test.sh run -f

# spawn 10 conainers:
for x in {1..10}; do ./test.sh run -f -c host-$x.foreman.test; done
```
