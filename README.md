## Creating AWS Account
* create a new user for provisioning everything else (download credentials)
* set up mfa for new user
* add new user to administrators group
* set password policy
* setup new profile in ~/.aws/credentials called anz_assessment

## prerequisites
* terraform > 0.13.0 installed
* aws cli installed
* docker installed
* export the following environment variables from the root of this repo

```
export AWS_PROFILE=anz_assessment
```

## Terraform
First we need to create the minimum resources required to support remote state in s3. To do this we store the state for this step in a local file base backend.

```
cd $SERVICE_ROOT/terraform/00-init
terraform init
terraform plan (check results)
terraform apply (check results, type yes)
```

The state from this init stage is committed to the git repo to allow sharing and versioning of changes to state.

Next we create the network using an open source vpc module - https://github.com/terraform-aws-modules/terraform-aws-vpc

The state for this stage and following stages will be stored in the s3 bucket created during the init stage with locking managed in a dynamodb table

```
cd $SERVICE_ROOT/terraform/01-network
terraform init
terraform plan (check results)
terraform apply (check results, type yes)
```

Now we create security groups and iam roles for the EKS control plane and 
worker nodes

```
cd $SERVICE_ROOT/terraform/02-security
terraform init
terraform plan (check results)
terraform apply (check results, type yes)
```

Next we create the EKS cluster and worker nodes

```
cd $SERVICE_ROOT./terraform/03-kubernetes
terraform init
terraform plan (check results)
terraform apply (check results, type yes)
```

Before we can use kubectl for the new EKS cluster we need to get the kubeconfig

```
aws eks update-kubeconfig --name anz_assessment --region ap-southeast-2
kubectl config use-context <the context name will be output from the previous command>. 
```

You can confirm that kubectl is configured properly by running the following command:

```
kubectl get svc
```

Next up we need to create the ECR repository for our services docker images to be pushed to.

```
cd $SERVICE_ROOT/terraform/04-auxiliary
terraform init
terraform plan (check results)
terraform apply (check results, type yes)
```

## Build the docker image
First we need to get the repository uri from terraform:

```
cd $SERVICE_ROOT/terraform/04-auxiliary
export REPO_URI=`terraform output service_repository_uri`
```

Build the image from dockerfile:

```
docker build -t $REPO_URI:local .
```

test run the built image:

```
docker run -p 8000:8000 $REPO_URI:local
```

Next we need to login to the AWS ECR repo with docker

```
$(aws ecr get-login --no-include-email)
```

Now we push the image up

```
docker push $REPO_URI:local
```

## Helm

First we need to init helm:
Ideally you would follow the recommendations in the following page to secure tiller (or run tiller locally) - https://helm.sh/docs/using_helm/#securing-your-helm-installation

For this assessment we are saving time by just installing tiller with RBAC that only allows access to the namespace anz-assessment

```
kubectl apply -f $SERVICE_ROOT/helm/init/tiller-RBAC-config.yaml
helm init --service-account tiller --tiller-namespace anz-assessment
helm install --tiller-namespace ap-assessment --namespace anz-assessment $SERVICE_ROOT/helm/
```

Use the following command to see when the webapp service has finished provisioning (EXTERNAL-IP will go from pending to a dns name)

```
kubectl get svc webapp -n anz-assessment -w
```

you can use that service http://EXTERNAL-IP:8000 to confirm that everything deployed successfully

## Diagrams

### Network
![Network diagram]()

The network is configured to provide a secure fault-tolerant environment for the application to run. All resources are deployed into private subnets (most with internet access via availability zone specific NAT Gateways, one with no internet access at all). Seperate subnets are provided for deploying common AWS managed services to limit exposure from AWS related security vectors. Public subnets are provided for Load Balancers. 

The Network layer leverages an open source VPC module for terraform. The intention of this it to reduce maintenance and chance of human error in misconfiguration of network resources. (Ideally this module would be vendored to ensure it remains available and the upgrade process can be managed to allow peer review before changes are implemented)

### Service
![Service diagram](https://github.com/perminder21/ANZ-Assessment/blob/main/images/ANZ-Assessment-Service-diagram.png)

The application is deployed as a kubernetes Deployment with a replica count of 2 pods. The pods are configured to try and deploy to nodes located in different failure-domains (based on availability zone tags on the instances). If it is unable to deploy to a seperate zone, it will deploy to the same zone so that the correct number of pods will be running.

### Terraform
![Terraform strategy](https://raw.githubusercontent.com/perminder21/ANZ-Assessment/master/images/ANZ-Assessment-Terraform-strategy.png)


#### Layered Terraform
Each successive layer of the terraform loads the remote state of the previous layers of terraform.

00-init - This layer creates the resources required for securely storing the remote state of the later layers. This stack uses the local file system to store it's state. This state is then committed to the git repository for version control and sharing.

01-network - This layer creates the vpc resources for running the EKS cluster

02-security - This layer create the security controls used by EKS

03-kubernetes - This layer creates the EKS cluster and the worker nodes

04-auxiliary - This layer create the resources required for deploying the service. At this stage it is only the ECR Repository. In the future it could also create codepipeline and codedeploy resources

## Resources
Multistage dockerfile for golang - https://medium.com/travis-on-docker/multi-stage-docker-builds-for-creating-tiny-go-images-e0e1867efe5a
Thanks for challenge, learnt a bit about it, while doing test.

