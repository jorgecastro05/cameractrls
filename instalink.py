#!/usr/bin/env python3

from flask import Flask, request
from flask import send_from_directory 
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
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
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="memory://",
)


@app.route("/")
def index():
    return send_from_directory()
    return render_template("/", 'android-app/camera_control/build/web/')

@app.route("/props")
def print_properties():
    return properties

@limiter.limit("1 per minute")
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



