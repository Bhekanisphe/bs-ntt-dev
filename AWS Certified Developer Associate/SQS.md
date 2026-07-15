SQS is pull based 
Messaeges are up to 250Kb in size
Larger messages can be snt using amazon SQS Extended Client Library for Java
Messages are kept in the queue from 1 minute to 14 days
Default retention is 4 days
Message processes atleast once

FIFO
    3000 messages/second
    Requires Message group ID and Message Deduplication ID

    Message Group ID
        The tag specifies that a message belongs to a specific group
        Messages that belong to the same message group are guaranteed to be processed in a FIFO
        Messages with a different Group ID may be received out of order
    Message Deduplication ID
        the token used for deduplication o messages within the deduplication interval
        5 mins interval
        Generated as SHA-256 with the message body
Standard queue
    unlimited number of transactions/second

Dead Letter Queue
    Handles message falue
    Not a type of queue but a config
    Messages are moved to the dead-letter queue when ReceiveCount for a message exceeds the maxRecieveCount 
    Should not be used with standard queue when your app will keep retrying transmission
Delay Queue
    LArge distributed apps which may need to introduce a elay in processing
    You need to apply a delay to an entire queue of mesages

Visibility timeout
    Provided the job is processed before the visisbility timeout expires, the message will then be deleted from the queue
    If the job is not processed within the visibility timeout, the message will become visisble again and another reader will process it
    This could result in the same message being delivered twiiice
    Defauly - 30 sec
    Max 12hrs

Short polling - checks a subset of seervers and may not return all messages
Long polling - qaits for the WaitTimeSeconds and eliminates empty responses --- up to 20 secs