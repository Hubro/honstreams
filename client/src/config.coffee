###
Configuration module for honstreams
###

# Default configuration - mostly just for reference purposes when writing a new
# custom configuration file
module.exports = config =
{
    # Required: Stream data path
    'stream_data_url': null

    # Google analytics tracking code (Required for tracking)
    'ga_tracking_code': null

    # Styling options
    'sidebar_title': null
    'sidebar_image': null # 40x40
}

# Fetch custom configuration
$.ajax
    url: 'config.json'
    async: false
    complete: (e)->
        # Check if the config file was loaded successfully
        if e.status == 200
            # Try to parse it as JSON
            try
                c = JSON.parse e.responseText

                # Extend default configuration
                $.extend config, c
            catch error
                err = String(error)
                console.error 'Config file could not be parsed. Error: ' + err
                config.error = true
        else
            console.error 'Config file could not be loaded. Code: ' + e.status
            config.error = true
