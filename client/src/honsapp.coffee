
self = module.exports

# Dependencies
Sidebar = require 'controllers/sidebar'
Display = require 'controllers/display'
dataloader = require 'dataloader'
hashpath = require 'hashpath'
config = require 'config'

# Initiates the honstreams app
self.init = (selector)->

    # Check if the configuration file was loaded
    if config.error
        @el.html 'Failed to load configuration file'
        return
    
    # Tie the creation to window.ready just to be sure
    $ ->
        # Set class to honsapp
        self.el = $(selector).addClass 'honsapp'

        # Add the sidebar
        sidebar = Sidebar.create()
        self.el.append sidebar.el

        # Add the display
        display = Display.create()
        self.el.append display.el

        # Fetch live streams and repeat every minute
        _first = true
        fetchLiveStreams = ->

            dataloader.fetchLiveStreams (streams)->
                # streams can be false
                if !streams then return

                # Sort streams by status
                streams.sort (a, b)->
                    return -1 if a.viewers > b.viewers
                    return 1
                
                sidebar.setStreams streams
                display.setStreams streams

                # Run the first hashchange event after all is loaded
                if _first then $(window).hashchange() and _first = false

        setInterval fetchLiveStreams, 60000
        fetchLiveStreams()

        # Listen to the hash path changing
        hashpath.addChangeListener (path)=>
            # Tell the Display to update it's content
            display.processPath path
        
        console.log 'Honstreams app is initiated'
