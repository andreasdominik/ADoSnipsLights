#
# API function goes here, to be called by the
# skill-actions:
#

function doSwitch(deviceId, command)

    deviceParams = Snips.getConfig(deviceId)
    driver = deviceParams[3]

    # map intent-command to api-command:
    #
    if haskey(COMMANDS, command)

        apiCommand = COMMANDS[command]

        if driver == "shellybulb"
            ip = deviceParams[4]
            switchShellybulb(ip, apiCommand)

        elseif driver == "GPIO"
            gpio = deviceParams[4]
            switchGPIO(gpio, apiCommand)
        end
         # ... relative commands goes here:
    elseif command in ["colder", "warmer", "brighter", "darker", "next_colour"]

        if driver == "shellybulb"
            ip = deviceParams[4]
            changeShellybulbValues(ip, command)
        end
    else
        Snips.publishSay(TEXTS[:what_to_do], lang = LANG)
    end
end


"""
commands: "colder", "warmer", temp = 3000-6500K, 5 Steps 900
"brighter", "darker", gain/brightness = 0-100, steps 25
"next_colour", 10 rainbow colours
rainbow(10) "#FF0000FF" "#FF9900FF" "#CCFF00FF" "#33FF00FF"
"#00FF66FF" "#00FFFFFF" "#0066FFFF"
"#3300FFFF" "#CC00FFFF" "#FF0099FF"
"""
function changeShellybulbValues(ip, command)

    status = getShellyStatus(ip)
    if command == "colder"
        newTemp = status[:temp] - TEMP_STEP
        if newTemp < 3000
            newTemp = 3000
        end
        status[:temp] = newTemp

    elseif command == "warmer"
        newTemp = status[:temp] + TEMP_STEP
        if newTemp < 6500
            newTemp = 6500
        end
        status[:temp] = newTemp

    elseif command == "brighter"
        bright = status[:mode] == "white" ? status[:brightness] : status[:gain]
        newBright = bright + BRIGHTNESS_STEP
        if newBright > 100
            newBright = 100
        end
        status[:brightness] = newBright
        status[:gain] = newBright

    elseif command == "darker"
        bright = status[:mode] == "white" ? status[:brightness] : status[:gain]
        newBright = bright - BRIGHTNESS_STEP
        if newBright < 0
            newBright = 0
        end
        status[:brightness] = newBright
        status[:gain] = newBright

    elseif command == "next_colour"
        colour = getSimilarRainbow((status[:red], status[:green], status[:blue]))
        newColour = colour + 1
        if newColour > 10
            newColour = 1
        end
        (status[:red], status[:green], status[:blue]) = COLOURS_STEP[newColour]
    end

    params = "$(status[:red]) $(status[:green]) $(status[:blue]) " *
    "$(status[:white]) " *
    "$(status[:gain]) $(status[:temp]) $(status[:brightness])"

    switchShellybulb(ip, "RGB", params)
end



"""
Return the index of the most similar color in list.
"""
function getSimilarRainbow((r,g,b))

    return argmin([sum(abs2, ((r-ir),(g-ig),(b-ib))) for (ir,ig,ib) in COLOURS_STEP])
end

#
#
# Low-level APIs:
#
#

function switchShellybulb(ip, apiCommand, params = nothing)

    if params == nothing
        shellcmd = `$MODULE_DIR/$SHELLYBULB_SCRIPT $ip $apiCommand`
    else
        shellcmd = `$MODULE_DIR/$SHELLYBULB_SCRIPT $ip $apiCommand $(split(params))`
    end
    Snips.printDebug("$shellcmd")
    Snips.tryrun(shellcmd, wait = true, errorMsg = TEXTS[:script_error])
end


function getShellyStatus(ip)

    shellcmd = `$MODULE_DIR/$SHELLYBULB_SCRIPT $ip STATUS`
    Snips.tryrun(shellcmd, wait = true)
    status = Snips.tryParseJSONfile("shellybulb.json")
    if status == nothing
        status = Dict(:ison=>false, :mode=>"white",
                      :red=>255, :green=>255, :blue=>255, :white=>255,
                      :gain=>60, :temp=>4100, :brightness=>60,
                      :effect=>0
                     )
    end
    return status
end


function switchGPIO(gpio, apiCommand)

    if apiCommand == "ON"
        setGPIO(gpio, :on)
    elseif apiCommand == "OFF"
        setGPIO(gpio, :off)

        Snips.publishSay(:error_gpio_cmd, lang = LANG)
    end
end
