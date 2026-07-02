import json
import boto3
import uuid

instance_id = '6e669f6f-3783-4c0e-ac76-4f531575015d'
connect = boto3.client('connect')
table_name = 'bs-automated-testing-iac'
key_name = 'flow_name-testing_option'
pk_value = ''

def config():
    region = 'af-south-1'
    account_id = '687244881512'

    dynamodb = boto3.client('dynamodb')

    dyanmodb_data = dynamodb.get_item(
        TableName = table_name,
        Key={'flow_name-testing_option' : {'S': 'BM-Test-Flow-IaC:1-Timeout'}}
    )

    def get_menu_levels():
        menu_levels_data = dyanmodb_data['Item']['menu_levels']['M']
        menu_levels = []

        for menu_level in menu_levels_data:
            menu_levels.append({
            'identifier' : menu_levels_data[menu_level]['M']['identifier']['S'],
            'message' : menu_levels_data[menu_level]['M']['message']['S'],
            'user_action' : menu_levels_data[menu_level]['M']['user_action']['S'],
            'next' : menu_levels_data[menu_level]['M']['next']['S']
            })
        return menu_levels
    
    def get_retry_levels():
        retry_levels_data = dyanmodb_data['Item']['retry_levels']['M']
        retry_settings = {}
        
        default_retry_levels = {
            "attempts" : retry_levels_data['default']['M']['attempts']['N'],
            "wrong_action" : retry_levels_data['default']['M']['wrong_action']['S'],
            "retry_message" : retry_levels_data['default']['M']['retry_message']['S'],
            "transfer_message" : retry_levels_data['default']['M']['transfer_message']['S'],
        }

        timeout_retry_levels = {
            "attempts" : retry_levels_data['timeout']['M']['attempts']['N'],
            "retry_message" : retry_levels_data['timeout']['M']['retry_message']['S'],
            "transfer_message" : retry_levels_data['timeout']['M']['transfer_message']['S'],
        }

        retry_settings.update({"default": default_retry_levels, "timeout": timeout_retry_levels})

        return retry_settings

    queue = connect.describe_queue(
        InstanceId = instance_id,
        QueueId = dyanmodb_data['Item']['queue_id']['S']
    )
    hoo = connect.describe_hours_of_operation(
        InstanceId = instance_id,
        HoursOfOperationId = dyanmodb_data['Item']['hoo_id']['S']
    )

    test_case_data = {
        'instance_id' : instance_id,
        'region' : region,
        'account_id' : account_id,
        'flow_name' : dyanmodb_data['Item']['flow_name-testing_option']['S'],
        'description' : dyanmodb_data['Item']['description']['S'],
        'flow_id' : dyanmodb_data['Item']['flow_id']['S'],
        'hoo_id' : dyanmodb_data['Item']['hoo_id']['S'],
        'hoo_results' : dyanmodb_data['Item']['hoo_result']['S'],
        'queue_id' : dyanmodb_data['Item']['queue_id']['S'],
        'welcome_text' : dyanmodb_data['Item']['welcome_text']['S'],
        'menu_levels' : get_menu_levels(),
        'queue_display_name' : queue['Queue']['Name'],
        'hoo_display_name' : hoo['HoursOfOperation']['Name'],
        'caller_number' : dyanmodb_data['Item']['caller_number']['S'],
        'type' : dyanmodb_data['Item']['type']['S'],
        'default' : get_retry_levels()['default'],
        'timeout' : get_retry_levels()['timeout']
    }
    return test_case_data

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps(config())
    }