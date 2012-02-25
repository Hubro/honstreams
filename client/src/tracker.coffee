config = require 'config'

tracker = exports
window._gaq = []

if config.ga_tracking_code
    window._gaq.push ['_setAccount', 'UA-26013152-2']

    $ ->
        `
        (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
        `

        return
else
    console.warn 'No Google analytics tracking code found in config'

tracker.pageView = (path)->
    window._gaq.push ['_trackPageview', path]

tracker.event = (cat, action, label)->
    window._gaq.push ['_trackEvent', cat, action, label]
