justintv = require '../src/justintv'
Stream = require '../src/models/stream'

update = ->
    try
        justintv.fetchLiveStreams (streams)->
            # streams can be null
            if !streams
                console.warn "Couldn't fetch streams".yellow

            # If not, run the update
            Stream.updateAllFromRaw streams, ->
                console.log 'Waiting 60 seconds for the next update'.magenta
    catch err
        console.error ('An error occurred: ' + String(err)).red
        console.log err

update()

setInterval ->
    update()
, 60000

