
# Dependencies
Sequelize = require 'sequelize'
honsdb = require '../honsdb'
config = require '../config'
mysql = require 'mysql'
queues = require 'mysql-queues'
async = require 'async'
_ = require 'underscore'
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
    # Use underscores instead of camelcase in MySQL
    underscored: true

    # Static methods
    classMethods:
        # Perform a full update of the Stream database
        updateAllFromRaw: (rawdata, callback)->

            # Validate the input
            if !_.isArray rawdata
                callback 'Invalid input type for arg1: ' + typeof rawdata
                return

            # Create a MySQL connection
            con = mysql.createConnection
                host: config.mysql_host
                user: config.mysql_username
                password: config.mysql_password
                database: config.mysql_database

            # Start a transaction
            queues con, false
            trans = con.startTransaction()

            # First set all streams to offline
            console.log 'Setting all existing streams to offline'.yellow
            trans.query 'UPDATE `Streams` SET live=0;'
            # trans.query 'TRUNCATE `Streams`;'

            # Update each stream
            for rawstream in rawdata
                console.log 'Inserting/replacing ' + rawstream.channel.login

                query = """
                    REPLACE INTO `Streams`
                        (`channel`, `title`, `live_title`, `screen_cap_small`,
                         `channel_image_medium`, `live`, `viewers`,
                         `embed_viewers`, `embed_enabled`, `featured`,
                         `delayed`, `live_at`, `created_at`, `updated_at`)
                        VALUES
                            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
                """
                params = [
                    rawstream.channel.login,
                    rawstream.channel.title,
                    rawstream.title,
                    rawstream.channel.screen_cap_url_small,
                    rawstream.channel.image_url_medium,
                    true,
                    rawstream.channel_count or 0,
                    rawstream.embed_count or 0,
                    rawstream.channel.embed_enabled,
                    rawstream.featured,
                    rawstream.broadcaster == 'delay',
                    new Date(),
                    new Date(),
                    new Date()
                ]

                trans.query query, params, (err, info)->
                    if err
                        trans.rollback()
                        throw err

            trans.commit ->
                con.end()
                callback?()

            return

        # Fetch all streams from the database, including persistent data. The
        # callback is returned with arguments error and data. Error is false
        # unless an error occurred.
        fetchWithPersistentData: (filter_string, callback)->

            # If only a callback was passed
            if typeof filter_string == 'function'
                callback = filter_string
                filter_string = null

            # Create a MySQL connection
            con = mysql.createConnection
                host: config.mysql_host
                user: config.mysql_username
                password: config.mysql_password
                database: config.mysql_database

            # Ready the query
            query = """
                SELECT
                    Streams . *,
                    StreamsPD.custom_name,
                    StreamsPD.competitive,
                    StreamsPD.sponsored
                FROM
                    Streams
                        LEFT JOIN
                    StreamsPD ON Streams.channel = StreamsPD.channel
            """

            # Was there a filter string?
            if filter_string
                query += "\nWHERE #{filter_string}"

            # Order by live, then viewers
            query += "\nORDER BY live DESC, viewers DESC;"

            # Run the query and pass the returned data to the callback
            con.query query, (err, data)->
                con.end()
                callback err, data

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
