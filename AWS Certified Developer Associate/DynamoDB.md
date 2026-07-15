Scales horizontally
Microseconds latecy can be achived with DynamoDB Accerator (DAX)
Global tables all region

control plate API:
    CreateTable
    DescribeTable
    Listtables
    UpdateTable
    DeleteTable

Data plane API:
    PutItem
    BatchWriteItem
    GetItem
    BatchGetItem
    UpdatItem
    DeleteItem

DynamoDB standard - default and recommended for most workloads
DyanmoDB Standard-Infrequent Access (DynamoDb Standaard-IA) - Loweer cost storage for tables that store infrequently accessed data such as:
    App logs
    Old social meadia posts
    E-cormmerce order history
    Past gaming archivements

Max size of a policy for DynamoDB is 20Kb

DyanmoDB partition and primary keys

Eventually consistent:
    When you read data from a table, the response might not reflect the results of a recently completed write operation
    The response might include some stale data
    If you repeat your read request after a short time, the response should return the latest data

Strongly cosnsistent
    most up to date data
    may nopt be available if there is a network delay or outage
    higher latency
    not supported on global secondary indexes
    more throughput capacity

Read capacity units (RCU)
    1 RCU = 1 strongly consistent read per second for an item up to 4KB in size
    1 RCU = 2 eventually consistent reads per second for an item up to 4KB in size
    1 RCU = 0.5 transactional read request per second

Write Capacity units (WCU)
    items up to 1Kb, one WCU can perform:
        One standard write request / s
        0.t transactional writes requests (1 transactional write requres 2 WCU)

On-demand capacity - auto scale

Performance and Throttling

    Provisioned capacity - you specify the number of RCU and WCU that you require for your application
    On-demand capacity - DynamoDB instantly accommodates your workloads as they ramp up or down to any previously reached traffic level

    If your application exceeds the provisioned throughput on a table or index, DynamoDB returns a ThrottlingException error
    If you receive a ThrottlingException error, you can retry the request with exponential backoff
    ProvisionedThroughtputThrottlingError

    Hot keys - one partition key is being read too often
    Hot partitions - when data access is embalanved, a hot partition can receive a higher volume of read and write traffic compared to ther traffics
    Large files

    Resolution:
        Reduce frequentcy of requests and use exponential backoff
        Try to design your app for uniform activity across all logical partition keys in the table and its secodary indexes
        Use burst capacity effectively - retains up to 5 mins of unused read and write capacity which can be consumed quickly
        Ensure adaptive capacity is enabled

Scan vs query
    Scan:
        Filter criteria can name any table attribute
        Evaluates each item to see if it meets desired criteria, discards unwanted results
        Reads ebery item from the tanle
        Slow and expensive on large tables/indexes
    Query:
        Filter criteria must include the partition key and can optionally include the sort key
        Evaluates only items that match the partition key value, discards unwanted results
        Reads only items that match the partition key value
        Fast and efficient on large tables/indexes

LSI and GSI
    Local Secondary Index
        Must be created at table creation time
        Provides an alternative sort key for scans and queries
        Uses the same pk but different sk

        Scope:
            An LSI is bound to a specific pk of the table. It is crreated at the time of table creation and cannot be modified later
        Attributes:
            Uses the same pk as the tables primary key but allows you to define different sk
        Query performance
            LSIs can provide low latency with strong consistancy
        Use case:
            When you have a table with wide range of query patten and a specific pk has high cardinality (ie many distinct values)
    Global Secondary Index
        Can be created at any time
        Provides an alternative pk and sk for scans and queries
        Uses different pk and sk  

        Scope
            independent of the table's pk and can be created or modified after the table is created. Each table can have multiple GSIs, and they can span across multiple partitions
        Attributes
            allows you to define its own pk and sk, which can be different from the table's pk. It creates a separate index with its own data structure
        Query performance
            provies flexibility in quering across the entire table, including different pk. 
        Use case
            when you need to query the table based on different attributes or different combinations of attributes, regardless of the pk