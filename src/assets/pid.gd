extends Reference

class_name PID

var Kp = 1.0
var Ki = 1.0
var Kd = 1.0

var setpoint = 0.0
var PTerm = 0.0
var ITerm = 0.0
var DTerm = 0.0
var last_error = 0.0
var int_error = 0.0 # for windup guard
var windup_guard = 20.0
var output = 0.0

func absorb_parameters(params: Vector3):
	Kp = params[0]
	Ki = params[1]
	Kd = params[2]

func clear():
	setpoint = 0.0
	PTerm = 0.0
	ITerm = 0.0
	DTerm = 0.0
	last_error = 0.0
	int_error = 0.0 # for windup guard
	windup_guard = 20.0
	output = 0.0

func update(error: float, delta_time: float):
	var delta_error = error - last_error
	PTerm = Kp * error
	ITerm += error * delta_time
	if ITerm < -windup_guard:
		ITerm = -windup_guard
	elif ITerm > windup_guard:
		ITerm = windup_guard
	DTerm = 0.0
	if delta_time > 0:
		DTerm = delta_error / delta_time
	
	last_error = error
	
	output = PTerm + (Ki * ITerm) + (Kd * DTerm)