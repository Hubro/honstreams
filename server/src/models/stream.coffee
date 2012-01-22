
# Dependencies
sequelize = require 'sequelize'
honsdb = require '../database'
require 'colors'

# Declare Stream's fields
Stream_fields =
	#
	# Static data
	#

	# The primary key
	id:
		type: sequelize.INTEGER
		primaryKey: true
		autoIncrement: true
	
	# This is the channel name of the stream, e.g. "thethrill"
	channel:
		type: sequelize.STRING
		unique: true
		allowNull: false
		validate:
			notEmpty: true
	
	# This is the displayed name of the stream, e.g. "Phil the Thrill"
	name:
		type: sequelize.STRING
		unique: true
		allowNull: false
		validate:
			notEmpty: true
	
	# If the streamer has their own site where the stream is displayed
	custom_url:
		type: sequelize.STRING
		allowNull: true
		# Must be a URL
		validate:
			isUrl: true
	
	# Is this stream sponsored by honstreams?
	sponsored:
		type: sequelize.BOOLEAN
		allowNull: false
		defaultValue: false
	
	#
	# Fleeting channel info
	#

	# Is this stream featured on justin.tv?
	featured:
		type: sequelize.BOOLEAN
		allowNull: false
		defaultValue: false
	
	# Can this stream be embedded?
	embed_enabled:
		type: sequelize.BOOLEAN
		allowNull: false
		defaultValue: true

	# Is this stream being delayed on justin-tv? e.g. Honstreams
	delayed:
		type: sequelize.BOOLEAN
		allowNull: false
		defaultValue: false

	#
	# Fleeting status data
	#

	# Is this stream live right now?
	live:
		type: sequelize.BOOLEAN
		allowNull: false
		defaultValue: false
	
	# The stream's current title, e.g. "Playin some 1900+ hon"
	title:
		type: sequelize.STRING
		allowNull: false
		defaultValue: 'No title set yet'
	
	# The amount of viewers that are watching this stream right now
	viewers:
		type: sequelize.INTEGER
		allowNull: false
		defaultValue: 0
	
	# The amount of viewers that are watching this stream right now via an embed
	# object
	embed_viewers:
		type: sequelize.INTEGER
		allowNull: false
		defaultValue: 0
	
	# Records when a stream was live last
	live_at:
		type: sequelize.DATE
		allowNull: true
		defaultValue: null
	
# Stream model attributes
Stream_attr =
	# User underscores instead of camelcase in MySQL
	underscored: true

	# Static methods
	classMethods: null

	# Methods on the Stream instance
	instanceMethods:
		# Try to update the stream. Can throw exceptions
		update: ->
			jtv = require '../jtv'
			require 'colors'
			self = this

			console.log "Updating stream '#{self.channel}'"

			# Fetch 
			jtv.fetchStreamStatus self.channel, (status)->
				console.log "Received status object for '#{self.channel}'"
				# If the stream is live
				if status
					self.live = true
					self.featured = status.featured
					self.embed_enabled = status.embed_enabled
					self.delayed = (status.broadcaster == 'delayed')
					self.title = status.title
					self.viewers = Number(status.stream_count)
					self.embed_viewers = Number(status.embed_count)
					self.live_at = new Date()

					# Attempt to save
					self.save()
					.success ->
						# Yay!
						console.log "Channel '#{self.channel}' updated and " +
							"set to live"
					.error (msg)->
						# Something went wrong
						console.error "Failed to save update for ".red +
							"'#{self.channel}':".red
						console.error msg
				
				# If the stream is offline
				else
					# If it was already offline, do nothing
					if !self.live
						console.log "Channel '#{self.channel}' is still offline"
						return
					# If it used to be online, set it to offline now and save it
					else
						self.live = false
						self.save()
						.success ->
							# Success! Everthing is saved and dandy
							console.log "Channel '#{self.channel}' updated " +
								"and set to offline"
						.error (msg)->
							# Something went wrong
							console.error "Failed to save update for ".red +
								"'#{self.channel}':".red
							console.error msg
# Create the Stream model
Stream = honsdb.define 'Stream', Stream_fields, Stream_attr

# Export the module
module.exports = Stream



###########################
##### Standalone code #####
###########################

# Creates a new stream with input polled from the user
create_stream = ->
	# Require some user input dependencies
	prompt = require 'prompt'
	async = require 'async'
	require 'colors'

	# Set up prompt
	prompt.message = ''
	prompt.delimiter = ''
	prompt.start()

	prompt_channel =
		name: 'channel'
		message: 'Channel > '
		empty: false
		validator: /^[a-zA-Z\s\_]+$/
		warning: 'Channel name can contain letters, numbers and underscores'
	
	prompt_name =
		name: 'name'
		message: 'Stream name [Use channel] > '
		empty: true
	
	prompt_custom_url =
		name: 'custom_url'
		message: 'Custom URL [None] > '
		empty: true
		validator: /^(?:https?:\/\/)?(?:[\w]+\.)(?:\.?[\w]{2,})+$|^$/

	# Start the input prompt
	prompt.get [prompt_channel, prompt_name, prompt_custom_url], 
		(err, results)->

			# Copy channel to name if name was left empty
			if !Boolean(results.name)
				results.name = results.channel

			# Set custom_url to null if it was left empty
			if !Boolean(results.custom_url)
				results.custom_url = null

			# Create a new Stream
			newStream = Stream.build
				channel: results.channel
				name: results.name
				custom_url: results.custom_url
			
			# Save the new Stream
			newStream.save()
			.success ->
				console.log 'Stream saved'.green
			.error (error)->
				console.error ('Stream creation failed: ' + error.message).red

# Updates the stream of the input channel name
update_stream = (args)->

	# Check for input
	if args.length != 1
		console.error 'Usage: update <channel>'
		process.exit 1
	
	# Try to find the input channel name among the streams
	search = Stream.find where: channel: args[0]
	search.success (result)->
		# Stream found!
		if result
			result.update()
		# If stream couldn't be found, exit
		else
			console.error "Couldn't find channel '#{args[0]}'".red
			return
	
	# If something goes wrong
	search.error (msg)->
		console.error msg

# Synchronizes the Streams table with this model
syncdb = ->
	require 'colors'

	Stream.sync(force: true)
	.success ->
		console.log 'Stream table synchronized'.green
	.error (msg)->
		console.error 'Failed to synchonize table:'.red
		console.error msg

# Execute
if !module.parent
	# Shift out the call path from argv
	process.argv.shift()

	# require cli and enable some plugins
	cli = require 'cli'
	cli.enable 'version', 'status'

	# Define allowed options and commands
	cli_options = null

	cli_commands =
		create: 'Create a new stream'
		update: 'Updates the stream of the input channel name'
		syncdb: 'Synchronize the Streams table with this model (Will drop data)'
	
	# Parse the command line input
	cli.parse cli_options, cli_commands

	# Create new stream
	switch cli.command
		when 'create' then create_stream()
		when 'update' then update_stream cli.args
		when 'syncdb' then syncdb()
