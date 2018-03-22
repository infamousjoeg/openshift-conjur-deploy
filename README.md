# openshift-conjur-deploy

This repository contains scripts for deploying a Conjur v4 cluster to an OpenShift environment. It also incudes a deployable test app that demonstrates interaction with Conjur.

# Requirements

- Obtain the latest Conjur v4 Appliance and make sure it is tagged as `conjur-appliance:4.9-stable`.
- Install the [v1.3.3](https://github.com/openshift/origin/releases/tag/v1.3.3) of the OpenShift CLI.
- Log in to your OpenShift environment via `oc login` with a user that has project creation privileges.

# OpenShift Configuration

First you'll need to specify an environment variable for the OpenShift project in which you wish to run Conjur:

```
export CONJUR_PROJECT_NAME=conjur
```

You'll also need to make sure the [integrated Docker registry](https://docs.openshift.com/container-platform/3.3/install_config/registry/deploy_registry_existing_clusters.html) of your OpenShift environment is available and that it has beenadded as an [insecure registry](https://docs.docker.com/registry/insecure/) in your local Docker engine. Set the `DOCKER_REGISTRY_PATH` environment variable to the path of your OpenShift docker repo:

```
export DOCKER_REGISTRY_PATH=docker-registry-[namespace].apps.[openshift env domain]
```

Finally, login to the Docker registry with:

```
docker login $DOCKER_REGISTRY_PATH
```

# Conjur Configuration

You will need to set environment variables for the account and admin password that you would like to use when configuring your Conjur installation:

```
export CONJUR_ACCOUNT=my_account_name
export CONJUR_ADMIN_PASSWORD=my_admin_password
```

# Deploying Conjur

Run the `./start` script in the root folder to deploy Conjur to your environment. This will create a Conjur OpenShift project and deploy 3 Conjur Appliance pods. By convention, the first pod is chosen as Master and the other two are designated as Standbys. An HAProxy pod will also be created to act as a load balancer for the Conjur containers and provide high availability.

# Test App

If you would like to deploy the optional test app, simply `cd` into `webapp_demo` and run `./start.sh`. This will set up a separate OpenShift project with a client app that retrieves a secret from Conjur on a loop and writes it to the logs. Visit the OpenShift console and examine the logs of a test app pod to confirm that the test app is working properly. You can also run `./rotate_db_password.sh` to change the password.
