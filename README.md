Foreman Remote Execution test setup
===================================

Spawns docker containers running sshd and registers them inside the Foreman to test
remote execution functionality.

Setup
-----

```
cp settings.sh.example settings.sh
# edit settings to update paths to foreman and proxy

# copy the generated keys to your local directory
cp ssh/id_rsa_foreman_proxy* ~/.ssh

# build certs and docker image
./test.sh build

**In foreman directory**

Add a line that contains `:restrict_registered_smart_proxies: false` to file `config/settings.yaml`

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
