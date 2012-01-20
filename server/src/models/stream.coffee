
# Dependencies
sequelize = require 'sequelize'
honsdb = require '../database'

# Declare Stream's fields
Stream_fields =
	id:
		type: sequelize.INTEGER
		primaryKey: true
		autoIncrement: true
	
	channel:
		type: sequelize.STRING
		unique: true
		allowNull: false
		validate:
			notEmpty: true
	name:
		type: sequelize.STRING
		unique: true
		allowNull: false
		validate:
			notEmpty: true
	custom_url:
		type: sequelize.STRING
		allowNull: true
		# Must be a URL
		validate:
			isUrl: true

	online:
		type: sequelize.BOOLEAN
		allowNull: false
		defaultValue: false
	viewers:
		type: sequelize.INTEGER
		allowNull: false
		defaultValue: 0
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

# Execute ?
if !process.parent

	help = ->
		console.log """
			
			USAGE: Stream command
			
			Where command is one of the following
			  syncdb  Run syncdb on the Stream model
			          Optionally with force
			  new     Insert a new Stream row
			
		"""

	# Expect command
	if not process.argv[2]
		help()
	
	# Sync the table
	if process.argv[2] == 'syncdb'
		force = if process.argv[3] == 'force' then true else false

		Stream.sync(force: force).success ->
			console.log 'Stream table synchronized' + 
				(if force then ' forcefully' else '')
		.error (error)->
			console.log 'Sync failed'
			console.log error
	
	# Insert a new record
	if process.argv[2] == 'new'
		get_input = require '../get_input'
		async = require 'async'

		# Message user
		console.log 'Input the data for new Stream row'

		# Get info from cli
		async.series
			channel: (callback)->
				get_input 'channel', (data)->
					callback(null, data)

			name: (callback)->
				get_input 'name', (data)->
					callback(null, data)

			, (err, results)->

				# Throw any errors
				if err then throw err

				# Create a new Stream
				newStream = Stream.build
					channel: results.channel
					name: results.name
				
				# Save the new Stream
				newStream.save().success ->
					console.log 'Stream saved'
				.error (error)->
					console.log 'An error occurred'
					console.log error