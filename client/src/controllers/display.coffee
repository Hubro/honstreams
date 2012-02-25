
honsapp = require 'honsapp'
hashpath = require 'hashpath'
display_stream_view = require 'views/display_stream'
display_page_view = require 'views/display_page'
dataloader = require 'dataloader'
tracker = require 'tracker'

class Display

    # Static factory function
    @create: -> return new Display()
    
    # Members
    defaultPath: ['pages', 'home']
    streams: null
    chatVisible: false

    # Selectors
    selectors:
        jtv: '.jtv_wrapper'
        chat: '.jtv_wrapper .chat'
        toggleChatButton: '#stream_chat_toggle'

    # Constructor
    constructor: ->
        # Set up the controller
        self = @self = this
        @el = $('<div>').addClass 'display'

        # Create a markdown parser object
        converter = new Showdown.converter()
        @markdown = converter.makeHtml

        # Load settings
        @chatVisible = dataloader.getMemory 'display-chat', true
    
    # Setter for the streams
    setStreams: (streams)->
        @streams = streams

    # Decide what to do according to the input path array
    processPath: (path)->
        if !path.length
            return hashpath.setPath @defaultPath
        
        if path[0] == "pages"
            @displayPage path[1]

        if path[0] == "stream"
            @displayStream path[1]

    # Takes a channel name as input and displays it's stream
    displayStream: (channel)->
        # If the streams haven't been loaded yet, do nothing
        if !@streams then return

        @channel = channel

        # Check if the requested stream exists
        stream = false
        $.each @streams, (i, e)->
            if e.channel == channel
                stream = e
                return false
        
        # If yes, display it. Otherwise alert the user of the error
        if stream
            @el.html display_stream_view
                stream: stream
                showChat: @chatVisible
        else
            @el.html 'STREAM NOT FOUND'
        
        @setupEvents()
    
    # Takes a page path and displays it using markdown
    displayPage: (page)->
        pagetext = """
            # Welcome to Honstreams.com!

            This is an early beta version of Honstreams 3.0 so don't expect
            every feature to work perfectly in every scenario imaginable.

            If you have any feature requests or complaints please contact me on
            <tomas@honstreams.com>

            ## Important note

            I might roll out updates to this application as often as a few times
            per day. In other words, if you can't load the application all of a
            sudden, chances are I've taking it down to run a git pull. In that
            situation please wait a few minutes and try again :-)
        """

        @el.html display_page_view content: @markdown pagetext
    
    setupEvents: ->
        self = @

        # Stream toolbar button "Hide chat box"
        $('#stream_chat_toggle', @el).click ->
            self.toggleStreamChat()

            # Track the event
            tracker.event 'ChatToggleButton', 'Click', self.channel
        
        # Stream toolbar button "Visit stream page"
        $('#visit_stream_page', @el).click ->
            window.open "http://twitch.tv/#{self.channel}"

            # Track the event
            tracker.event 'VisitTwitchButton', 'Click', self.channel

        # Chat reload button
        $('.jtv_wrapper > .chat > .reloadbtn', @el).click ->
            wrapper = $(this).parent().find '.wrapper'
            html = wrapper.html()

            # Empty the wrapper and reinsert the HTML
            wrapper.empty()
            wrapper.html html

            # Track the event
            tracker.event 'ChatReloadButton', 'Click', self.channel
        
        # Chat reload box tooltip
        $('.jtv_wrapper > .chat > .reloadbtn', @el).tipsy
            gravity: 's'
            fade: true
            opacity: 0.95
            title: ->
                """
                This button will reload the justin.tv chat box. This is useful
                after you resize the browser window since the chat box won't
                scale with it
                """
        
        # Hide least important elements as the window space is reduced
        initial_resize = true # For the initial resize, don't use animations
        ltbox_hidden = false
        header_right_hidden = false

        $(window).resize (e)->
            width = $(window).width()
            anim_duration = if initial_resize then 0 else 100

            ltbox = $('.header > .stream-title', self.el)
            ltbox_width = 1080

            header_right = $('.header > .viewers, .header > .featured')
            header_right_width = 750

            # The live title should only be shown if the window is > 1050px
            if width <= ltbox_width and !ltbox_hidden
                ltbox.stop().animate {opacity: 0}, anim_duration
                ltbox_hidden = true
            else if width > ltbox_width and ltbox_hidden
                ltbox.stop().animate {opacity: 1}, anim_duration
                ltbox_hidden = false
            
            # The right part of the stream info should be hidden if the window
            # is
            if width <= header_right_width and !header_right_hidden
                header_right.stop().animate {opacity: 0}, anim_duration
                header_right_hidden = true
            else if width > header_right_width and header_right_hidden
                header_right.stop().animate {opacity: 1}, anim_duration
                header_right_hidden = false

        # Trigger an initial resize for the elements to settle
        $(window).resize()
        initial_resize = false

        @

    # Toggles the stream chat from showing/not showing
    toggleStreamChat: (override)->
        jtv = $(@selectors.jtv, @el)
        button = $(@selectors.toggleChatButton, @el)

        # Hide if visible
        if @chatVisible
            jtv.addClass 'no-chat'
            button.html 'Show chat'

            dataloader.putMemory 'display-chat', false

            # Track the event
            tracker.event 'StreamChat', 'Hide', @channel
        # Show if hidden
        else
            jtv.removeClass 'no-chat'
            button.html 'Hide chat'

            dataloader.putMemory 'display-chat', true

            # Track the event
            tracker.event 'StreamChat', 'Show', @channel
        
        @chatVisible = !@chatVisible

module.exports = Display
