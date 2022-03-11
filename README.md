# Config Connector Demo


## 1. GCP Infrastructure

The following resources will be deployed through terraform in [/infra] folder

* VPC Network
* Subnet in europe-west2
* GKE Cluster in europe-west2 with Config Connector add-on and Workload Identity
  enabled
* Node Pool
* Workload Identity Service Account

Edit the infra/terraform.tfvars file with the project id
Run `terraform apply`

## 2. Config Connector namespace and CRD's

Deploys the core config connector resource manager and attaches to the service
account provisioned in step 1

1. Edit the cnrm.yaml file and update the ConfigConnector googleServiceAccount
   from the output from step 1

2. Update the namespaces with the required names and project id's

Run `kubectl apply -f krm/cnrm.yaml`

## 3. GCP Resources through Config Connector




## 4. Commands for demo

Reconilliation occurs every 10 minutes

~~Get resources deployed~~ `kubectl get gcp -n <NAMESPACE>`

~~Tail reconcilliation logs~~ `kubectl logs cnrm-controller-manager-0 -n
cnrm-system manager -f`

Delete some resources in pantheon and then force a reconciliation by `kubectl
delete pod cnrm-controller-manager-0 -n cnrm-system`  it should reconcile after
5 - 10 seconds

