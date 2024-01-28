extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_client = true
var is_server = true
onready var addressBox = $Panel/VBoxContainer/HBoxContainer/Address
onready var inputBox = $Panel/VBoxContainer/InputBar

enum {NO_CONNECTION, CONNECTED}

var currentstate = NO_CONNECTION
var serverIp = "127.0.0.1"
var peer = NetworkedMultiplayerENet.new()
var players = []

var arguments = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	#Get command-line args
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	print(arguments)
	
	#connect server/client
	if(arguments["mode"] == "server"):
		peer.create_server(9999)
		msg("Server")
	else:
		peer.create_client(serverIp, 9999)
		msg("client")
	get_tree().network_peer = peer
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _player_connected(id):
	#Called on server when client joins
	msg("Player with ID " + str(id) + " has joined")
	

func _player_disconnected(id):
	#Called on server when client leaves
	msg("Player with ID " + str(id) + " has left")

func _connected_ok():
	msg("The Server connected successfully!")

func _connected_fail():
	msg("Could not connect to server.")

func _server_disconnected():
	msg("Server disconnected")

master func _player_command(command):
	if get_tree().is_network_server():
		command = str(get_tree().get_rpc_sender_id()) + ": " + command
	else:
		$Panel/VBoxContainer/InputBar.clear()
		rpc_id(1, "_player_command", command)
	msg(command)

func msg(s):
	#function sends string to output on screen
	$Panel/VBoxContainer/RichTextLabel.text += s + "\n"
