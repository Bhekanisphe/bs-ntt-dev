A VPC is a logically isolated portion of the AWS cloud within a region

Subnets - Availability Zone
Launch resources (EC2) to VPC Subnets
Internet gateway used to connect to the network

Route table is used to configure the VPC router

CIDR - Classless Interdomain Routing

Each VPC has a different block of IP address
Each subnet has a block of IP addresses from the CIDR block

VPC subnets have a longer subnet mask than the CIDR block by using additional bits from the host portion

VPC --> EC2, RDS EFS
Non VPC --> DynamoDB, S3, Route 53 CloudFront, Internet gatewa (Both)

Stateful firewall allows the return traffic automatically
Stateless firewall check for an allow rule for both connections

ACL - Networck Access Control List

NACLs apply at the subnet level --. Stateless
NACLs apply to traffic entering / exiting the subnet

Security Groups - applied at instance level -- Only allow rules

EBS used by EC2

EC2 hosts are managed by AWS
EC2 instances are amanged by the customer

Storage is always charged for the capacity
Instances is stopped when not needed -- can be terminated

Instance falmalies provide varying combinations of hardware resources - optimised for different compute workloads

m5.Large
M-family, 5-

Elastic Network Interface ENI
VPC->Subnet->AZ

Public -> Changes when stopped. Chargeable. Cannot be moved
Private -> Retained when the instance is stopped. Used in bth private and public\

ENI
ENA - Enhanced performance
EFA - High performance

EBS
Attached over the network -- must be in the same AZ

Instance store volumes are ephemeral (Non Persistant)

Snapshot, point in time state.. back up --> stored in S3. Incremental


EFS (Lenux only)
Regional file systems have mount targets in multiple AZ
instances connect to mount points in local AZ
Connection protocol is NFS

OneZone file system have mount targets

EFS
Data consistenncy
File locking
Storage classes:
    EFS Standard uses SSD for low latency performance
    EFS Infrequent Access - cost effective
    EFS Archive - Even cheaper for less active daya
Durability
EFS repliation
Automatic backup
Performance Options - 
    Provisioned 
    Bursting throughput - Scale

Uses NFS Protocol

Can mount to another region, but the file system is read-only

On-prem can mount using VPN - Linux

EC2 Metadata::
169.254.169.254/latest/meta-data

User Data:
Code that runs when instance launches for the first time
Must be base64-encoded
Limited to 16kB in raw form

*EC2 Auto Scaling*
Autolaunch and terminate instances
Maintain availablility and scale capacity
Works with EC2 EKS ECS
Intergrates with:
    CloudWatch
    ELB for distributing connections
    EC2 Spot Instance for cost optimisation
    VPC for deploying instances across AZs

Cloud watch :: Metrix report: CPU>80 -- Launch new instance
Health CHeck : 
    EC2 Status check
    ELB 
Helath check grace period
    How long should we wait

Manual Auto SCailing - ASG size manually
Dyanmic - Automatic based on demand
Predictive
Scheduled

ELB Elastic load balancing
Provide high availability and fault tolerance
Target include:
    EC2, ECS, IP addresses, Lambda f(x), Other load balancers

Application Load Balancer:
    Request level
    Route based on content of the request (L7)
    Supports path based routing, host-based routing, query string parameter based-routing and source IP address-based routing
    Supports instances, IP addresses, Lambda funtions and containers as targerts
    Use cases:
        Web apps with L7 routing HTTP/S
        Microservices architectures eg Dockercontainers
        Lambda targets

Network Load balancer
    Connection level
    Route connections based on IP protocol data (L4)
    Offers ultra high performanc, low latency and TLS offloading at scale
    Can have a static IP / Elasting IP
    Supports UDP and ststic IP addresses as target
    Use cases:
        TCP/UDP based apps
        Ultra low latency
        Static IP addresses
        VPC endpoint services

Gateway Load Balancer
    Used in front of virtual appliances such as firewalls, IDS/IPS, and deep packet inspection systems
    Operae at L3 - listens for all packets on all ports
    Forwards traffic to the TG specifired in the listener rules
    Exchanges traffic with appliances using GENEVE protocol on port 6081
    Use cases:
        Deploy, scale and manage 3rd party network appliances
        Centrailised inspection and monitoring
        Firewalls, intrusion detection and prevention systems and deep packet inspection systems