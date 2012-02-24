
Mixin = require 'mixin'

class EventEmitter extends Mixin

    # Object to hold the events
    _events: {}

    # Register a new callback
    on: (event_name, callback)->
        if !@_events[event_name] then @_events[event_name] = []
        @_events[event_name].push callback

        @
    
    # Register a callback to happen only once
    once: (event_name, callback)->
        self = @
        if !@_events[event_name] then @_events[event_name] = []

        num = self._events.length

        @_events[event_name].push ->
            callback()
            delete self._events[num]
            return
        
        @

    # Function for triggering an event with an optional context object
    trigger: (event_name, context)->
        context = {} unless context
        funcs = @_events[event_name]

        if funcs then for func in funcs
            func.call context
        
        @

module.exports = EventEmitter
