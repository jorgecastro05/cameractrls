#!/usr/bin/env python3

from flask import Flask, request, Response
from flask import send_from_directory 
import logging
import sys
import os 
import cameractrls
import re
from flask_limiter import Limiter,util
from flask_limiter.util import get_remote_address

# Insta360 Link Options
properties = {
  "device": "/dev/v4l/by-id/usb-Insta360_Insta360_Link-video-index0",
  "pan_option": "pan_absolute",
  "pan_default": 0,
  "pan_max": 522000,
  "pan_min": -522000,
  "tilt_option": "tilt_absolute",
  "tilt_default": 0,
  "tilt_max": 360000,
  "tilt_min": -324000,
  "tilt_step": 3600,
  "pan_step": 3600,
  "zoom_step": 10,
  "image_step": 1,
  "zoom_option": "zoom_absolute",
  "zoom_min": 100,
  "zoom_max": 400,
  "zoom_default": 100,
  "brightness": 50,
  "contrast": 50,
  "saturation": 50,
  "sharpness": 50,
  "white_balance_temperature_min": 2000,
  "white_balance_temperature_max": 10000,
  "white_balance_temperature_default": 6400,
  "white_balance_temperature_step": 100,
  "white_balance_automatic": 0
}

# Constants
STEP_MULTIPLIER = 3

def limiter_error(e):
    return 'limit api reached', 208

app = Flask(__name__)
app.logger.setLevel(logging.WARN)
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["10000 per hour"],
    storage_uri="memory://"
)

app.register_error_handler(429, limiter_error)

@app.route("/")
def index():
    return send_from_directory()
    return render_template("/", 'android-app/camera_control/build/web/')

@app.route("/props")
def print_properties():
    print("loading values")
    result = cameractrls.main(device=properties["device"], controls='', list_controls = True)
    properties['current_zoom'] = re.search(r"zoom_absolute = (\d+)", result).group(1)
    properties['current_tilt'] = re.search(r"tilt_absolute = (-{0,1}\d+)", result).group(1)
    properties['current_pan'] = re.search(r"pan_absolute = (-{0,1}\d+)", result).group(1)
    properties['current_brightness'] = re.search(r"brightness = (\d+)", result).group(1)
    properties['current_contrast'] = re.search(r"contrast = (\d+)", result).group(1)
    properties['current_saturation'] = re.search(r"saturation = (\d+)", result).group(1)
    properties['current_sharpness'] = re.search(r"sharpness = (\d+)", result).group(1)
    properties['current_white_balance'] = re.search(r"white_balance_temperature = (\d+)", result).group(1)
    properties['loaded_values'] = True
    app.logger.info(properties)
    return properties

