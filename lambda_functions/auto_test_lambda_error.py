import json
import boto3
import uuid

instance_id = '6e669f6f-3783-4c0e-ac76-4f531575015d'
connect = boto3.client('connect')
table_name = 'bs-automated-testing-iac'
key_name = 'flow_name-testing_option'
pk_value = ''
region = 'af-south-1'
account_id = '687244881512'

dynamodb = boto3.client('dynamodb')



def config():
    
    dyanmodb_data = dynamodb.get_item(
    TableName = table_name,
    Key={key_name : {'S': pk_value}}
    )
    queue = connect.describe_queue(
        InstanceId = instance_id,
        QueueId = dyanmodb_data["Item"]['queue_id']['S']
    )
    hoo = connect.describe_hours_of_operation(
        InstanceId = instance_id,
        HoursOfOperationId = dyanmodb_data['Item']['hoo_id']['S']
    )


    def get_menu_levels():
        menu_levels_data = dyanmodb_data['Item']['menu_levels']['M']
        menu_levels = [{"default":{}}, {"timeout":{}}]

        retry_levels_data = dyanmodb_data['Item']['retry_settings']['M']

        for menu_level in menu_levels_data:
            menu_levels.append({
            'identifier' : menu_levels_data[menu_level]['M']['identifier']['S'],
            'message' : menu_levels_data[menu_level]['M']['message']['S'],
            'user_action' : menu_levels_data[menu_level]['M']['user_action']['S'],
            'next' : menu_levels_data[menu_level]['M']['next']['S']
            })

            if menu_levels_data[menu_level]['M']['user_action']['S'] == "default":
                menu_levels[0] = {
                    "default" : {
                        "attempts" : int(retry_levels_data['default']['M']['attempts']['N']),
                        "wrong_action" : retry_levels_data['default']['M']['wrong_action']['S'],
                        "retry_message" : retry_levels_data['default']['M']['retry_message']['S'],
                        "transfer_message" : retry_levels_data['default']['M']['transfer_message']['S'],
            }}
            elif menu_levels_data[menu_level]['M']['user_action']['S'] == "timeout":
                menu_levels[1] = {
                    "timeout" : {
                        "attempts" : int(retry_levels_data['timeout']['M']['attempts']['N']),
                        "retry_message" : retry_levels_data['timeout']['M']['retry_message']['S'],
                        "transfer_message" : retry_levels_data['timeout']['M']['transfer_message']['S'],
            }
            }


        return menu_levels
    

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
        'menu_levels' : get_menu_levels()[2],
        'queue_display_name' : queue['Queue']['Name'],
        'hoo_display_name' : hoo['HoursOfOperation']['Name'],
        'caller_number' : dyanmodb_data['Item']['caller_number']['S'],
        'type' : dyanmodb_data['Item']['type']['S'],
        'retry_settings' : {
            'default' : get_menu_levels()[0]['default'],
            'timeout' : get_menu_levels()[1]['timeout']
        }
    }

    return test_case_data


def generate_position(x, y):
    return {"x": x, "y": y}


def generate_check_hoo_override(hoo_arn, hoo_display_name, result="InHour"):
    action_id = str(uuid.uuid4())
    return action_id, {
        "Parameters": {
            "ActionType": "OverrideSystemBehavior",
            "Behavior": {
                "Type": "FlowAction",
                "Properties": {
                    "ActionType": "CheckHoursOfOperation",
                    "ActionParameters": {"HoursOfOperationId": hoo_arn},
                    "Strategy": {
                        "Type": "MockResponse",
                        "Response": {
                            "Type": "ExecutionResult",
                            "ExecutionResult": {"Value": result}
                        }
                    }
                }
            }
        },
        "Identifier": action_id,
        "Type": "OverrideSystemBehavior",
        "Transitions": {}
    }, hoo_display_name


def generate_user_action(user_value, type_):
    action_id = str(uuid.uuid4())
    return action_id, {
        "Parameters": {
            "Actor": "Customer",
            "Instruction": {
                "Type": type_,
                "Properties": {"Value": user_value}
            }
        },
        "Identifier": action_id,
        "Type": "SendInstruction",
        "Transitions": {}
    }


def generate_disconnect_action():
    action_id = str(uuid.uuid4())
    return action_id, {
        "Parameters": {
            "ActionType": "TestControl",
            "Command": {"Type": "EndTest"}
        },
        "Identifier": action_id,
        "Type": "TestControl",
        "Transitions": {}
    }


def generate_observation(identifier, event_type, actor, action_id, event_props, actions, next_observations):
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


def generate_cluster(name, action_ids, position, junction, size=None):
    return {
        "type": "cluster",
        "id": str(uuid.uuid4()),
        "content": "",
        "actionId": "",
        "isFolded": False,
        "position": position,
        "size": size or {"width": 575, "height": 273},
        "clusterProfile": {
            "name": name,
            "actionIds": action_ids,
            "style": "grid",
            "clusterJunction": junction,
            "locked": True
        }
    }


