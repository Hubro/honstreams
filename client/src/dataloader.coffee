
config = require 'config'

self = module.exports

# Fetch the live streams
self.fetchLiveStreams = (callback)->
    url = config.stream_data_url

    $.ajax
        url: url
        type: 'GET'
        datatype: 'json'
        complete: (e)->
            # Check if the streams were loaded successfully
            if e.status == 200
                try
                    callback JSON.parse e.responseText
                catch error
                    console.error 'Stream data could not be parsed. Error: ' +
                                  String(error)
                    callback false
            else
                console.error 'Stream data could not be loaded. Status: ' + 
                              e.status
                callback false

##
## Functions for memories
## cookie based settings specific for each visitor
##

# Get the memory from cookie. fallback overrides undefined
self.getMemory = (name, fallback)->
    console.log "Getting memory: #{name}, #{value}"
    memory = self.getMemories()

    if memory
        if typeof memory[name] != 'undefined'
            value = memory[name]
        else if typeof fallback != 'undefined'
            value = fallback
        else
            value = null

        return value
    else return fallback

# Save a memory in a cookie
self.putMemory = (name, value)->
    console.log "Putting memory: #{name}, #{value}"
    # Fetch or create the memory
    memory = self.getMemories()
    if !memory then memory = {}

    memory[name] = value

    self.putMemories memory

# Get the entire memory cookie
self.getMemories = ->
    memory = $.cookie 'honsapp-memory'

    if memory
        memory = JSON.parse memory

        return memory
    else return null

# Set the entire memory cookie
self.putMemories = (memory)->
    $.cookie 'honsapp-memory', JSON.stringify(memory), 365