@app.route("/reset",methods=['GET'])
@limiter.limit("4 per second")
def reset():
    pan_option = properties['pan_option']
    tilt_option = properties['tilt_option']
    pan_default = properties['pan_default']
    tilt_default = properties['tilt_default']
    properties['current_pan'] = pan_default
    properties['current_tilt'] = tilt_default
    try:
        cameractrls.main(device=properties["device"], controls=f'{pan_option}={pan_default}')
        cameractrls.main(device=properties["device"], controls=f'{tilt_option}={tilt_default}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'reseting values'

@app.route("/pan",methods=['GET'])
@limiter.limit("4 per second")
def pan():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    pan_option = properties['pan_option']
    if 'loaded_values' not in properties:
        print_properties()
    if option is not None:
        if option == 'inc':
            value = int(properties['current_pan']) + (properties['pan_step'] * STEP_MULTIPLIER)
        elif option == 'dec':
            value = int(properties['current_pan']) - (properties['pan_step'] * STEP_MULTIPLIER)
        else:
            value = properties['pan_default']
    try:
        app.logger.info(f'current pan is {value}')
        if(properties['pan_min'] < value < properties['pan_max']):
            cameractrls.main(device=properties["device"], controls=f'{pan_option}={value}')
            properties['current_pan'] = value
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'


@app.route("/tilt",methods=['GET'])
@limiter.limit("4 per second")
def tilt():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    tilt_option = properties['tilt_option']
    if 'loaded_values' not in properties:
        print_properties()
    if option is not None:
        if option == 'inc':
            value = int(properties['current_tilt']) + (properties['tilt_step'] * STEP_MULTIPLIER)
        elif option == 'dec':
            value = int(properties['current_tilt']) - (properties['tilt_step'] * STEP_MULTIPLIER)
        else:
            value = properties['tilt_default']
    try:
        app.logger.info(f'current tilt is {value}')
        if(properties['tilt_min'] < value < properties['tilt_max']):
            cameractrls.main(device=properties["device"], controls=f'{tilt_option}={value}')
            properties['current_tilt'] = value
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'

@app.route("/zoom",methods=['GET'])
@limiter.limit("4 per second")
def zoom():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    zoom_option = properties['zoom_option']
    if 'loaded_values' not in properties:
        print_properties()
    if option is not None:
        if option == 'inc':
            value = int(properties['current_zoom']) + properties['zoom_step']
        elif option == 'dec':
            value = int(properties['current_zoom']) - properties['zoom_step']
        else:
            value = properties['zoom_default']
    try:
        if(properties['zoom_min'] <= value <= properties['zoom_max']):
            cameractrls.main(device=properties["device"], controls=f'{zoom_option}={value}')
            properties['current_zoom'] = value
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'

@app.route("/brightness",methods=['GET'])
@limiter.limit("4 per second")
def brightness():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    if 'loaded_values' not in properties:
        print_properties()
    if option is not None:
        if option == 'inc':
            value = int(properties['current_brightness']) + properties['image_step']
        elif option == 'dec':
            value = int(properties['current_brightness']) - properties['image_step']
        else:
            value = properties['brightness']
    properties['current_brightness'] = value
    try:
        cameractrls.main(device=properties["device"], controls=f'brightness={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'

@app.route("/contrast",methods=['GET'])
@limiter.limit("4 per second")
def contrast():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    if 'loaded_values' not in properties:
        print_properties()
    if option is not None:
        if option == 'inc':
            value = int(properties['current_contrast']) + properties['image_step']
        elif option == 'dec':
            value = int(properties['current_contrast']) - properties['image_step']
        else:
            value = properties['contrast']
    properties['current_contrast'] = value
    try:
        cameractrls.main(device=properties["device"], controls=f'contrast={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'

@app.route("/saturation",methods=['GET'])
@limiter.limit("4 per second")
def saturation():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    if 'loaded_values' not in properties:
        print_properties()
    if option is not None:
        if option == 'inc':
            value = int(properties['current_saturation']) + properties['image_step']
        elif option == 'dec':
            value = int(properties['current_saturation']) - properties['image_step']
        else:
            value = properties['saturation']
    properties['current_saturation'] = value
    try:
        cameractrls.main(device=properties["device"], controls=f'saturation={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'


@app.route("/sharpness",methods=['GET'])
@limiter.limit("4 per second")
def sharpness():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    if 'loaded_values' not in properties:
        print_properties()
    if option is not None:
        if option == 'inc':
            value = int(properties['current_sharpness']) + properties['image_step']
        elif option == 'dec':
            value = int(properties['current_sharpness']) - properties['image_step']
        else:
            value = properties['sharpness']
    properties['current_sharpness'] = value
    try:
        cameractrls.main(device=properties["device"], controls=f'sharpness={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'

@app.route("/white_balance",methods=['GET'])
@limiter.limit("4 per second")
def white_balance():
    args = request.args
    value = args.get('value')
    option = args.get('option')
    if 'loaded_values' not in properties:
        print_properties()
        cameractrls.main(device=properties["device"], controls='white_balance_automatic=0')
    if option is not None:
        if option == 'inc':
            value = int(properties['current_white_balance']) + properties['white_balance_temperature_step']
        elif option == 'dec':
            value = int(properties['current_white_balance']) - properties['white_balance_temperature_step']
        else:
            value = properties['white_balance_temperature_default']
    properties['current_white_balance'] = value
    try:
        cameractrls.main(device=properties["device"], controls=f'white_balance_temperature={value}')
    except:
        return Response(
        "error setting parameter",
        status=400,
    )
    return f'set value of {value}'