def build_retry_block(level, config, positions, action_metadata, x, y, next_target):
    """
    Builds the repeated "wrong input" / "timeout" loop for one menu level.

    Every attempt is two observations, chained sequentially:
        "Menu options {i+1}"                              (the prompt)
        "Default {i+1}" / "Timeout {i+1}" [+ " - Transfer"] (the reaction)

    Each observation's Identifier is IDENTICAL to its cluster's name —
    this is required for the file to import correctly.

    Returns (observations, cluster_annotations, entry_identifier) where
    entry_identifier is "Menu options 1" — what an earlier observation's
    NextObservations should point to.
    """
    kind = level["user_action"]  # "default" or "timeout"
    settings = config.get("retry_settings", {}).get(kind, {})
    attempts = settings.get("attempts", 3)
    retry_message = settings["retry_message"]
    transfer_message = settings.get("transfer_message", retry_message)
    wrong_action = settings.get("wrong_action", "0")
    type_ = config.get("type", "DtmfInput")
    kind_label = "Default" if kind == "default" else "Timeout"

    observations = []
    clusters = []
    x_step = 300

    prompt_names = [f"Menu options {i + 1}" for i in range(attempts)]
    reaction_names = [
        f"{kind_label} {i + 1}" + (" - Transfer" if i == attempts - 1 else "")
        for i in range(attempts)
    ]

    for i in range(attempts):
        is_last = (i == attempts - 1)
        cx = x + i * x_step

        prompt_event_id = str(uuid.uuid4())
        prompt_cluster_action_ids = [prompt_event_id]
        actions_for_prompt = []

        if kind == "default":
            user_id, user_action = generate_user_action(wrong_action, type_)
            actions_for_prompt = [user_action]
            prompt_cluster_action_ids.append(user_id)
            positions[user_id] = generate_position(cx + 224, y)
            action_metadata[user_id] = {"position": positions[user_id]}
        # "timeout" -> no customer action block at all

        positions[prompt_event_id] = generate_position(cx, y)
        action_metadata[prompt_event_id] = {"position": positions[prompt_event_id]}

        observations.append(
            generate_observation(
                identifier=prompt_names[i],
                event_type="MessageReceived",
                actor="System",
                action_id=prompt_event_id,
                event_props={
                    "MatchingCriteria": {"Type": "Similarity"},
                    "Text": level["message"]
                },
                actions=actions_for_prompt,
                next_observations=[reaction_names[i]]
            )
        )

        clusters.append(generate_cluster(
            prompt_names[i], prompt_cluster_action_ids,
            {"x": cx, "y": y}, [None]  # junction id patched below
        ))

        reaction_event_id = str(uuid.uuid4())
        positions[reaction_event_id] = generate_position(cx, y + 344)
        action_metadata[reaction_event_id] = {"position": positions[reaction_event_id]}

        next_id = prompt_names[i + 1] if not is_last else next_target

        observations.append(
            generate_observation(
                identifier=reaction_names[i],
                event_type="MessageReceived",
                actor="System",
                action_id=reaction_event_id,
                event_props={
                    "MatchingCriteria": {"Type": "Similarity"},
                    "Text": transfer_message if is_last else retry_message
                },
                actions=[],
                next_observations=[next_id]
            )
        )

        clusters.append(generate_cluster(
            reaction_names[i], [reaction_event_id],
            {"x": cx, "y": y + 344}, [None]  # junction id patched below
        ))

    # Wire clusterJunction (visual-only) to point at the NEXT cluster in
    # this block; the very last cluster's junction is left empty here and
    # patched by the caller once it knows the following block's cluster id.
    for i in range(len(clusters) - 1):
        clusters[i]["clusterProfile"]["clusterJunction"] = [clusters[i + 1]["id"]]
    clusters[-1]["clusterProfile"]["clusterJunction"] = []

    return observations, clusters, prompt_names[0]


