# openshift-conjur-deploy

This repository contains scripts for deploying a Conjur v4 cluster to an
OpenShift 3.3 environment.

# Setup

The Conjur deployment scripts pick up configuration details from local
environment variables. The setup instructions below will walk you through the
necessary steps for configuring your OpenShift environment and show you which
variables need to be set before deploying.

### OpenShift

To deploy Conjur, you will first need access to an [OpenShift 3.3](https://docs.openshift.com/container-platform/3.3/welcome/index.html)
deployment and must log in using the [OpenShift v1.3.3 CLI](https://github.com/openshift/origin/releases/tag/v1.3.3)
with a user that has sufficient privileges to create OpenShift projects:

```
oc login https://<your-routing-domain>:<port> -u <privileged-user>
```

Finally, you must specify a name for the OpenShift project in which you'd like
to deploy the Conjur cluster:

```
export CONJUR_PROJECT_NAME=conjur
```

### Docker

You will need to [install Docker](https://www.docker.com/get-docker) on your
local machine if you do not already have it. You will also need to make sure
that the [integrated Docker registry](https://docs.openshift.com/container-platform/3.3/install_config/registry/deploy_registry_existing_clusters.html)
in your OpenShift environment is available and that you've added it as an
[insecure registry](https://docs.docker.com/registry/insecure/) in your local
Docker engine. You must then specify the path to the OpenShift registry like so:

```
export DOCKER_REGISTRY_PATH=docker-registry-<registry-namespace>.<routing-domain>
```

### Conjur

#### Appliance Image

You will need to obtain a Docker image of the Conjur v4 appliance and tag it in
your local registry as `conjur-appliance:4.9-stable`. The deploy scripts will
look for this tag when pushing the applance image to your OpenShift Docker
registry.

#### Appliance Configuration

When setting up a new Conjur installation, you must provide an account name and
a password for the admin account:

```
export CONJUR_ACCOUNT=<my_account_name>
export CONJUR_ADMIN_PASSWORD=<my_admin_password>
```

Conjur uses [declarative policy](https://developer.conjur.net/policy) to control
access to secrets. After deploying Conjur, you will need to load a policy that
defines a `webservice` to represent the Kubernetes authenticator:

```
- !policy
id: conjur/authn-k8s/{{ SERVICE_ID }}
```

The `SERVICE_ID` should describe the OpenShift cluster in which your Conjur
deployment resides. For example, it might be something like `openshift/prod`.
For Conjur configuration purposes, you will need to provide this value to the
Conjur deploy scripts like so:

```
export AUTHENTICATOR_SERVICE_ID=<service_id>
```

This `service_id` can be anything you like, but it's important to make sure
that it matches the value that you intend to use in Conjur Policy.

# Permissions

The service account used by the Conjur authenticator must be granted the
following permissions in the namespaces of the applications that wish to
authenticate with Conjur:

- `pods [get, list]` to verify the pod's membership in its namespace
- `pods/exec [create, get]` to inject a signed certificate directly into the pod

# Usage

Run `./start` to deploy Conjur. This will execute the numbered scripts in
sequence to create and configure a Conjur cluster comprised of one Master, two
Standbys, and two read-only Followers.

Please note that the deploy scripts grant the `anyuid` SCC to the `default`
service account in the project that contains Conjur as configuring standbys and
followers requires root access.

When the deploy scripts finish, they will print out the URL and credentials that
you need to access Conjur from outside the OpenShift environment. You can access
the Conjur UI by visiting this URL in a browser or use it to interact with Conjur
through the [Conjur CLI](https://developer.conjur.net/cli).

# Test App Demo

The [openshift-conjur-demo repo](https://github.com/conjurdemos/openshift-conjur-demo)
can be used to set up a test application that retrieves secrets from Conjur
using our Ruby API. It can be used as a reference when setting up your own
applications to integrate with Conjur.