express = require 'express'
path = require 'path'

app = express()
PORT = process.env.PORT or 3000

# Middleware
app.use express.json()
app.use express.static path.join __dirname, '..', 'public'

# Chub API proxy endpoints
CHUB_API = 'https://api.chub.ai'

# Search characters
app.get '/api/search', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  queryParams = new URLSearchParams req.query

  try
    response = await fetch "#{CHUB_API}/search?#{queryParams}",
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    res.json data
  catch err
    res.status(500).json error: err.message

# Get specific character
app.get '/api/characters/:creator/:name', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {creator, name} = req.params

  try
    response = await fetch "#{CHUB_API}/api/characters/#{creator}/#{name}",
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    res.json data
  catch err
    res.status(500).json error: err.message

# Update character
app.put '/api/characters/:creator/:name', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {creator, name} = req.params

  try
    response = await fetch "#{CHUB_API}/api/core/characters/#{creator}/#{name}",
      method: 'PUT'
      headers:
        'CH-API-KEY': apiKey
        'Content-Type': 'application/json'
      body: JSON.stringify req.body
    data = await response.json()
    res.json data
  catch err
    res.status(500).json error: err.message

# Get user's projects
app.get '/api/users/:username', (req, res) ->
  apiKey = req.headers['x-chub-api-key']
  unless apiKey
    return res.status(401).json error: 'Missing X-Chub-API-Key header'

  {username} = req.params

  try
    response = await fetch "#{CHUB_API}/api/users/#{username}",
      headers:
        'CH-API-KEY': apiKey
    data = await response.json()
    res.json data
  catch err
    res.status(500).json error: err.message

app.listen PORT, ->
  console.log "Chub Manager running at http://localhost:#{PORT}"
