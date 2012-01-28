
# Dependencies
Sequelize = require 'sequelize'
honsdb = require '../honsdb'
async = require 'async'
StreamData = require './streamdata'
require 'colors'

# Declare Stream's fields
Stream_fields =
	#
	# Static data
	#

	# The primary key
	id:
		type: Sequelize.INTEGER
		primaryKey: true
		autoIncrement: true
	
	# This is the channel name of the stream, e.g. "thethrill"
	channel:
		type: Sequelize.STRING
		unique: true
		allowNull: false
		validate:
			notEmpty: true
	
	#
	# Textual stream data
	#
	
	# This is the displayed name of the stream, e.g. "Phil the Thrill"
	title:
		type: Sequelize.STRING
		allowNull: false
		validate:
			notEmpty: true
	
	# The stream's current title, e.g. "Playin some 1900+ hon"
	live_title:
		type: Sequelize.STRING
		allowNull: true
	
	#
	# Links
	#
	
	screen_cap_small:
		type: Sequelize.STRING
		allowNull: false

	channel_image_medium:
		type: Sequelize.STRING
		allowNull: false

	#
	# Flags and numbers
	#

	# Is this stream live right now?
	live:
		type: Sequelize.BOOLEAN
		allowNull: false
	
	# The amount of viewers that are watching this stream right now
	viewers:
		type: Sequelize.INTEGER
		allowNull: false
	
	# The amount of viewers that are watching this stream right now via an embed
	# object
	embed_viewers:
		type: Sequelize.INTEGER
		allowNull: false
	
	# Can this stream be embedded?
	embed_enabled:
		type: Sequelize.BOOLEAN
		allowNull: false
	
	# Is this stream featured on justin.tv?
	featured:
		type: Sequelize.BOOLEAN
		allowNull: false

	# Is this stream being delayed on justin-tv? e.g. Honcast
	delayed:
		type: Sequelize.BOOLEAN
		allowNull: false
	
	# Records when a stream was live last
	live_at:
		type: Sequelize.DATE
		allowNull: false
	
# Stream model attributes
Stream_attr =
	# User underscores instead of camelcase in MySQL
	underscored: true

	# Static methods
	classMethods:
		# Perform a full update of the Stream database
		updateAllFromRaw: (rawdata)->
			# First set all streams to offline
			honsdb.query('UPDATE Streams SET live=0')
			.success ->
				console.log 'All streams set to offline'.yellow

				# Update each stream
				for rawstream in rawdata
					Stream.updateFromRaw rawstream
			.error (e)->
				console.error 'Couldn\'t set all streams to offline:'.red
				console.error e.message.red
			
		# Update the content of a single Stream from the input data
		updateFromRaw: (rawdata)->

			# Ready an error function that'll be used a lot
			sqlerror = (e)->
				console.error e.message.red
				console.error ('On stream: ' + rawdata.channel.login).red

			# Check if the stream already exists
			this.find(where: channel: rawdata.channel.login)
			.success (stream)->
				# If the stream doesn't exist, just create a new stream
				if stream == null
					create_new()
				# Otherwise, refresh the existing stream with new data
				else
					update stream
			.error sqlerror
			
			# The raw data structured in the layout of the database, ready for
			# update or insertion
			structured_data =
				channel: rawdata.channel.login
				title: rawdata.channel.title
				live_title: rawdata.title
				screen_cap_small: rawdata.channel.screen_cap_url_small
				channel_image_medium: rawdata.channel.image_url_medium
				live: true
				viewers: rawdata.channel_count
				embed_viewers: rawdata.embed_count
				embed_enabled: rawdata.channel.embed_enabled
				featured: rawdata.featured
				delayed: rawdata.broadcaster == 'delayed'
				live_at: new Date()
			
			# Adds a new stream to the database using the input rawdata object
			create_new = ->
				# Create the new stream and save it
				new_stream = Stream.build(structured_data)
				.save()
				.success ->
					console.log "#{rawdata.channel.login} added".green
				.error sqlerror
			
			# Updates a stream in the database with new data
			update = (stream)->
				stream.updateAttributes(structured_data)
				.success ->
					console.log "#{rawdata.channel.login} updated".cyan
				.error sqlerror

	# Methods on the Stream instance
	instanceMethods:
		toJSON: ->
			rawstream = {};

			for attr in this.attributes
				rawstream[attr] = this[attr]
			
			return rawstream
		
		getStreamData: (callback)->
			return

# Create the Stream model
Stream = honsdb.define 'Stream', Stream_fields, Stream_attr

# Export the module
module.exports = Stream
