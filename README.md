# aws_terraform
## Prerequisites:
- You have installed Terraform
- You have installed AWS CLI and configured profile to use with Terraform -  [link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#example-usage).  Alternatively the provider block can include keys as variables. 
- To be able to ssh into the EC2 instace make sure to replace key_name and public_key variables with the existing key. 
## File Structure:
- Code consists of 2 folders: root and module
- S3 bucket and auto scaling group doesn't include any variable so there is really no need for separate modules. It can be alternatively included under the VPC module in the structure of the resources. Overuse of modules can be more confusing in some instances. 
- Module consits of variables in case there will be need to have separate auto.tfvars folders for different environments, this makes the code easier to reuse in my opinion. 
- I have included the output of the public IP of the instance in Sub2, for convenience 
## Issues Faced:
- I have created similar infrastructures before so I was familiar with the task. The issue I have faced was to create separate lifecycle policies for the same S3 bucket based on prefixes. As per Terraform documentation - "S3 Buckets only support a single lifecycle configuration. Declaring multiple aws_s3_bucket_lifecycle_configuration resources to the same S3 Bucket will cause a perpetual difference in configuration." In this case I was able to use different prefixes and use the same lifecycle configuration. I found this link to be the most useful [link](https://github.com/hashicorp/terraform-provider-aws/issues/23132)
- I was not able to add storage to ASG. I have assumed that the task was to create EBS and have EC2 instances in the auto scaling group reuse it. I have found on Stack Overflow that there could be a user data script created for the EC2 to attach existing EBS volume. My assumpntion is that the user data script could be added to the EC2 lifecycle hook. Due to the time alloted for the project I was not able to deep dive and properly execute this part of the task. [link](https://stackoverflow.com/questions/60898996/attach-ebs-volume-to-autoscalinggroup)
## Resources:
- I have used official Terraform ducumentation to create all the resources, extra links provided above.
- Screenshot from the stand-alone EC2 below. 
-  <img width="1108" alt="red_hat_ec2" src="https://user-images.githubusercontent.com/111542965/213895865-689e8c71-3e67-4a4b-8bb5-e4ea3af0bb81.png">
Please let me know if there are any questions, I will appreciate any feedback on the task. Thank you. 
