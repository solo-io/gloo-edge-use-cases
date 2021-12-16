# AWS ELB Integration
This section is meant to be a companion to the Gloo Edge documentation for [AWS Elastic Load Balancer integration](https://docs.solo.io/gloo-edge/latest/guides/integrations/aws/#recommended-controller-aws-load-balancer-controller).  Here, you can find scripts and examples to help ease your setup on AWS.

## Setting up the IAM account
The `setup-iam.sh` script can assist with automating IAM account creation for your AWS cluster.  

### Pre-requisites
- [eksctl](https://eksctl.io/)
- [aws client](https://aws.amazon.com/cli/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)


### Running the script
The script has three mandatory arguments:
- cluster : AWS cluster name
- region : AWS region
- account_id : AWS account id

```
./create-iam <cluster> <region> <account_id>
```