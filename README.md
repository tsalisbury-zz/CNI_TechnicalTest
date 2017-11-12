# CNI Hello World App
This is a simple node.js application which reads `Hello World`.  It can be run locally using Docker so that developers may work on it in any environment and on any operating system.  The application can also be run in Amazon Web Services by deploying the infrastructure set out in the `infrastructure` directory of this repository.
The infrastructure is created using Terraform, so that it is maintainable and ready for extending in future if required.  To test the build and view what will be created, run `terraform plan`.

The AWS resources created consist of:
- A container repository which will store images/versions of the application.
- An ECS cluster comprised of two t2.micro EC2 instances, so that the application will be resilient in the event of one being terminated or becoming unavailable.  The two instances are created as an EC2 autoscaling group, which will maintain two instances at all times.
- 2 load balancers - one containing the EC2 instances, which will accept requests to the application over http, and one for the ECS service, which will accept requests to the ECS cluster from the instances.
- 1 security groups and 2 iam roles to allow secure access between the instances, the load balancers, the cluster and the container repository.

### Prerequisites
- An AWS account, with credentials set in `~/.aws/credentials`, so that infrastructure may be created from the command line, and a default region of `eu-west-1`.
- AWS cli tools installed
- Terraform installed.
- Docker installed and running.

## Running the application locally using Docker
From the root directory, run
```
docker build -t tsalisbury_cni_app .
docker run -p 80:8080 tsalisbury_cni_app
```
The application can then be accessed by browsing to `http://localhost`, and should simply say `Hello World`.


## Infrastructure Setup
The AWS infrastructure which will be made can be shown from within the `infrastructure` directory simply by running
```
terraform plan
```
To actually create it, run
```
terraform apply
```
Running the apply will give two outputs - the cni_repository_url, where the application images will be pushed, and the ec2_elb_dns_name, which can be pasted into a browser to view the application once it is deployed.


### Deploy the application
To deploy the application, the container image must be pushed to the registry.  The ecs service will then deploy it to the instances in ec2, according to the task definition specified.

The image can be built and pushed to the registry as follows.

First, log into the registry.  The command to log in can be obtained by running
```
aws ecr get-login
```
Paste the output of this command into the cli.  (Note: I have found it necessary to remove `-e none` from this output to make login possible.)

Then, from the root directory, build and push the container image by running
```
docker build -t <cni_repository_url> .
docker push <cni_repository_url>
```

Once the container is pushed to the registry, it will be installed by the ecs agent on the ec2 instances.  This can be checked from the ECS console, by going to the cluster `tsalisbury_cni_cluster` clicking on `tsalisbury_cni_service` and clicking the `Events` tab.  This can also be verified by logging into the ec2 instances (an ssh key is supplied in the `ec2-ssh-key` directory), and checking `/var/log/docker`, or simply by running `docker ps -a`.

Once the containers have been pulled and are running, the app will be available by going to `http://<ec2_elb_dns_name>` in a browser.

### Updating the application
Updating the application is a two step process.  Firstly, once the app has been modified, push the new container image to the registry.  Then, the ECS service must be updated, which will update the container on the ec2 instances.

To push the new version to the registry, use `docker build` and `docker push` as specified above.

To create a new revision of the task definition, run
```
aws ecs update-service --cluster tsalisbury_cni_cluster --service tsalisbury_cni_service --task-definition tsalisbury_cni
```
This will update the ECS service, which will then pull and run the updated docker image from the regsitry.  The updated application can be viewed at `http://<ec2_elb_dns_name>`.
