VPC, EC2 and ELB:
    VPC:
        Logically isolated portin of the AWS cloud within a region
        VPC router takes care of routing within the VPC and outside of the VPC
        The route table is used to configure the VPC router
        An internet gateway is attached to a VPC and used to connect to the internet
        A VPC spans all the AZs in the regions
        Each VPC has a diffrrent block of IP addresses CIDR bloc
        Subnets are created within AZs
        Each subnet has a block of IP addresses from the CIDR block
    Security Groups:
        Applly at instance level
        can be applied to instances in any subnet
        Support aloow rules only
        Separate rules are defined for outbound traffic
        A source can be IP address or Security group ID
        NACLs apply at the subnet level
        NACLs apply only to trraffic entering / exiting the subnet
        Rules are processed inorder (numbered)
        NACLs have an explicit deny at the end
    EC2:
        Virtual server
        run Windows Linux or MacOS
        managed by AWS (hosts)
        An AMI defines the config of the instance
        You can customise your instance and create a custtom AMI
        A snapshot is a point-in-time backup of an instance
        User data is run when the instance starts for the first time
        Instance metadata is the data about your EC2 instance
        instance data is available at 169.254.196.254/latest/meta-data
    Access Keys:
        Best practice to use temporary security creds(IAM roles) instead of access keys
        Also, disable any AWS account root user access keys
        Associated with IAM acc
        Inherit permission of the IAM Acc
        IAM roles should be used intead of access keys where possible
    ELB:
        ELBs provide a single endpoint for your application 
        ELBs distribute connections to back-end instances, IPs, containers, and functions
        Target Groups are used for attaching the target applications to ELB
        The ALB is used for web applications with L7 routing (HTTP/S) and offers advanced routing 
        the GLB ditributes connections to applications like IDS, IPS, NGFW and WAF
    Sessions:
        Session state data can be stored in db such as DynamoDB and ElastiCache
        Can include temp data, meta data, auth information etc
        Sticky sessions can be used on ELBs to bind a session to an EC2 instance
        Sticky Session uses cookies that are generated at the ELB level
        You can use a combination of duration-based stickiness, app-based stickiness and no stickiness across your target groups
        Sticky Sessions are not supported with TLS listeners and TLS target groups (NLB)
    Extras:
        IGW are attached at VPC level
        VPC are regional
        fault tolrance -: Create multiple subnets each within a different AZ and launch EC2 instances running you app accross these subnets
        Keypairs are used to connect securely to EC2 instances. A key pair consist of a public key that AWS stores, and a private key file that youstore. For Linux the private key file allows you to connect securely SSH into your intance

IaC and PaaS:
    Elastic beanstalk config files (.ebextensions) can be added to your web apps source code
    USed to customize env and resources
    Config files are YAML or JSON formatted docs with a .config file extension
    They should be placed in the .ebextension folder in the app source code bundle 
    The option_settings section of the config file defines the values for the config options
    The Resources section lets you further customise the resources in your apps env
    SSL/TLS certs can be assigned to the env ELB (Can use ACM)
    The connections between clients and load balancer are secured