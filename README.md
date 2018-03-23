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
docker login -u _ -p $(oc whoami -t) $DOCKER_REGISTRY_PATH
```

# Conjur Configuration

You will need to set environment variables for the account and admin password that you would like to use when configuring your Conjur installation:

```
export CONJUR_ACCOUNT=<my_account_name>
export CONJUR_ADMIN_PASSWORD=<my_admin_password>
```

You will also need to set the `AUTHENTICATOR_SERVICE_ID` environment variable for the authn-k8s webservice that you will define in Conjur policy.. This should be of the form `authn-k8s/<service_id>`. For example, to enable the Conjur policy `conjur/authn-k8s/gke/prod`, you would set this to `authn-k8s/gke/prod`.

```
export AUTHENTICATOR_SERVICE_ID=authn-k8s/<service_id>
```

# Deploying Conjur

Run the `./start` script in the root folder to deploy Conjur to your environment. This will create a Conjur OpenShift project and deploy 3 Conjur Appliance pods. By convention, the first pod is chosen as Master and the other two are designated as Standbys. An HAProxy pod will also be created to act as a load balancer for the Conjur containers and provide high availability.

# Test App

Visit the [openshift-conjur-demo repo](https://github.com/conjurdemos/openshift-conjur-demo) for a test app that will allow you to test Conjur running in an OpenShift environment.