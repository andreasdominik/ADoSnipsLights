
# language settings:
# 1) set LANG to "en", "de", "fr", etc.
# 2) link the Dict with messages to the version with
#    desired language as defined in languages.jl:
#

lang = Snips.getConfig(:language)
const LANG = (lang != nothing) ? lang : "de"

# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = true
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)


# Bash-script to control shellybulb:
#
const SHELLYBULB_SCRIPT = "controlShellyBulb.sh"

# the list of lights as defined in the intent.
# all other devices are ignored:
#
const LIGHTS = ["wall_light", "main_light", "floor_light", "TV_light",
                "light"]


# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_ROOM = "room"
const SLOT_DEVICE = "device"
const SLOT_ON_OFF = "on_or_off"
const SLOT_LIGHT_SETTINGS ="light_settings"

# Device names in intent:
#
const INTENT_LIGHT = "light"
const INTENT_WALL_LIGHT = "wall_light"
const INTENT_MAIN_LIGHT = "main_light"
const INTENT_FLOOR_LIGHT = "floor_light"
const INTENT_TV_LIGHT = "TV_light"

# map settings and commands from intent to
# api commands:
#
const COMMANDS = Dict("ON" => "ON",
                "OFF" => "OFF",
                "colour" => "COLOUR",
                "white" => "WHITE",
                "warm" => "WARM",
                "cold" => "COLD",
                "red" => "RED",
                "orange" => "ORANGE",
                "green" => "GREEN",
                "blue" => "BLUE",
                "pink" => "PINK",
                "dark" => "DARK",
                "bright" => "BRIGHT",
                "dark" => "DARK",
                "medium_bright" => "MEDIUM"
               )

# Stepsizes for settings:
#
const TEMP_STEP = 900
const BRIGHTNESS_STEP = 25
const COLOURS_STEP = [(255,0,0),
                (255,153,0),
                (204,255,0),
                (51,255,0),
                (0,255,102),
                (0,255,255),
                (0,102,255),
                (51,0,255),
                (204,0,255),
                (255,0,153)]

# Language-dependent settings:
#
if LANG == "de"
    Snips.registerIntentAction("ADoSnipsOnOffDE", switchLight)
    Snips.registerIntentAction("SetLightsSettings", setLightSettings)
elseif LANG == "en"
    Snips.printLog("Language en is not yet supported!")
    # Snips.registerIntentAction("ADoSnipsOnOffDE", switchLight)
    # Snips.registerIntentAction("SetLightsSettings", setLightSettings)
else
    Snips.printLog("Language $LANG is not yet supported!")
end

# add system triggers:
#
Snips.registerTriggerAction("ADoSnipsLights", triggerLight)
