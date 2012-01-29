self = module.exports

# Get the hash
hash = window.location.hash.substr 1

# An array for callbacks
_change = []

# Add an event to hash changed
$(window).hashchange ->
	hash = window.location.hash.substr 1
	path = parsePath hash

	# Call every callback with the new info
	$.each _change, (i, cb)->
		cb path
, false

# Function for registering callbacks
self.addChangeListener = (cb)->
	_change.push cb

# Function for setting the hash path
self.setPath = (arr)->
	hash = '#' + stringifyPath arr
	window.location.hash = hash

parsePath = (url)->
	return [] if not url
	return url.split '/'

stringifyPath = (arr)->
	return arr.join '/'

# An array for the path
path = self.path = parsePath hash
