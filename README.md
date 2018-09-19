# k8s-deploy-tools

CI/CD deployment tools for Kubernetes

## Docker Image

This alpine-based docker image contains next tools:

- [`kubectl`](https://kubernetes.io/docs/reference/kubectl/kubectl/) - Kubernetes CLI
- [`oc`](https://docs.openshift.com/enterprise/3.0/cli_reference/get_started_cli.html) - OpenShift CLI
- [`istioctl`](https://istio.io/docs/reference/commands/istioctl/) - Istio cli
- `gettext` - so you can use `envsubst` to substitute environment variables in your CI/CD pipeline

## Examples

Why should I use `envsubst`? You should never put secrets into your version
control, so you might want to keep them in secret variables in your CI/CD
system. You can use `envsubst` to substituted them correctly in your templates.

A CI/CD system usually sets a bunch of variables to the build environment.
Below I'll show an example of [GitLab CI variables set in the build environment](https://docs.gitlab.com/ce/ci/variables/#predefined-variables-environment-variables).

- `CI_PROJECT_NAME`: my_awesome_project
- `CI_BUILD_REF_SLUG`: f1234d

Your `app.yaml` could look similar the one below:

```yaml
...
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: ${CI_PROJECT_NAME}
    name: sample
  spec:
    replicas: 1
    selector:
      app: ${CI_PROJECT_NAME}
      deployment: ${CI_BUILD_REF_SLUG}
...
```

After `cat app.yaml | envsubst > app.yaml` you'll notice the variables have
been replaced with their actual values:

```yaml
...
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: my_awesome_project
    name: sample
  spec:
    replicas: 1
    selector:
      app: my_awesome_project
      deployment: f1234d
...
```

## GitLab CI example

Below a sample job in an `.gitlab-ci.yml` file:

```yaml
deploy:
  image: spaceonfire/k8s-deploy-tools
  stage: deploy
  before_script:
    - oc login "$KUBE_URL" --token="$KUBE_TOKEN" --insecure-skip-tls-verify
    - oc project "$KUBE_NAMESPACE" 2> /dev/null || oc new-project "$KUBE_NAMESPACE"
  script:
    - cat app.yaml | envsubst > app.yaml
    - oc apply -f app.yaml
```
