
honsapp = require 'honsapp'
hashpath = require 'hashpath'
display_stream_view = require 'views/display_stream'
display_page_view = require 'views/display_page'
dataloader = require 'dataloader'

class Display

    # Static factory function
    @create: ->
        return new Display()
    
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

        # Listen for streams refresh
        honsapp.addEventListener 'streams-refreshed', (streams)->
            self.streams = this
        
        # Load settings
        @chatVisible = dataloader.getSetting 'display-chat', false

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

            This is the **home** page!

            Look, it even supports pure HTML:

            <object type="application/x-shockwave-flash" id="live_embed_player_flash" 
            data="http://www.justin.tv/widgets/live_embed_player.swf?channel=milkfat&auto_play=false" 
            bgcolor="#000000" width="640" height="480">
                <param name="allowFullScreen" value="true" />
                <param name="allowScriptAccess" value="always" />
                <param name="allowNetworking" value="all" />
                <param name="movie" value="http://www.justin.tv/widgets/live_embed_player.swf" />
                <param name="flashvars" value="channel=milkfat&auto_play=false" />
            </object>

            So I can embed **donate boxes** and stuff
        """

        @el.html display_page_view content: @markdown pagetext
    
    setupEvents: ->
        self = @

        # Stream toolbar button "Hide chat box"
        $('#stream_chat_toggle', @el).click ->
            self.toggleStreamChat()
        
        # Stream toolbar button "Visit stream page"
        $('#visit_stream_page', @el).click ->
            window.open "http://twitch.tv/#{self.channel}"

        # Chat reload button
        $('.jtv_wrapper > .chat > .reloadbtn', @el).click ->
            wrapper = $(this).parent().find '.wrapper'
            html = wrapper.html()

            # Empty the wrapper and reinsert the HTML
            wrapper.empty()
            wrapper.html html
        
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
        
        @
            

    # Toggles the stream chat from showing/not showing
    toggleStreamChat: (override)->
        jtv = $(@selectors.jtv, @el)
        button = $(@selectors.toggleChatButton, @el)

        # Hide if visible
        if @chatVisible
            console.log 'Display: Hiding stream chat'
            jtv.addClass 'no-chat'
            button.html 'Show chat'

            dataloader.putSetting 'display-chat', false
        # Show if hidden
        else
            console.log 'Display: Showing stream chat'
            jtv.removeClass 'no-chat'
            button.html 'Hide chat'

            dataloader.putSetting 'display-chat', true
        
        @chatVisible = !@chatVisible

module.exports = Display
