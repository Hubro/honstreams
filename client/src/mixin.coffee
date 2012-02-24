class Mixin
    # Copy all properties from mixin to this obj. Ignore properties that already
    # exist
    @mix: (obj) ->
        if not obj then throw('mix(obj) requires obj')

        for key, value of @prototype when key != 'constructor'
            if not obj[key] then obj[key] = value
        
        # If there's a constructor, run in on obj
        if @::constructor then @::constructor.call obj

        return

module.exports = Mixin
