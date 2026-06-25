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
        Key={'flow_name-testing_option' : {'S': pk_value}}
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
        'type' : dyanmodb_data['Item']['type']['S']
    }
    return test_case_data

def generate_position(x, y):
    return {"x": x, "y": y}


def generate_check_hoo_override(hoo_arn, hoo_display_name, result="InHour"):
    """Creates the Hours of Operation mock override action."""
    action_id = str(uuid.uuid4())
    return action_id, {
        "Parameters": {
            "ActionType": "OverrideSystemBehavior",
            "Behavior": {
                "Type": "FlowAction",
                "Properties": {
                    "ActionType": "CheckHoursOfOperation",
                    "ActionParameters": {
                        "HoursOfOperationId": hoo_arn
                    },
                    "Strategy": {
                        "Type": "MockResponse",
                        "Response": {
                            "Type": "ExecutionResult",
                            "ExecutionResult": {
                                "Value": result
                            }
                        }
                    }
                }
            }
        },
        "Identifier": action_id,
        "Type": "OverrideSystemBehavior",
        "Transitions": {}
    }, hoo_display_name


def generate_user_action(user_value, type):
    """Creates a voice utterance instruction action."""
    action_id = str(uuid.uuid4())
    return action_id, {
        "Parameters": {
            "Actor": "Customer",
            "Instruction": {
                "Type": type,
                "Properties": {
                    "Value": user_value
                }
            }
        },
        "Identifier": action_id,
        "Type": "SendInstruction",
        "Transitions": {}
    }



def generate_disconnect_action():
    """Creates a disconnect instruction action."""
    action_id = str(uuid.uuid4())
    return action_id, {
        "Parameters": {
            "ActionType": "TestControl",
            "Command": {
                "Type": "EndTest"
            }
        },
        "Identifier": action_id,
        "Type": "TestControl",
        "Transitions": {}
    }


def generate_observation(identifier, event_type, actor, action_id, event_props, actions, next_observations):
    """Generic observation builder."""
    return {
        "Identifier": identifier,
        "Event": {
            "Type": event_type,
            "Actor": actor,
            "Identifier": action_id,
            "Properties": event_props
        },
        "Actions": actions,
        "Transitions": {
            "NextObservations": next_observations
        } if next_observations else {}
    }


