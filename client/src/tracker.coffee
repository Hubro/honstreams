config = require 'config'

tracker = exports
heartbeat = null
window._gaq = []

if config.ga_tracking_code
    window._gaq.push ['_setAccount', 'UA-26013152-2']
    window._gaq.push ['_setSessionCookieTimeout', 120000]

    # Run minute heartbeats
    heartbeat = setInterval ->
        tracker.event 'Heartbeat', 'Beat'
    , 60000

    # Insert the ga code at page ready
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
    if label
        window._gaq.push ['_trackEvent', cat, action, label]
    else
        window._gaq.push ['_trackEvent', cat, action]