def build_test_case(config):
    region = config["region"]
    account_id = config["account_id"]
    instance_id = config["instance_id"]

    def arn(resource_type, resource_id):
        return f"arn:aws:connect:{region}:{account_id}:instance/{instance_id}/{resource_type}/{resource_id}"

    init_event_id = str(uuid.uuid4())
    hoo_override_id, hoo_override_action, hoo_display = generate_check_hoo_override(
        arn("operating-hours", config["hoo_id"]),
        config["hoo_display_name"],
        config.get("hoo_result", "InHour")
    )
    welcome_event_id = str(uuid.uuid4())
    queue_event_id = str(uuid.uuid4())
    disconnect_id, disconnect_action = generate_disconnect_action()

    positions = {
        init_event_id: generate_position(91.2, 79.2),
        hoo_override_id: generate_position(315.2, 79.2),
        welcome_event_id: generate_position(618.4, 82.4),
    }
    action_metadata = {
        init_event_id: {"position": positions[init_event_id]},
        hoo_override_id: {
            "position": positions[hoo_override_id],
            "parameters": {"Behavior": {"Properties": {"ActionParameters": {
                "HoursOfOperationId": {"displayName": config["hoo_display_name"]}
            }}}}
        },
        welcome_event_id: {"position": positions[welcome_event_id]},
    }

    welcome_cluster = generate_cluster(
        "Welcome message", [welcome_event_id], {"x": 738, "y": 39}, [None]
    )

    annotations = [
        generate_cluster(
            "Interaction 1", [init_event_id, hoo_override_id],
            {"x": 79, "y": 35}, [welcome_cluster["id"]]  # junction to the next cluster
        ),
    ]
    
    annotations.append(welcome_cluster)

    menu_observations = []
    x_start, y_start = 942.4, 76
    x_step, y_step = 300, 400

    # Precompute the real entry point for every level BEFORE generating any
    # observations, since a normal level's "next" may point at a level that
    # turns out to be "default"/"timeout" (which enters at "Menu options 1",
    # not at its own identifier).
    entry_id_for = {}
    for level in config["menu_levels"]:
        if level["user_action"] in ("default", "timeout"):
            entry_id_for[level["identifier"]] = "Menu options 1"
        else:
            entry_id_for[level["identifier"]] = level["identifier"]

    def resolve_next(target):
        return entry_id_for.get(target, target)

    first_menu_identifier = None
    last_cluster = annotations[-1]  # will be re-pointed once we know the next block's first cluster

    for i, level in enumerate(config["menu_levels"]):
        block_x = x_start + i * 100
        block_y = y_start + i * y_step

        if level["user_action"] in ("default", "timeout"):
            obs, clusters, entry_id = build_retry_block(
                level, config, positions, action_metadata, block_x, block_y,
                resolve_next(level["next"])
            )
            menu_observations.extend(obs)
            last_cluster["clusterProfile"]["clusterJunction"] = [clusters[0]["id"]]
            annotations.extend(clusters)
            last_cluster = clusters[-1]
            level["_entry_identifier"] = entry_id
        else:
            event_id = str(uuid.uuid4())
            user_id, user_action = generate_user_action(level["user_action"], config["type"])
            event_pos = generate_position(block_x, block_y)
            positions[event_id] = event_pos
            positions[user_id] = generate_position(block_x + 224, block_y)
            action_metadata[event_id] = {"position": event_pos}
            action_metadata[user_id] = {"position": positions[user_id]}

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
                    next_observations=[resolve_next(level["next"])]
                )
            )
            level_cluster = generate_cluster(
                level["identifier"], [event_id, user_id], {"x": block_x, "y": block_y}, []
            )
            last_cluster["clusterProfile"]["clusterJunction"] = [level_cluster["id"]]
            annotations.append(level_cluster)
            last_cluster = level_cluster
            level["_entry_identifier"] = level["identifier"]

        if first_menu_identifier is None:
            first_menu_identifier = level["_entry_identifier"]

    last_menu_next = resolve_next(config["menu_levels"][-1]["next"])
    check_queue_pos = generate_position(x_start + len(config["menu_levels"]) * 400, y_start)
    positions[queue_event_id] = check_queue_pos
    positions[disconnect_id] = generate_position(check_queue_pos["x"] + 224, check_queue_pos["y"])
    action_metadata[queue_event_id] = {
        "position": positions[queue_event_id],
        "parameters": {"Event": {"Properties": {"ActionParameters": {
            "QueueId": {"displayName": config["queue_display_name"]}
        }}}}
    }
    action_metadata[disconnect_id] = {"position": positions[disconnect_id]}

    check_queue_obs = generate_observation(
        identifier=last_menu_next,
        event_type="FlowActionStarted",
        actor="System",
        action_id=queue_event_id,
        event_props={
            "ActionType": "TransferContactToQueue",
            "ActionParameters": {"QueueId": arn("queue", config["queue_id"])}
        },
        actions=[disconnect_action],
        next_observations=None
    )
    check_queue_cluster = generate_cluster(
        last_menu_next, [queue_event_id, disconnect_id], check_queue_pos, []
    )
    last_cluster["clusterProfile"]["clusterJunction"] = [check_queue_cluster["id"]]
    annotations.append(check_queue_cluster)

    welcome_cluster_target = None
    observations = [
        generate_observation(
            identifier="Interaction 1",
            event_type="TestInitiated",
            actor="System",
            action_id=init_event_id,
            event_props={},
            actions=[hoo_override_action],
            next_observations=["Welcome message"]
        ),
        generate_observation(
            identifier="Welcome message",
            event_type="MessageReceived",
            actor="System",
            action_id=welcome_event_id,
            event_props={
                "MatchingCriteria": {"Type": "Similarity"},
                "Text": config["welcome_text"]
            },
            actions=[],
            next_observations=[first_menu_identifier]
        ),
        *menu_observations,
        check_queue_obs
    ]

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
        Tags={
        'Name': config()["flow_name"],
        'Description': config()["description"],
        'Environment': 'Develpment'
    }  
    )
    
    execute_test = connect.start_test_case_execution(
        InstanceId = instance_id,
        TestCaseId = test_case["TestCaseId"]
    )

    return execute_test["Status"]


def lambda_handler(event, context):
    for record in event['Records']:
        keys = record['dynamodb']['Keys']
        
        global pk_value
        partition_key = keys[key_name]

        pk_value = list(partition_key.values())[0]
    run()
    
    return {
        'statusCode': 200,
        'body': config()
    }