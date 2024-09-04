Cloud Engineering Take-Home Assignment

In this project I demonstrated the deployment of a simple API that was built with Java to Google Cloud Platform (GCP) using Kubernetes (GKE) and Terraform as Infrastructure as code. The API returns the current time in a JSON format when accessed via a GET request and the deployment process is fully automated using GitHub Actions for Continuous Integration & Continuous Deployment (CI/CD). 
This project showcases my prowess in cloud engineering, infrastructure automation, Kubernetes management, security best practices, and CI/CD pipelines.

Project Structure
A GitHub Actions workflow folder named .github that contains a workflow subfolder which has the automation script that automates the entire deployment process, including infrastructure provisioning, Docker image building, API deployment.
An src folder that contains the folder structure of a java application using springboot to develop the API that returns the current time in JSON format. The API is containerized using Docker.
A Terraform folder that contains infrastructure as code used to create the entire infrastructure on GCP, including the GKE cluster, NAT gateway, IAM roles, VPC networking, and Kubernetes resources (Namespaces, Deployments, Services, Ingress, kubernetes manifest).

Deliverables
GitHub Repository:
Link: https://github.com/Joshrichhy/shortlet-time-challenge.git
 Contains the following:
Terraform code for infrastructure setup, including all Kubernetes resources.
Dockerfile and Kubernetes manifests defined in Terraform.
GitHub Actions workflow.
API source code.
README file with instructions on how to run and test the setup locally.
Deployed API Endpoint: http://34.67.222.198/shortlet/time
GitHub Actions Workflow Run: Link to the successful workflow run that deployed the infrastructure and API. https://github.com/Joshrichhy/shortlet-time-challenge/actions/runs/10691176748

How to Run and Test Locally
1. Clone the Repository:
Open your shell or terminal 
Run git clone https://github.com/Joshrichhy/shortlet-time-challenge.git
Run cd shortlet-time-challenge
Open the folder using an Integrated Development Environment(IDE) or VS code

2. Set Up Environment Variables:
Open the terraform folder : There are two subfolders, gke-cluster and kubernetes-resources
Configure the necessary environment variables for GCP credentials and project details in the terraform.tfvars file. It contains the following
Project_id: <Input your project id you created in your GCP>
region: <Input your region to create resources>
Gke_service_account: <The email of the service account to use for GKE>

3. Setup GCP CLI on your machine and configure it with your credential
4. Setup Docker as well
5. Build and Run the API Locally:
    Run docker build -t time-api .
    Run docker run -p 8678:8678 time-api
	Note: Port 8678 is the port i specified in the Dockerfile
    Access the API at http://localhost:8678/shortlet/time

6. Provision Infrastructure using Terraform:
  Start by entering the gke-cluster to provision the vpc, subnet, nat router, nat-gateway, the kubernetes cluster, the service-account, the I_AM
       Run cd terraform/gke-cluster
       Run terraform init
       Run terraform apply -auto-approve
  To get your Kubeconfig to run the next step
      Run gcloud container clusters get-credentials api-time-kube-cluster --zone <your region> --project <your project id>
  Note: api-time-kube-cluster is the name of the cluster i put in the terraform script
  This step provisions the nodes in the cluster, the deployment, the service, the namespace and the security
      Run cd ..
      Run cd kubernetes-resources
      Run terraform init
      Run terraform apply -auto-approve
  Terraform will automatically handle the deployment as part of the infrastructure provisioning process.

7. Test API Deployment:
    Use the provided Service_ip that was outputted  to verify the deployment.
    curl http://<service_ip>/shortlet/time 
    This should return the current time in a json format provided every steps passed

8. To Delete the Insfrastructure
		Run cd terraform/kubernetes-resources
		Run terraform destroy 
		Run cd ../gke-cluster
		Run terraform destroy


LINKS
GitHub Repository: https://github.com/Joshrichhy/shortlet-time-challenge.git
Deployed API Endpoint: http://34.67.222.198/shortlet/time
GitHub Actions Workflow Run: https://github.com/Joshrichhy/shortlet-time-challenge/actions/runs/10691176748

