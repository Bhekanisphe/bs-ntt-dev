Templates
    Json/YAML
If the stack is deleted, the infrastructure is deleted
Change set - Change existing resource

Use intrinsic functions in your templates to assign values to properties that are not available until runtime

!Ref 
    returns the value of the specified parameter or resource
    parameter logical name --> value of the parameter
    resource locical name --> value that can be used to refer to that resource 
Fn::GetAtt
    returns the value of an attribute from a resource in the template
    resource logical name --> attribute name --> value of that attribute
Fn::FindInMap
    returns map values

AWS::Serverless
    transform specifies the version of AWS serverless application model (AWS SAM) to use
    This model defines AWS SAM syntax that you can use and how AWS CF processes it
AWS::Include
    transform wors with template snippets that are stored separately from the main AWS CF template

Iaas
    Eg EC2
    You manage virtual servers 
PaaS
    You upload your code/data to create your application
    Eg AWS Elastic Beanstalk

Webservers are standard app that listen for and then process HTTP requests, typically over port 80
Workers are specialised apps that have a bachround processing task that listens for messages on SQS queue
Workers should be used for long-running tasks

Worker polls the queue

You can add AWS Beanstalk config files (.ebextensions)to your web app's source code to configure your env and customise the AWS resources that it contains
Config files are YAML or JSON docs with a .config file extension that you place in a folder named .ebextensions and deploy in your app source bundle

option_setting section define the values for config options
The resources section lets you further customise the resources in your applications environment and define additional AWS resources beyond the functionality provided by config options
Additional sections of a config file let you configure the EC2 instances that are launched in the env
these include packages, sources, files, users, groups, commands, conatiner_commands, and services

Using HTTPS with Elastic Beanstalk
    SSL/TLS certificates can be assigned to an environment's ELB
    Can use ACM
    The connections between clients and the load balancer are secured
    Backend connections between the load balancer and EC2 instances are not secured
    You can configure the certificate through the console or through the .ebextensions:
        '''
        option_settings:
            aws:elbv2:listener:443:
                listenerEnabled: 'true'
                Protocol : HTTPS
                SSLCertificateArns: arnXXX
