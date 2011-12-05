# Integrates with memegenerator.net
#
# meme Y U NO <text>              - Generates the Y U NO GUY with the bottom caption
#                              of <text>
#
# meme I don't always <something> but when i do <text> - Generates The Most Interesting man in the World
#
# meme <text> ORLY?               - Generates the ORLY? owl with the top caption of <text>
#
# meme <text> (SUCCESS|NAILED IT) - Generates success kid with the top caption of <text>
#
# meme <text> ALL the <things>    - Generates ALL THE THINGS
#
# meme <text> TOO DAMN <high> - Generates THE RENT IS TOO DAMN HIGH guy
#
# meme Good news everyone! <news> - Generates Professor Farnsworth
#
# meme kahn <text> - TEEEEEEEEEEEEXT!!!!

module.exports = (robot) ->
  robot.respond /meme Y U NO (.+)/i, (msg) ->
    caption = msg.match[1] || ""

    memeGenerator msg, 2, 166088, "Y U NO", caption, (url) ->
      msg.send url

  robot.respond /meme (I DON'?T ALWAYS .*) (BUT WHEN I DO,? .*)/i, (msg) ->
    memeGenerator msg, 74, 2485, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /meme (.*)(O\s?RLY\??.*)/i, (msg) ->
    memeGenerator msg, 920, 117049, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /meme (.*)(SUCCESS|NAILED IT.*)/i, (msg) ->
    memeGenerator msg, 121, 1031, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /meme (.*) (ALL the .*)/i, (msg) ->
    memeGenerator msg, 6013, 1121885, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /meme (.*) (\w+\sTOO DAMN .*)/i, (msg) ->
    memeGenerator msg, 998, 203665, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /meme (GOOD NEWS EVERYONE[,.!]?) (.*)/i, (msg) ->
    memeGenerator msg, 1591, 112464, msg.match[1], msg.match[2], (url) ->
      msg.send url

  robot.respond /meme khan (.+)/i, (msg) ->
    memeGenerator msg, 6443, 1123022, "", khanify(msg.match[1]), (url) ->
      msg.send url

memeGenerator = (msg, generatorID, imageID, text0, text1, callback) ->
  username = process.env.HUBOT_MEMEGEN_USERNAME
  password = process.env.HUBOT_MEMEGEN_PASSWORD

  unless username
    msg.send "MemeGenerator username isn't set. Sign up at http://memegenerator.net"
    msg.send "Then set the HUBOT_MEMEGEN_USERNAME environment variable"
    return

  unless password
    msg.send "MemeGenerator password isn't set. Sign up at http://memegenerator.net"
    msg.send "Then set the HUBOT_MEMEGEN_PASSWORD environment variable"
    return

  msg.http('http://version1.api.memegenerator.net/Instance_Create')
    .query
      username: username,
      password: password,
      languageCode: 'en',
      generatorID: generatorID,
      imageID: imageID,
      text0: text0,
      text1: text1
    .get() (err, res, body) ->
      result = JSON.parse(body)['result']
      if result? and result['instanceUrl']? and result['instanceImageUrl']?
        instanceURL = result['instanceUrl']
        img = result['instanceImageUrl']
        msg.http(instanceURL).get() (err, res, body) ->
          # Need to hit instanceURL so that image gets generated
          callback "http://memegenerator.net#{img}"
      else
        msg.reply "Sorry, I couldn't generate that image."

khanify = (msg) ->
  msg = msg.toUpperCase()
  vowels = [ 'A', 'E', 'I', 'O', 'U' ]
  index = -1
  for v in vowels when msg.lastIndexOf(v) > index
    index = msg.lastIndexOf(v)
  "#{msg.slice 0, index}#{Array(10).join msg.charAt(index)}#{msg.slice index}!!!!!"