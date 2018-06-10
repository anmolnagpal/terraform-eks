<p align="center"><img src="https://i.imgur.com/7994Qdm.png" /></p>

> Terraform module for simplified management of Kubernetes servers using EKS


## 🔆 Highlights

- **EKS Cluster** AWS managed Kubernetes cluster of master servers
- **AutoScaling Group** contains 2 m4.large instances based on the latest EKS Amazon Linux 2 AMI
- **Associated VPC, Internet Gateway, Security Groups, and Subnets** Operator managed networking resources for the EKS 
Cluster and worker node instances
- **Associated IAM Roles and Policies** Operator managed access resources for EKS and worker node instances

### 🎨 Architecture

<p align="center"><img src="https://i.imgur.com/0eJ3ZAP.png" /></p>

### 🔰Getting Started

> Follow the steps below to get started

#### 🔨 Setting Up Kubectl

Create a kubeconfig file for manging the EKS Cluster. 

Login to your kubectl node and insert the codeblock to `.kube/config`


```yml
apiVersion: v1
clusters:
- cluster:
    server: EKS_ENDPOINT_URL
    certificate-authority-data: BASE64_ENCODED_CA_CERT   
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "CLUSTER_NAME"
        - "-r"
        - ""
 ```



Replace `EKS_ENDPOINT_URL` with your EKS Endpoint URL, `BASE64_ENCODED_CA_CERT` with `certificateAuthority` and `CLUSTER_NAME` with EKS Cluster name.

Save the configuration file and execute following commands to use it.

```sh
export KUBECONFIG=$KUBECONFIG:~/.kube/config

echo 'export KUBECONFIG=$KUBECONFIG:~/.kube/config' >> ~/.bashrc
```

Now test your configuration

```sh
kubectl get all
```

If everything is fine, you will get your cluster details :)

### Setup K8s Dashboard
- Refrence :
    - https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

## 👬 Contribution

- Open pull request with improvements
- Discuss ideas in issues
- Reach out with any feedback [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/anmol_nagpal.svg?style=social&label=Follow%20%40anmol_nagpal)](https://twitter.com/anmol_nagpal)
