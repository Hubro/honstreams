
# Dependencies
fs = require 'fs'
path = require 'path'
minifyjson = require '../vendor/minify.json.js'
_ = require 'underscore'
require 'colors'

default_config = JSON.parse minifyjson """
{
    // The port on which to run the honstreams server
    "port": 1337,

    // The path to the public folder
    "public_folder": "../client/public",

    // MySQL information
    "mysql_host": "127.0.0.1",
    "mysql_port": 3306,
    "mysql_database": "honsdb",
    "mysql_username": "root",
    "mysql_password": "",
    "mysql_logging": false, // Print all mysql queries to stdout

    // justin.tv oauth key and secret
    "jtv_key": null,
    "jtv_secret": null,

    "jtv_api_root": "http://api.justin.tv",
    "jtv_stream_list": "/stream/list.json?channel=%s",
    "jtv_channel_show": "/channel/show/%s.json",

    // OAuth stuff
    "jtv_req_token_url": "http://api.justin.tv/oauth/request_token",
    "jtv_acc_token_url": "http://api.justin.tv/oauth/access_token"
}
"""

# Load config
try
    raw_config = fs.readFileSync __dirname + '/../config.json', 'UTF-8'
    custom_config = JSON.parse minifyjson raw_config

    config = _.extend default_config, custom_config

catch err
    console.warn "Couldn't load config: #{String(err)}".red
    config = default_config

# Set runtime extras
config.root = path.join(__dirname, '/../')

# Export the config
module.exports = config
