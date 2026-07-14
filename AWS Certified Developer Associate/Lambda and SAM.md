Serverless Services:
    No instances to manage
    No provisioning of hardware
    No management of operating sys or software
    Capacity provisioning and patching is handled automatically
    Provides auto scaling and high availability
    Cheap

AWS Lambda:
    Price depends on memory and duration
    Max 15 minutes
    Syncronise invocation - apps waits for the function to process the event and return a response
    Asyncronise invocation - app sends the event to the function and continues processing. The function returns a response when it finishes processing the event
    Lambda scalees horizontally by running multiple instances of a function in parallel up to concurrent limit
    Lambdas are regional
    Can be connected to a VPC
    NAT gateway is required for internet connectivity
    The function execution role must have a permissions to create the ENIs

    Invocation:
        Lambda console
        URL HTTP/S endpoint
        Lambda API
        AWS SDK
        AWS CLI
        AWS Toolkit
        Other AWS services
        invoked when reading from a stream or queue
        sync/async

        Sync - 
            Lambda waits for the function to process the event and return a response
            The function returns a response to the invoker when it finishes processing the event
            to use CLI use invoke command:
                aws lambda invoke --function-name name --payload '{ "key" : "value"}' response.json
                The payload is a str that contains an event in JSON format
                response -> response.json
                to get the logs for an invocation from the command line use the --log-type option. The response include LogResult feild that contains up to 4KB

        ASync -
            Lambda handles retries and can send invocation records to a destinatiokn
            Places the event in a queue and returns a success response without additional information
            To invoke set invocation type param to Event

        Event Source mapping :
            To process items from a stream or queue, you cancreate an event source mapping 
            An event source mapping is an AWS lambda resource that reads from an event source and invokes a lambda function
            process items from a stream or queue
            used for processing events in (Made in the Lambda itself):
                SQS
                Kinesis
                DynamoDB
            For other eg S3 and SNS, the function is invoked Async and the config is made on the source (S3/SNS) rather than Lambda

            Event notifications:
                S3 can sent event to a Lambda function when an object is created or deleted
                You configure notification settings on a bucket and grant the S3 permission to invoke the function on the functions resource based permissions policy
                S3 invokes your funct async with an event that contains details about the object

        aws lambda invoke --function-name myfunction response.json  --> Sync
        aws lambda invoke --function-name myfunction --nvocation-type Event response.json   --> Async

        Versioning:
            You work on the $LATEST which is the latest version of the code with is mutable
            When youre ready to publish a Lambda function you create a version - these are numbered

            aws lambda invoke --function-name myfuction:1 respose.json --> runs version "1"
        Aliases:
            can point to two versions of a function 
            App code points to the alias
            MyFunction:myapplalias

    Deployment packages:
        2 types:
            Container images
                The base operating sys
                The run time
                Lambda extensions
                App code and its dependencies
                Container images are uploaded to the Amazon Elastic Container Registry ECR
                The image is then deployed to the Lambda function
            .zip file archives
                Is uploaded from S3 or your computer
                Limits:
                    50 MB - Zipped, for direct upload
                    250 MB - Unzipped
                    3 MB - Console editor

        Through CloudFormation:
            AWS::Lambda::Function resource create a Lambda function
            the function code zip file must be stored in S3
            Must be in the same region
            You need a cloudformation template file
            Set the package file to:
                Image for container images
                Zip for .zip archives
    Layers
        You can configure your Lambda func to pull in additional code and content in the form of layers
        A layer is a ZIP archive that contains libraries, a custom runtime or other dependencies
        With layers, you can use libraries in your func withoutneeding to include them in your deplyment package
        A funct can use up to 5 layers at a time
        Layers are extracted to the /opt dir in the funct execution env
        Each runtime looks for libraries in a different location under /opt, depending on the language
        Use the update-function-configuration

    Environment variabels
        aws lambda update-function-configuration --function-name myfunction \ --environment "Variables={BUCKET=my-bucket,KEY=file.txt}"

        when viewing the func config with ge-function-configuration we can see theresult

    Limits:
        Memory -> 128MB to 10240 MB in 1 MB increment 
        timeout 900 sec
        Environment variables - 4KB for all 
        Layers - up to 5
        Burst concurrency - 500-300 depemding on the region
        Invocaton payload - 6Mb(Sync) 256Kb (ASync)
        container image code package size - 10Gb
        /tmp dir storage 512Mb to 10240Mb in 1Mb increments

    Success and Falue Destination
        Send invocation records to a destination when your funct is invoked
        The execution record contains details about the request and response in JSON format 
        Info includes:
            Version, Timestamp, Request context, request payload, response context, response payload
    Dead-Letter Queue
        Saves uprocessed events for further processing
        Applies to Asynch invocation
        DLQ can be SQS queue or SNS topic
        When editing Async config, you can specify the number of retries
    

    Concurrency
        Reserved concurrency - guarantees a set number of concurrent instances for a critical function
            to throttle the concurrency make the reserved to 0
        Unreserved concurrency - the remaining pool of concurrency that is shared by all other functions in the account
        Provisioned concurrency - keeps a specified number of Lambda instances initialized and hyper ready to respond in double-digit milliseconds


        Limits:
            Reserved concurrency - 1000 per region
            Unreserved concurrency - 1000 per region
            Provisioned concurrency - 1000 per region

            1000 invocations at any given time per region
            default burst concurrencyquota per region is between 500 and 3000, wich varies per region 
            Therre is no max concurrency limit for Lambda funct
            To avoid throttling request per limit increases atleast 2 weeks ahead of time

    Performance monitoring
        Lambda automatically monitors Lambda functions on your behalf and sends metrics to CloudWatch
        Metrics include:
            Invocations, Duration, Error count, Dead-letter errors, Throttles, Iterator age, Concurrent executions, Unreserved concurrent executions
        You can view metrics in the Lambda console or in CloudWatch
        You can also create custom metrics and send them to CloudWatch using the AWS SDK

        Make sure to have permissions to write to the logs

        "logs:CreateLogStream"
        "logs:PutLogEvents"

        Tracing with AWS X-Ray
            You can use AWS X-Ray to visulize the components of your app, identify performance bottlenecks, and troubleshoot requests that resulted in an error
            Your lambda funct send trace data to X-Ray, and X-ray processes data to generate a service map and searchable trace summaries
            AWS Xray Deamon is a software app that gathers segment data and relays it to the AWS Xray service
            The deamon works in conjunction with the AWS Xray SDKs so that data sent by the SDKs can reach Xray service
            The funct needs permissions to write to XRay i the execution role
    

    Lambda in a VPC and ALB targets
        You must connect to a private subnet with a NAT gateway for Internet access - no public IP
        Careful with DNS resolution of public hostnames as it could add to funct running time (cost)
        Cannot be connected to a dedicated tenancy VPC
        Inly connect to a VPC if you need to, it can slow down funct execution
        Permissions:
            ec2:CreateNetworkInterface
            ec2:DescribeNetworkInterfaces
            ec2:DeleteNetworkInterface
        These permissions are included in the AWSLambdaVPCExecutionRole managed policy

        ALB supports lambda functions as targets
        You can register your Lambda functoins as targets and configure a listener rule to forward requests to the target group for your Lambda function

        the content of the request is passed in JSON format

        Limits:
            Same acc same region
            Max size of request/responce 1Mb
            Websockets are not supported. Upgrade request are rejected with an HTTP 400 code
            Local zones are not supported

    Security for Lambda functions:
        Recommended to use Secretes managerinstead of environment variables
        Files, deployment packages are encrypted at rest with KMS key
        Func execution role must provide permissions to AWS services
        Lambda API endpoints only supports TLS connections

        AWS Signer:
            Is a fully managed code signing service
            Used to ensure the trust and integrity cof code
            Code is validated against a digital signiture
            With Lambda you can ensure only truested code runs win Lambda functions
            IAM policies can enforce that funct can be created only if they have signing enabled
            If a dev leaves you can revoke all versions of signing profile so the code cannot run

    Best Practises - function code
        Separate the lambda handler from your core logic 

        take advantage of execution env reuse to improve the performance of your funct
            Initialize SDK clients and db connections outside of the function handler
            Cache static assets locally in the /tmp dir
            Subsuquent invocations processed by the same instance of your funct can reuse these resources
            This saves costs by reducing funct run time

        Use a keep-alive directive to maintain persistant connections

        Use enviroment variables to pass operational parameters to yoiur function

        Control dependencies in your functions deployment package

        Minimise your deployment package size to its runtime necessities
        Avoid recussive code in your funct    
    
    AWS serverless Application Model
        AWS SAM is an open-source framework for building serverless applications
        It provides shorthand syntax to express functions, APIs, databases, and event source mappings
        You can define the application you want with just a few lines of code
        The AWS SAM CLI provides a Lambda-like execution environment that lets you locally build, test, and debug serverless applications defined by AWS SAM templates

        has Transform header

        commands:
            sam package
            sam deploy

        Same as CloudFormattion

        sam package -t template.yaml --s3-bucket dctlabs --output-template-file package-template.yaml
        sam deploy --template-file packaged-template.yaml --stack-name my-cf-stack

        alternatively run:
        aws cloudformation package --template-file template.yanl --s3-bucket dctlabs --output-template-file packaged-template.yaml
        aws cloudformation deploy --template-file packaged-template.yaml --stack-name my-cf-stack

        resource types:
            AWS::Serverless::Function (AWS Lambda)
            AWS::Serverless::Api (API Gateway)
            AWS::Serverless::SimpleTable (Dyanmodb)
            AWS::Serverless::Application (AWS serverless app repo)
            AWS::Serverless::HttpApi (API gatewat HTTP API)
            AWS::Serverless::LayerVersion (Lambda layers)




