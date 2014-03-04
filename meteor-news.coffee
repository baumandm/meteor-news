request = Npm.require('request')

error = (err) ->
    if err 
        console.log(err, err.stack)
  
fetch = (feed) ->
    # Define our streams
    req = request(feed, {timeout: 10000, pool: false})
    req.setMaxListeners(50)

    # Some feeds do not respond without user-agent and accept headers.
    req.setHeader('user-agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36')
        .setHeader('accept', 'text/html,application/xhtml+xml')
    
    feedparser = new Feedparser();

    # Define our handlers
    req.on('error', error)
    req.on('response', (res) ->
        stream = this

        if (res.statusCode != 200) 
            return this.emit('error', new Error('Bad status code'))

        # And boom goes the dynamite
        stream.pipe(feedparser);
    )

    feedparser.on('error', error)
    feedparser.on('end', error)
    feedparser.on('readable', ->
        while (post = this.read())
            console.log('-> '+post.title)
    )


if Meteor.isClient
    Template.hello.greeting = -> "Welcome to meteor-news."


    Template.hello.events {
        'click input': ->
            # template data, if any, is available in 'this'
            if (typeof console != 'undefined')
                console.log("You pressed the button")
    }
  
if Meteor.isServer
    Meteor.startup ->
        fetch('http://news.yahoo.com/rss/')
        
    