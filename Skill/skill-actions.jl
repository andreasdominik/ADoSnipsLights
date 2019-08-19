#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
    function switchLight(topic, payload)

Switch a light on or off (from unified OnOff-Intent).
"""
function switchLight(topic, payload)

    Snips.printLog("action switchLight() started.")
    # find the device and room:
    #
    slots = extractSlots(payload)
    Snips.printDebug(slots)

    # ignore intent if it is not a light!
    #
    if  slots == nothing || slots[:device] == nothing
        Snips.printLog("no device found in intent.")
        return false
    end
    if  !(slots[:device] in LIGHTS)
        Snips.printLog("device $(slots[:device]) ignored.")
        return false
    end


    if !(slots[:onOrOff] in ["ON", "OFF"])
        Snips.publishEndSession(TEXTS[:what_to_do])
        return true
    end


    # get matched devices from config.ini and find correct one:
    #
    matchedDevices = getDevicesFromConfig(slots)

    if length(matchedDevices) < 1
        Snips.publishEndSession(TEXTS[:no_matched_light])
        return true
    else
        Snips.publishEndSession(TEXTS[:ok])
        for d in matchedDevices
            doSwitch(d, slots[:onOrOff])
        end
    end
    return true  # follow up without hotword necessray
end




"""
    function setLightSettings(topic, payload)

Modifies the settings of a light (but no ON/OFF)
"""
function setLightSettings(topic, payload)

    Snips.printLog("action setLightSettings() started.")

    # find the device and room:
    #
    slots = extractSlots(payload)
    if slots[:device] == nothing
        Snips.publishEndSession(TEXTS[:which_lamp])
        return true
    end

    if slots[:settings] == nothing
        Snips.publishEndSession(TEXTS[:what_to_do])
        return true
    end


    # get matched devices from config.ini and find correct one:
    #
    matchedDevices = getDevicesFromConfig(slots)

    if length(matchedDevices) < 1
        Snips.publishEndSession(TEXTS[:no_matched_light])
        return false
    else
        Snips.publishEndSession(TEXTS[:ok])
        for d in matchedDevices
            doSwitch(d, slots[:settings])
        end
    end
    return true
end



#
# Functions to be executed from a system trigger:
#
"""
    function triggerLight(topic, payload)

Switch a light on or off (from a QnD system trigger).
The trigger must have the following JSON format:
    {
      "target" : "qnd/trigger/andreasdominik:ADoSnipsLights",
      "origin" : "ADoSnipsScheduler",
      "time" : timeString,
      "trigger" : {
        "room" : "default",
        "device" : "floor_lamp",
        "onOrOff" : "ON",
        "settings" : "undefined"
      }
    }

"""
function triggerLight(topic, payload)

    Snips.printLog("action triggerLight() started.")

    # abort if the trigger payload is not complete:
    #
    haskey( payload, :trigger) || return false
    trigger = payload[:trigger]

    haskey( trigger, :room) || return false
    haskey( trigger, :device) || return false
    haskey( trigger, :onOrOff) || return false
    haskey( trigger, :settings) || return false

    # find the device and room:
    #
    slots = trigger

    # ignore intent if it is not a light.
    # ignore intent if it is not ON or OFF:
    #
    slots[:device] in LIGHTS || return false
    slots[:onOrOff] in ["ON", "OFF"] || return false

    # get matched devices from config.ini and find correct one:
    #
    matchedDevices = getDevicesFromConfig(slots)

    if length(matchedDevices) < 1
        return false
    else
        for d in matchedDevices
            doSwitch(d, slots[:onOrOff])
        end
    end
    return false  # follow up with hotword
end



#
# API funs:
#



function extractSlots(payload)

    slots = Dict()
    slots[:room] = Snips.extractSlotValue(payload, SLOT_ROOM)
    if slots[:room] == nothing
        slots[:room] = Snips.getSiteId()
    end

    slots[:device] = Snips.extractSlotValue(payload, SLOT_DEVICE)
    slots[:onOrOff] = Snips.extractSlotValue(payload, SLOT_ON_OFF)
    slots[:settings] = Snips.extractSlotValue(payload, SLOT_LIGHT_SETTINGS)

    return slots
end




function getDevicesFromConfig(slots)

    devices = Snips.getConfig(:devices)
    if devices isa AbstractString
        devices = [devices]
    end

    Snips.printDebug(devices)
    Snips.printDebug(slots)


    # add all light in room for INTENT_LIGHT
    # or only devices with correct name:
    #
    matchedDevices = []
    if slots[:device] == INTENT_LIGHT
        for d in devices
            dParams = Snips.getConfig(d)
            if  dParams[1] == slots[:room]
                push!(matchedDevices, d)
            end
        end
    else
        for d in devices
            dParams = Snips.getConfig(d)
            Snips.printDebug(dParams)
            if  dParams[1] == slots[:room] && dParams[2] == slots[:device]
                push!(matchedDevices, d)
            end
        end
    end
    Snips.printDebug(matchedDevices)

    return matchedDevices
end
