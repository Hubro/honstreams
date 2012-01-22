
# Dependencies
sequelize = require 'sequelize'
honsdb = require '../database'

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
	
	# The amount of clicks this stream has received so far
	clicks:
		type: sequelize.INTEGER
		allowNull: false
		defaultValue: 0

# Stream model attributes
Stream_attr =
	classMethods:
		foo: ->
	instanceMethods:
		update: ->
			# Do update stuff

# Create the Stream model
Stream = honsdb.define 'Stream', Stream_fields, Stream_attr

# Export the module
module.exports = Stream



###########################
##### Standalone code #####
###########################

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

# Execute
if !process.parent
	# Shift out the call path from argv
	process.argv.shift()

	# require cli and enable some plugins
	cli = require 'cli'
	cli.enable 'version', 'status'

	# Define allowed options and commands
	cli_options = null

	cli_commands =
		create: 'Create a new stream'
		syncdb: 'Synchronize the Streams table with this model'
	
	# Parse the command line input
	cli.parse cli_options, cli_commands

	# Create new stream
	switch cli.command
		when 'create' then create_stream()
		when 'syncdb'
			console.log 'Syncing'
