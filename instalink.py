#!/usr/bin/env python3

from flask import Flask, request, Response
from flask import send_from_directory 
import sys
import os 
import cameractrls
import re

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
  "zoom_option": "zoom_absolute",
  "zoom_min": 100,
  "zoom_max": 400,
  "zoom_default": 100
}


app = Flask(__name__)

@app.route("/")
def index():
    return send_from_directory()
    return render_template("/", 'android-app/camera_control/build/web/')

@app.route("/props")
def print_properties():
    result = cameractrls.main(device=properties["device"], controls='', list_controls = True)
    properties['current_zoom'] = re.search(r"zoom_absolute = (\d+)", result).group(1)
    properties['current_tilt'] = re.search(r"tilt_absolute = (-{0,1}\d+)", result).group(1)
    properties['current_pan'] = re.search(r"pan_absolute = (-{0,1}\d+)", result).group(1)
    return properties


@app.route("/pan",methods=['GET'])
def pan():
    args = request.args
    value = args.get('value')
    pan_option = properties['pan_option']
    try:
        cameractrls.main(device=properties["device"], controls=f'{pan_option}={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'


@app.route("/tilt",methods=['GET'])
def tilt():
    args = request.args
    value = args.get('value')
    tilt_option = properties['tilt_option']
    try:
        cameractrls.main(device=properties["device"], controls=f'{tilt_option}={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'

@app.route("/zoom",methods=['GET'])
def zoom():
    args = request.args
    value = args.get('value')
    zoom_option = properties['zoom_option']
    try:
        cameractrls.main(device=properties["device"], controls=f'{zoom_option}={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'

