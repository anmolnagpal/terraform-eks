<h1 align="center">
    Getting Started with AWS EKS
</h1>
<p align="center" style="font-size: 1.2rem;"> The Amazon Web Services EKS service allows for simplified management of Kubernetes servers. While the service itself is quite simple from an operator perspective, understanding how it interconnects with other pieces of the AWS service universe and how to configure local Kubernetes clients to managed clusters can be helpful. </p>
<hr />

# Guide Overview

##### The sample architecture introduced here includes the following resources:

- EKS Cluster: AWS managed Kubernetes cluster of master servers
- AutoScaling Group containing 2 m4.large instances based on the latest EKS Amazon Linux 2 AMI: Operator managed  Kuberneted worker nodes for running Kubernetes service deployments
- Associated VPC, Internet Gateway, Security Groups, and Subnets: Operator managed networking resources for the EKS 
Cluster and worker node instances
- Associated IAM Roles and Policies: Operator managed access resources for EKS and worker node instances

<br>

### Configure Kubectl

<br>
Now let's create a kubeconfig file for manging the EKS Cluster. Login to your kubectl node we created in step 4 and insert the codeblock to `.kube/config`
<br>

```
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

<br>

```
Replace EKS_ENDPOINT_URL with your EKS Endpoint URL, BASE64_ENCODED_CA_CERT with certificateAuthority and CLUSTER_NAME with EKS Cluster name. You can get all these details from EKS Cluster Console.
```

Save the configuration file and execute following commands to use it.

```
export KUBECONFIG=$KUBECONFIG:~/.kube/config
echo 'export KUBECONFIG=$KUBECONFIG:~/.kube/config' >> ~/.bashrc
```

Now test your configuration

```
kubectl get all
```
If everything is fine, you will get your cluster details :)

## 👬 Contribution

- Open pull request with improvements
- Discuss ideas in issues
- Reach out with any feedback [![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/anmol_nagpal.svg?style=social&label=Follow%20%40anmol_nagpal)](https://twitter.com/anmol_nagpal)