def build_test_case(config):
    region = config["region"]
    account_id = config["account_id"]
    instance_id = config["instance_id"]

    def arn(resource_type, resource_id):
        return f"arn:aws:connect:{region}:{account_id}:instance/{instance_id}/{resource_type}/{resource_id}"

    # --- IDs ---
    init_event_id = str(uuid.uuid4())
    hoo_override_id, hoo_override_action, hoo_display = generate_check_hoo_override(
        arn("operating-hours", config["hoo_id"]),
        config["hoo_display_name"],
        config.get("hoo_result", "InHour")
    )
    welcome_event_id = str(uuid.uuid4())
    queue_event_id = str(uuid.uuid4())
    disconnect_id, disconnect_action = generate_disconnect_action()

    # --- Positions (layout) ---
    positions = {
        init_event_id: generate_position(123.2, 110.4),
        hoo_override_id: generate_position(347.2, 110.4),
        welcome_event_id: generate_position(163.2, 349.6),
        queue_event_id: generate_position(1310.4, 627.2),
        disconnect_id: generate_position(1534.4, 627.2),
    }

    # --- Build menu level observations & track IDs ---
    menu_observations = []
    menu_event_ids = []
    menu_action_metadata = {}

    x_start = 477.6
    y_start = 352.8
    x_step = 224
    y_step = 275.2

    for i, level in enumerate(config["menu_levels"]):
        event_id = str(uuid.uuid4())
        user_id, user_action = generate_user_action(level["user_action"], config["type"])

        col = i % 2
        row = i // 2
        event_pos = generate_position(x_start + col * x_step, y_start + row * y_step)
        user_pos = generate_position(x_start + col * x_step + 224, y_start + row * y_step)

        positions[event_id] = event_pos
        positions[user_id] = user_pos

        menu_event_ids.append(event_id)

        menu_action_metadata[event_id] = {"position": event_pos}
        menu_action_metadata[user_id] = {"position": user_pos}

        menu_observations.append(
            generate_observation(
                identifier=level["identifier"],
                event_type="MessageReceived",
                actor="System",
                action_id=event_id,
                event_props={
                    "MatchingCriteria": {"Type": "Similarity"},
                    "Text": level["message"]
                },
                actions=[user_action],
                next_observations=[level["next"]]
            )
        )

    # --- Final "Check queue" observation ---
    last_menu_next = config["menu_levels"][-1]["next"]
    check_queue_obs = generate_observation(
        identifier=last_menu_next,
        event_type="FlowActionStarted",
        actor="System",
        action_id=queue_event_id,
        event_props={
            "ActionType": "TransferContactToQueue",
            "ActionParameters": {
                "QueueId": arn("queue", config["queue_id"])
            }
        },
        actions=[disconnect_action],
        next_observations=None
    )

    # --- Cluster annotations ---
    cluster_ids = [str(uuid.uuid4()) for _ in range(len(config["menu_levels"]) + 3)]

    init_cluster_id = cluster_ids[0]
    welcome_cluster_id = cluster_ids[1]
    check_queue_cluster_id = cluster_ids[-1]
    menu_cluster_ids = cluster_ids[2:-1]

    annotations = [
        {
            "type": "cluster",
            "id": init_cluster_id,
            "content": "",
            "actionId": "",
            "isFolded": False,
            "position": {"x": 119, "y": 74},
            "size": {"width": 575, "height": 273},
            "clusterProfile": {
                "name": "Initialize",
                "actionIds": [init_event_id, hoo_override_id],
                "style": "grid",
                "clusterJunction": [welcome_cluster_id],
                "locked": True
            }
        },
        {
            "type": "cluster",
            "id": welcome_cluster_id,
            "content": "",
            "actionId": "",
            "isFolded": False,
            "position": {"x": 169, "y": 373},
            "size": {"width": 295, "height": 273},
            "clusterProfile": {
                "name": "Welcome",
                "actionIds": [welcome_event_id],
                "style": "grid",
                "clusterJunction": [menu_cluster_ids[0]] if menu_cluster_ids else [check_queue_cluster_id],
                "locked": True
            }
        }
    ]

    for i, level in enumerate(config["menu_levels"]):
        event_id = menu_event_ids[i]
        user_id = [
            obs["Actions"][0]["Identifier"]
            for obs in menu_observations
            if obs["Identifier"] == level["identifier"]
        ][0]

        next_cluster = menu_cluster_ids[i + 1] if i + 1 < len(menu_cluster_ids) else check_queue_cluster_id

        annotations.append({
            "type": "cluster",
            "id": menu_cluster_ids[i],
            "content": "",
            "actionId": "",
            "isFolded": False,
            "position": {"x": 562 + i * 300, "y": 377 + i * 344},
            "size": {"width": 575, "height": 273},
            "clusterProfile": {
                "name": level["identifier"],
                "actionIds": [event_id, user_id],
                "style": "grid",
                "clusterJunction": [next_cluster],
                "locked": True
            }
        })

    annotations.append({
        "type": "cluster",
        "id": check_queue_cluster_id,
        "content": "",
        "actionId": "",
        "isFolded": False,
        "position": {"x": 1603, "y": 720},
        "size": {"width": 575, "height": 273},
        "clusterProfile": {
            "name": last_menu_next,
            "actionIds": [queue_event_id, disconnect_id],
            "style": "grid",
            "clusterJunction": [],
            "locked": True
        }
    })

    # --- ActionMetadata ---
    action_metadata = {
        init_event_id: {"position": positions[init_event_id]},
        hoo_override_id: {
            "position": positions[hoo_override_id],
            "parameters": {
                "Behavior": {
                    "Properties": {
                        "ActionParameters": {
                            "HoursOfOperationId": {
                                "displayName": config["hoo_display_name"]
                            }
                        }
                    }
                }
            }
        },
        welcome_event_id: {"position": positions[welcome_event_id]},
        queue_event_id: {
            "position": positions[queue_event_id],
            "parameters": {
                "Event": {
                    "Properties": {
                        "ActionParameters": {
                            "QueueId": {
                                "displayName": config["queue_display_name"]
                            }
                        }
                    }
                }
            }
        },
        disconnect_id: {"position": positions[disconnect_id]},
        **menu_action_metadata
    }

    # --- Observations (ordered) ---
    observations = [
        generate_observation(
            identifier="Initialize",
            event_type="TestInitiated",
            actor="System",
            action_id=init_event_id,
            event_props={},
            actions=[hoo_override_action],
            next_observations=["Welcome"]
        ),
        generate_observation(
            identifier="Welcome",
            event_type="MessageReceived",
            actor="System",
            action_id=welcome_event_id,
            event_props={
                "MatchingCriteria": {"Type": "Similarity"},
                "Text": config["welcome_text"]
            },
            actions=[],
            next_observations=[config["menu_levels"][0]["identifier"]]
        ),
        *menu_observations,
        check_queue_obs
    ]

    # --- Assemble full JSON ---
    test_case = {
        "Version": "2019-10-30",
        "Metadata": {
            "entryPointPosition": {"x": 40, "y": 40},
            "ActionMetadata": action_metadata,
            "Annotations": annotations,
            "StartAction": "",
            "name": config["flow_name"],
            "description": config["description"],
            "initializationData": "{\"Attributes\":{}}",
            "entryPoint": {
                "ChatEntryPointParameters": None,
                "Type": "VOICE_CALL",
                "VoiceCallEntryPointParameters": {
                    "DestinationPhoneNumber": None,
                    "FlowId": config["flow_id"],
                    "SourcePhoneNumber": None,
                    "TranscriptionLanguageCodes": None
                }
            }
        },
        "Observations": observations
    }

    return test_case

def run():
    test_case_list = connect.list_test_cases(
        InstanceId = instance_id,
        )
    for test_case in test_case_list["TestCaseSummaryList"]:
        if test_case["Name"] == config()["flow_name"]:
            connect.delete_test_case(
                InstanceId = instance_id,
                TestCaseId = test_case["Id"]
            )


    test_case = connect.create_test_case(
        InstanceId = instance_id,
        Name = config()["flow_name"],
        Description = config()["description"],
        Content =json.dumps(build_test_case(config())),
        EntryPoint = {
        'Type': 'VOICE_CALL',
        'VoiceCallEntryPointParameters': {
            'SourcePhoneNumber': config()['caller_number'],
            'FlowId': config()["flow_id"]
        },
    },   
    )
    
    execute_test = connect.start_test_case_execution(
        InstanceId = instance_id,
        TestCaseId = test_case["TestCaseId"]
    )

    return execute_test["Status"]

def lambda_handler(event, context):
    
    # TODO implement
    
    for record in event['Records']:
        event_name = record['eventName']
        keys = record['dynamodb']['Keys']
        
        global pk_value
        partition_key = keys[key_name]

        pk_value = list(partition_key.values())[0]
        run()
    
    
    return {'statusCode': 200
    ,'body': config()}