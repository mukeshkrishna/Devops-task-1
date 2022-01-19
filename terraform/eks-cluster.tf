
terraform {
  backend "s3" {
    bucket = "myapp-terrafrom-state-bucket"
    key = "myapp/state.tfstate"
    region = var.region
  }
}

# Kuberenetes provider will be used by Terraform to access k8s resources, to connect to EKS to do inital bootstrapping
provider "kubernetes" {
    # This tells not to load the config file from the default location and we will be creating new one
    load_config_file = "false"
    # Get the configured EKS cluster's Endpoint which was configured using eks module
    host = data.aws_eks_cluster.myapp-cluster.endpoint
    # Get the configured EKS cluster's token which was configured using eks module
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    # Get the configured EKS cluster's ca-certificate which was configured using eks module
    # Since the ca-cert is stored internally in k8s as 
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

#Please refer outputs.tf in kubernetes module to understand what all are exposed
data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster" {
    name = module.eks.cluster_id
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "13.2.1"
    
    cluster_name = var.cluster_name
    cluster_version = var.k8s_version

    #private_subnets,vpc_id are exposed in outputs.tf in eks module
    subnets = module.myapp-vpc.private_subnets
    vpc_id = module.myapp-vpc.vpc_id

    tags = {
        environment = var.env_prefix
        application = "myapp"
    }
    # we are creating standalone instance and not as nodegroup and fargate
    worker_groups = [
        {
            instance_type = "t2.medium"
            name = "worker-group-2"
            asg_desired_capacity = 1
        }
    ]
}

# Create a local file with kubeconfig.yaml once the eks cluster is provisioned
resource "local_file" "kube_config_file" {
    content  = module.eks.kubeconfig
    filename = "kubeconfig.yaml"
    file_permission = "400"
}
