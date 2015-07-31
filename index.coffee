express        = require 'express'
bodyParser     = require 'body-parser'
methodOverride = require 'method-override'
serveStatic    = require 'serve-static'
errorhandler   = require 'errorhandler'
concat         = require 'concat'

base           = require './base'

# Express Configuraion
app = express()
app.use serveStatic __dirname + '/client'
app.use bodyParser.urlencoded({ extended: false })
app.use bodyParser.json()
app.use methodOverride()
app.use errorhandler()
app.set 'json spaces', 4

# Routes
app.get '/', base.index

# Start server
app.listen process.env.PORT, () ->
  console.log "Listening at port: #{process.env.PORT}"
