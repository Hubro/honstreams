
# Dependencies
config = require './config'
oauth = require 'oauth'
util = require 'util'

# Locals
token_received = false
oauth_token = undefined
oauth_token_secret = undefined
jc = config.jtv

# Create an OAuth handle for the justin.tv API
jtvhandle = new oauth.OAuth jc.req_token_url, jc.acc_token_url, jc.key,
							jc.secret, '1.0', null, 'HMAC-SHA1'

# Performs a request to the API and passes the resulting data object to the
# callback
apiRequest = (path, callback)->
	# Ensure path starts with /
	path = if path.indexOf('/') == 0 then path else path = '/' + path
	
	# Attempt to run a request to the API
	jtvhandle.get jc.api_root + path, jc.key, jc.secret, (error, result)->
		info_object = JSON.parse result

		# Run callback with the result
		callback info_object

# Checks if the input stream name is live. Passes true of false to the callback,
# representing online or offline respectively. Can throw exceptions.
fetchChannelStatus = exports.fetchChannelStatus = (channel, callback)->
	request = util.format jc.stream_list, channel

	apiRequest request, (result)->
		# If the response is not empty, the stream is live
		if result.length > 0 and result[0]['meta_game'] == 'Heroes of Newerth'
			return callback true
		
		# Otherwise it's offline
		callback false

if !module.parent
	if process.argv.length < 3
		console.error 'No channel-name given'
		process.exit 1

	fetchChannelStatus process.argv[2], (status)->
		if status
			console.log process.argv[2] + ' is live!!!'
		else
			console.log process.argv[2] + ' is offline.'
