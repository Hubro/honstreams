
# Function for getting input from the user
get_input = (prompt, callback)->

	stdin = process.stdin
	stdout = process.stdout

	# Ready stdin for input
	stdin.resume()
	stdin.setEncoding('utf8')

	# Prompt the user
	stdout.write "#{prompt} > "

	stdin.once 'data', (data)->
		data = String(data).trim()

		if data
			stdin.pause()
			callback data
		else
			get_input(prompt, callback)

# Export the function
module.exports = get_input