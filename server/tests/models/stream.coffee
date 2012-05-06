
_ = require 'underscore'

exports.testFetchWithPersistentData = (test)->
    test.expect 2
    
    Stream = require '../../src/models/stream'

    Stream.fetchWithPersistentData (err, data)->
        test.equal err, null, "Fetch didn't return an error"
        test.ok _.isArray(data), "Returned data is an array"
        test.done()
