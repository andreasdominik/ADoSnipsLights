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

    println("- ADoSnipsLights: action switchLight() started.")
    # find the device and room:
    #
    slots = extractSlots(payload)

    # ignore intent if it is not a light!
    #
    if  !(slots[:device] in LIGHTS)
        println("- ADoSnipsLights: device $(slots[:device]) ignored.")
        return false
    end

    if slots[:device] == nothing
        Snips.publishEndSession(TEXTS[:which_lamp])
        return true
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

    println("- ADoSnipsLights: action setLightSettings() started.")

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

    println(devices)
    println(slots)


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
            println(dParams)
            if  dParams[1] == slots[:room] && dParams[2] == slots[:device]
                push!(matchedDevices, d)
            end
        end
    end
    println(matchedDevices)

    return matchedDevices
end
