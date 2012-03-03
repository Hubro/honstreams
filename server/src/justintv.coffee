
# Dependencies
config = require './config'
oauth = require 'oauth'
util = require 'util'

# Create an OAuth handle for the justin.tv API
jtvhandle = new oauth.OAuth config.jtv_req_token_url, config.jtv_acc_token_url, 
                            config.jtv_key, config.jtv_secret, '1.0', null,
                            'HMAC-SHA1'

# Performs a request to the API and passes the resulting data object to the
# callback
apiRequest = (path, callback)->
    # Ensure path starts with /
    path = if path.indexOf('/') == 0 then path else path = '/' + path
    
    # Attempt to run a request to the API
    jtvhandle.get config.jtv_api_root + path, config.jtv_key, \
                  config.jtv_secret, (error, result)->
        
        # Throw potential errors
        if error then throw error

        # Try to parse the result and pass it to the callback
        try
            info_object = JSON.parse result
            callback info_object
        # If the parsing fails, log the error and pass null to the callback
        catch err
            console.error String(err)
            callback null

# Checks if the input stream name is live. Passes true of false to the callback,
# representing online or offline respectively. Can throw exceptions.
fetchStreamStatus = exports.fetchStreamStatus = (channel, callback)->
    request = "/channel/show/#{channel}.json"

    apiRequest request, (result)->
        # Return false on empty response
        if result.length < 1
            callback false
        # Return the fetched object
        else callback result[0]

# Fetches all live streams featuring Heroes of Newerth and passes them to the
# callback
fetchLiveStreams = exports.fetchLiveStreams = (callback)->
    request = "/stream/list.json?meta_game=Heroes%20of%20Newerth"

    apiRequest request, (result)->
        # Run the callback with the result
        callback result

###########################
##### STANDALONE CODE #####
###########################

# Execute if module is run directly
if !module.parent
    fetchLiveStreams (streams)->
        console.log streams[0]
