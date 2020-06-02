extends Spatial

onready var animPlay = $AnimationPlayer
onready var lane1 = [$Panel/Ready1Lane1, $Panel/Ready2Lane1, $Panel/Ready3Lane1, $Panel/GoLane1]
onready var lane2 = [$Panel/Ready1Lane2, $Panel/Ready2Lane2, $Panel/Ready3Lane2, $Panel/GoLane2]
onready var car = $Car
onready var car2 = $Car2
onready var carOrigin = car.transform
onready var car2Origin = car2.transform
onready var smoke1 = $Car/Smoke
onready var smoke2 = $Car2/Smoke

export var time_scale = 1.0 setget set_timescale

var racetime = 0.00
var stage = -1
var started = false
var lane1pressed = false
var lane2pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	
func reset():
	$Timer.stop()
	racetime = 0.00
	stage = -1
	started = false
	lane1pressed = false
	lane2pressed = false
	for x in lane1:
		x.visible = false
	for x in lane2:
		x.visible = false
	$Panel/FalseStartLane1.visible = false
	$Panel/FalseStartLane2.visible = false
	$Panel/ReactionTime1.text = "%1.3f" % racetime
	$Panel/ReactionTime2.text = "%1.3f" % racetime
	$Panel/RaceTime1.text = "0.000"
	$Panel/RaceTime2.text = "0.000"
	reset_cars()
	$CameraAnimation.play_backwards("Camera")
	smoke1.emitting = false
	smoke2.emitting = false
	
func reset_cars():
	car.transform = carOrigin
	car2.transform = car2Origin
	print("car")
	print(car.transform)
	print(car.translation)
	car.linear_velocity = Vector3()
	car2.linear_velocity = Vector3()
	car.angular_velocity = Vector3()
	car2.angular_velocity = Vector3()

func _physics_process(delta):
	if stage == 3:
		racetime = racetime + delta

func set_timescale(x):
	Engine.time_scale = x
	time_scale = x

func _input(event):
	if event is InputEventKey and event.pressed:
		if started == false:
			return
		if event.scancode == KEY_R:
			reset()
			animPlay.play_backwards()
			return
		if event.scancode == KEY_ENTER:
			if stage < 3:
				$Panel/FalseStartLane2.visible = true
				$Timer.stop()
				smoke2.emitting = true
			else:
				if lane2pressed == true:
					return
				car2.apply_central_impulse(Vector3(-10,0,0))
				$Panel/ReactionTime2.text = "%1.3f" % racetime
				lane2pressed = true
				if not lane1pressed:
					$CameraAnimation.play("Camera")
		if event.scancode == KEY_SPACE:
			if stage < 3:
				$Panel/FalseStartLane1.visible = true
				$Timer.stop()
				smoke1.emitting = true
			else:
				if lane1pressed == true:
					return
				car.apply_central_impulse(Vector3(-10,0,0))
				$Panel/ReactionTime1.text = "%1.3f" % racetime
				lane1pressed = true
				if not lane2pressed:
					$CameraAnimation.play("Camera")
			



func _on_BeginButton_pressed():
	reset_cars()
	started = true
	animPlay.current_animation = "BeginAnim"
	animPlay.play()
	$Timer.start()



func _on_AnimationPlayer_animation_finished(anim_name):
	pass # Replace with function body.


func _on_Timer_timeout():
	if stage < 3:
		stage = stage + 1
		lane1[stage].visible = true
		lane2[stage].visible = true


func _on_FinishingLine_body_entered(body):
	if body == car:
		$Panel/RaceTime1.text = "%1.3f" % racetime
	if body == car2:
		$Panel/RaceTime2.text = "%1.3f" % racetime



func _on_CameraAnimation_animation_finished(anim_name):
	pass # Replace with function body.
