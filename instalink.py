#!/usr/bin/env python3

from flask import Flask, request
import cameractrls

# Insta360 Link Options
properties = {
  "device": "/dev/video2",
  "pan_option": "pan_absolute",
  "pan_default": 0,
  "pan_max": 522000,
  "pan_min": -522000,
  "tilt_option": "tilt_absolute",
  "tilt_default": 0,
  "tilt_max": 360000,
  "tilt_min": -324000,
  "step": 3600,
  "levels" : 20
}


app = Flask(__name__)

@app.route("/props")
def print_properties():
    return properties

@app.route("/pan",methods=['GET'])
def pan():
    args = request.args
    value = args.get('value')
    pan_max = properties["pan_max"]
    pan_min = properties["pan_min"]
    pan_option = properties['pan_option']
    pan_default = properties["pan_default"]
    levels = properties["levels"]
    set_value = int((pan_max / levels) * float(value))
    print(f'set value: {set_value}')
    cameractrls.main(device=properties["device"], controls=f'{pan_option}={set_value}')
    return f'set value of {set_value}'
    return args

@app.route("/tilt",methods=['GET'])
def tilt():
    args = request.args
    value = args.get('value')
    tilt_max = properties["tilt_max"]
    tilt_min = properties["tilt_min"]
    tilt_option = properties['tilt_option']
    tilt_default = properties["tilt_default"]
    levels = properties["levels"]
    set_value = int((tilt_max / levels) * float(value))
    print(f'set value: {set_value}')
    cameractrls.main(device=properties["device"], controls=f'{tilt_option}={set_value}')
    return f'set value of {set_value}'
    return args



