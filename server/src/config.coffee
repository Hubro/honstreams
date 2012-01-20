
# Dependencies
fs = require 'fs'
path = require 'path'
minifyjson = require '../vendor/minify.json.js'

# Load config
raw_config = fs.readFileSync __dirname + '/../config.json', 'UTF-8'
config = JSON.parse minifyjson raw_config

# Set runtime extras
config.root = path.join(__dirname, '/../')

# Export the config
module.exports = config