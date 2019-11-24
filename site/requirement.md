# Requirement DevOps Toolchain 

## Terraform musst runing from Comand Line interface (Download it from https://www.terraform.io/downloads.html)
```sh
terraform --version
```

## AWS CLI musst runing from Comand Line interface (Download it from https://aws.amazon.com/de/cli/)
```sh
aws --version      (Linux)
awscli --version   (Windows)
```

## AWS Admin User musst existing
![AAU](https://raw.github.com/eddi888/devops-toolchain/master/site/aws-admin-user.png)

## AWS User musst configured
```sh
awscli configure
```


## The configvariables.tf musst modified
///TODO DESCRIPTION


## Test the plan
```sh
terraform init
terraform plan
```

