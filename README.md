This tutorial shows how to deploy a simple house price prediction model.

## How-to Guide

### Start Jenkins service locally
```shell
docker compose -f docker-compose.yaml up -d
```
You can find the password for `admin` at the path `/var/jenkins_home/secrets/initialAdminPassword` in the container Jenkins.

### Push the whole code to Github for automatic deployment
```shell
git add --all
git commit -m "first attempt to deploy the model"
git push origin your_branch

kubectl create ns model-serving
kubectl create sa jenkins -n model-serving
kubectl create clusterrolebinding model-serving-admin-binding \
  --clusterrole=admin \
  --serviceaccount=model-serving:jenkins \
  --namespace=model-serving

kubectl create clusterrolebinding anonymous-admin-binding \
  --clusterrole=admin \
  --user=system:anonymous \
  --namespace=model-serving

kubectl create secret generic jenkins-token   --from-literal=token=$(openssl rand -hex 16)   -n model-serving

kubectl patch serviceaccount jenkins   -n model-serving   -p '{"secrets":[{"name":"jenkins-token"}]}'

kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > ca.crt

kubectl get secret jenkins-token -n model-serving -o jsonpath='{.data.token}' | base64 --decode

```