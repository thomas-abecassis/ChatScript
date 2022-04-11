extends Control

const PORT = 3000
const MAX_USERS = 4 #not including host

onready var chat_display = $RoomUI/ChatDisplay
onready var chat_input = $RoomUI/ChatInput

func _ready():
	get_tree().connect("connected_to_server", self, "enter_room")
	get_tree().connect("network_peer_connected", self, "user_entered")
	get_tree().connect("network_peer_disconnected", self, "user_exited")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func user_entered(id):
	chat_display.text += str(id) + " joined the room\n"

func user_exited(id):
	chat_display.text += str(id) + " left the room\n"

func host_room():
	var host = NetworkedMultiplayerENet.new()
	host.create_server(PORT, MAX_USERS)
	get_tree().set_network_peer(host)
	enter_room()
	chat_display.text = "Room Created\n"

func join_room():
	var ip = $SetUp/IpEnter.text
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, PORT)
	get_tree().set_network_peer(host)
	enter_room()

func enter_room():
	chat_display.text = "Successfully joined room\n"
	$SetUp/LeaveButton.show()
	$SetUp/JoinButton.hide()
	$SetUp/HostButton.hide()
	$SetUp/IpEnter.hide()

func leave_room():
	get_tree().set_network_peer(null)
	chat_display.text += "Left Room\n"
	$SetUp/LeaveButton.hide()
	$SetUp/JoinButton.show()
	$SetUp/HostButton.show()
	$SetUp/IpEnter.show()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			send_message()

func send_message():
	var msg = chat_input.text
	chat_input.text = ""
	var id = get_tree().get_network_unique_id()
	rpc("receive_message", id, msg)

sync func receive_message(id, msg):
	chat_display.text += str(id) + ": " + msg + "\n"

func _server_disconnected():
	chat_display.text += "Disconnected from Server\n"
	leave_room()

func _on_LeaveButton_button_up():
	leave_room()


func _on_JoinButton_button_up():
	join_room()


func _on_HostButton_button_up():
	host_room()
