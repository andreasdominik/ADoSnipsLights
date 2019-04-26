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
function templateAction(topic, payload)

    Dummyaction for the template.
"""
function templateAction(topic, payload)

    # log:
    println("- ADoSnipsOnOff: action templateAction() started.")

    # get my name from config.ini:
    #
    myName = Snips.getConfig(INI_MY_NAME)
    if myName == nothing
        Snips.publishEndSession(TEXTS[:noname])
        return false
    end

    # get the word to repeat from slot:
    #
    word = Snips.extractSlotValue(payload, SLOT_WORD)
    if word == nothing
        Snips.publishEndSession(TEXTS[:dunno])
        return true
    end

    # say who you are:
    #
    Snips.publishSay(TEXTS[:bravo], lang = LANG)
    Snips.publishEndSession("$(TEXTS[:iam])")
    return true
end
