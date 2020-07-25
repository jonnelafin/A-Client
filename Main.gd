extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var f = 0
var host = "http://0.0.0.0:5000" #"https://aplusminus.herokuapp.com"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if f%400 == 0:
		print("Refreshing messages...")
		$Users.request(host + "/list")
		$Me.request(host + "/get_my_ip")
		$Chat.request(host + "/history")
	f = f + 1


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	#JSON.parse(body.get_string_from_utf8())
	var json = parse_json(body.get_string_from_utf8())
	var clients = json.get("clients")
	print(clients)



func _on_Me_request_completed(result, response_code, headers, body):
	var json = parse_json(body.get_string_from_utf8())
	var UID = json.get("UID")
	var Ip = json.get("ip")
	print("Signed in as:  " + str(UID))
	$Label/ID.text = "Signed in as <" + UID + ">"


func _on_Chat_request_completed(result, response_code, headers, body):
	var json = parse_json(body.get_string_from_utf8())
	var history = json.get("chat-history")
	print("Chat:  " + str(history))
	var msgP = preload("res://Prefabs/Msg.tscn")
	for x in $Label/Container.get_children():
		$Label/Container.remove_child(x)
	var all = ""
	for i in history:
		all = all + i + "\n"
	var msgc = msgP.instance()
	msgc.text = all
	$Label/Container.add_child(msgc)
#	$Label/ID.text = "Signed in as <" + UID + ">"


func _on_Button_pressed():
	var data = {}
	var text = "" + $LineEdit.text + ""
	data["msg"] = text
	print("Making send request: " + str(data))
	_make_post_request(host + "/post", text, false)
func _make_post_request(url, data_to_send, use_ssl):
	# Convert data to json string:
	var query = data_to_send#JSON.print(data_to_send)
	#query = ""
#	print(HTTPClient.new().query_string_from_dict(data_to_send))
#	query = HTTPClient.new().query_string_from_dict(data_to_send)
#	for i in data_to_send.keys():
#		query = query + i + "=" + data_to_send[i]
	print(query)
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
#	$LineEdit/Send.request(url, headers, use_ssl, HTTPClient.METHOD_POST, query)
	$LineEdit/Send.request(url, headers, false, HTTPClient.METHOD_POST, query)


func _on_Send_request_completed(result, response_code, headers, body):
	print("Send request completed.")
	print("Result: " + str(result))
	print("Response: " + str(response_code))
	print("Headers: " + str(headers))
	print("Body: " + str(body.get_string_from_utf8()))
