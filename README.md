# openshift-conjur-deploy

This repository contains scripts for deploying a Conjur v4 cluster to an OpenShift 3.3 environment.

# Requirements

- Obtain the latest Conjur v4 Appliance and tag it as `conjur-appliance:4.9-stable`.
- Install the [OpenShift CLI v1.3.3](https://github.com/openshift/origin/releases/tag/v1.3.3).
- Log in to your OpenShift environment via `oc login` with a user that has project creation privileges.

# OpenShift Configuration

We will need to set a few environment variables to configure the deploy scripts. First, the project in which you wish to run Conjur:

```
export CONJUR_PROJECT_NAME=conjur
```

# Docker Configuration

Make sure the [integrated Docker registry](https://docs.openshift.com/container-platform/3.3/install_config/registry/deploy_registry_existing_clusters.html) of your OpenShift environment is available and that you've added it as an [insecure registry](https://docs.docker.com/registry/insecure/) in your local Docker engine. Specify the path to the registry as:

```
export DOCKER_REGISTRY_PATH=docker-registry-[registry pod namespace].apps.[openshift env domain]
```

# Conjur Configuration

Specify the account and admin password that you would like to use for Conjur:

```
export CONJUR_ACCOUNT=<my_account_name>
export CONJUR_ADMIN_PASSWORD=<my_admin_password>
```

In order to use Conjur's Kubernetes authenticator, you will have to create a Conjur policy named `conjur/authn-k8s/<service_id>`. This may be done before or after running these deploy scripts. Either way, you will need to specify the authenticator service ID as:

```
export AUTHENTICATOR_SERVICE_ID=<service_id>
```

For example, if your Conjur policy was called `conjur/authn-k8s/gke/prod` you would set:

```
export AUTHENTICATOR_SERVICE_ID=gke/prod
```

# Deploying Conjur

Run the `./start` script to deploy Conjur. This creates a project with a highly-available Conjur cluster comprised of one Master, two Standbys, and two read-only Followers. The Master and Standbys sit behind an HAProxy load balancer that can be accessed through a Kubernetes service. The Followers sit behind their own Kubernetes service and function as the point of contact between Conjur and your OpenShift applications.

# Test App

Visit the [openshift-conjur-demo repo](https://github.com/conjurdemos/openshift-conjur-demo) for a test app that will allow you to test Conjur running in an OpenShift environment.