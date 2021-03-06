require("./helpers")
{ vows: vows, assert: assert, zombie: zombie, brains: brains } = require("vows")


brains.get "/form", (req, res)-> res.send """
  <html>
    <body>
      <form action="/submit" method="post">
        <label>Name <input type="text" name="name" id="field-name"></label>
        <label for="field-email">Email</label>
        <input type="text" name="email" id="field-email"></label>
        <textarea name="likes" id="field-likes">Warm brains</textarea>
        <input type="password" name="password" id="field-password">

        <label>Hungry</label>
        <label>You bet<input type="checkbox" name="hungry[]" value="you bet" id="field-hungry"></label>
        <label>Certainly<input type="checkbox" name="hungry[]" value="certainly" id="field-hungry-certainly"></label>

        <label for="field-brains">Brains?</label>
        <input type="checkbox" name="brains" value="yes" id="field-brains">
        <input type="checkbox" name="green" id="field-green" value="Super green!" checked="checked">

        <label>Looks
          <select name="looks" id="field-looks">
            <option value="blood" label="Bloody"></option>
            <option value="clean" label="Clean"></option>
            <option value=""      label="Choose one"></option>
          </select>
        </label>
        <label>Scary <input name="scary" type="radio" value="yes" id="field-scary"></label>
        <label>Not scary <input name="scary" type="radio" value="no" id="field-notscary" checked="checked"></label>

        <select name="state" id="field-state">
          <option>alive</option>
          <option>dead</option>
        </select>

        <select name="unselected_state" id="field-unselected-state">
          <option>alive</option>
          <option>dead</option>
        </select>

        <select name="hobbies[]" id="field-hobbies" multiple="multiple">
          <option>Eat Brains</option>
          <option id="hobbies-messy">Make Messy</option>
          <option>Sleep</option>
        </select>

        <input type="unknown" name="unknown" value="yes">
        <input type="reset" value="Reset">
        <input type="submit" name="button" value="Submit">
        <input type="image" name="image" id="image_submit" value="Image Submit">

        <button name="button" value="hit-me">Hit Me</button>
      </form>
    </body>
  </html>
  """
brains.post "/submit", (req, res)-> res.send """
  <html>
    <body>
      <div id="name">#{req.body.name}</div>
      <div id="likes">#{req.body.likes}</div>
      <div id="green">#{req.body.green}</div>
      <div id="brains">#{req.body.brains}</div>
      <div id="looks">#{req.body.looks}</div>
      <div id="hungry">#{JSON.stringify(req.body.hungry)}</div>
      <div id="state">#{req.body.state}</div>
      <div id="scary">#{req.body.scary}</div>
      <div id="state">#{req.body.state}</div>
      <div id="unselected_state">#{req.body.unselected_state}</div>
      <div id="hobbies">#{JSON.stringify(req.body.hobbies)}</div>
      <div id="unknown">#{req.body.unknown}</div>
      <div id="clicked">#{req.body.button}</div>
      <div id="image_clicked">#{req.body.image}</div>
    </body>
  </html>
  """

brains.get "/upload", (req, res)-> res.send """
  <html>
    <body>
      <form method="post" enctype="multipart/form-data">
        <input name="text" type="file">
        <input name="image" type="file">
        <button>Upload</button> 
      </form>

      <form>
        <input name="get_file" type="file">
        <input type="submit" value="Get Upload">
      </form>
    </body>
  </html>
  """
brains.post "/upload", (req, res)->
  [text, image] = [req.body.text, req.body.image]
  res.send """
  <html>
    <head><title>#{text?.filename || image?.filename}</title></head>
    <body>#{text || image?.length}</body>
  </html>
  """

vows.describe("Forms").addBatch(
  "fill field":
    zombie.wants "http://localhost:3003/form"
      topic: (browser)->
        for field in ["email", "likes", "name", "password"]
          do (field)->
            browser.querySelector("#field-#{field}").addEventListener "change", -> browser["#{field}Changed"] = true
        @callback null, browser
      "text input enclosed in label":
        topic: (browser)->
          browser.fill "Name", "ArmBiter"
        "should set text field": (browser)-> assert.equal browser.querySelector("#field-name").value, "ArmBiter"
        "should fire change event": (browser)-> assert.ok browser.nameChanged
      "email input referenced from label":
        topic: (browser)->
          browser.fill "Email", "armbiter@example.com"
        "should set email field": (browser)-> assert.equal browser.querySelector("#field-email").value, "armbiter@example.com"
        "should fire change event": (browser)-> assert.ok browser.emailChanged
      "textarea by field name":
        topic: (browser)->
          browser.fill "likes", "Arm Biting"
        "should set textarea": (browser)-> assert.equal browser.querySelector("#field-likes").value, "Arm Biting"
        "should fire change event": (browser)-> assert.ok browser.likesChanged
      "password input by selector":
        topic: (browser)->
          browser.fill ":password[name=password]", "b100d"
        "should set password": (browser)-> assert.equal browser.querySelector("#field-password").value, "b100d"
        "should fire change event": (browser)-> assert.ok browser.passwordChanged

  "check box":
    zombie.wants "http://localhost:3003/form"
      topic: (browser)->
        for field in ["hungry", "brains", "green"]
          do (field)->
            browser.querySelector("#field-#{field}").addEventListener "click", -> browser["#{field}Clicked"] = true
            browser.querySelector("#field-#{field}").addEventListener "change", -> browser["#{field}Changed"] = true
        @callback null, browser
      "checkbox enclosed in label":
        topic: (browser)->
          browser.check "You bet"
          browser.wait @callback
        "should check checkbox": (browser)-> assert.ok browser.querySelector("#field-hungry").checked
        "should fire change event": (browser)-> assert.ok browser.hungryChanged
      "checkbox referenced from label":
        topic: (browser)->
          browser.check "Brains?"
          browser.wait @callback
        "should check checkbox": (browser)-> assert.ok browser.querySelector("#field-brains").checked
        "should fire change event": (browser)-> assert.ok browser.brainsChanged
      "checkbox by name":
        topic: (browser)->
          browser.check "green"
          browser["greenChanged"] = false
          browser.uncheck "green"
          browser.wait @callback
        "should uncheck checkbox": (browser)-> assert.ok !browser.querySelector("#field-green").checked
        "should fire change event": (browser)-> assert.ok browser.greenChanged

  "radio buttons":
    zombie.wants "http://localhost:3003/form"
      topic: (browser)->
        for field in ["scary", "notscary"]
          do (field)->
            browser.querySelector("#field-#{field}").addEventListener "click", -> browser["#{field}Clicked"] = true
            browser.querySelector("#field-#{field}").addEventListener "change", -> browser["#{field}Changed"] = true
        @callback null, browser
      "radio button enclosed in label":
        topic: (browser)->
          browser.choose "Scary"
        "should check radio": (browser)-> assert.ok browser.querySelector("#field-scary").checked
        "should fire click event": (browser)-> assert.ok browser.scaryClicked
        "should fire change event": (browser)-> assert.ok browser.scaryChanged
        ###
        "radio button by value":
          topic: (browser)->
            browser.choose "no"
          "should check radio": (browser)-> assert.ok browser.querySelector("#field-notscary").checked
          "should uncheck other radio": (browser)-> assert.ok !browser.querySelector("#field-scary").checked
          "should fire click event": (browser)-> assert.ok browser.notscaryClicked
          "should fire change event": (browser)-> assert.ok browser.notscaryChanged
        ###

  "select option":
    zombie.wants "http://localhost:3003/form"
      topic: (browser)->
        for field in ["looks", "state"]
          do (field)->
            browser.querySelector("#field-#{field}").addEventListener "change", -> browser["#{field}Changed"] = true
        @callback null, browser
      "enclosed in label using option label":
        topic: (browser)->
          browser.select "Looks", "Bloody"
        "should set value": (browser)-> assert.equal browser.querySelector("#field-looks").value, "blood"
        "should select first option": (browser)->
          selected = (option.selected for option in browser.querySelector("#field-looks").options)
          assert.deepEqual selected, [true, false, false]
        "should fire change event": (browser)-> assert.ok browser.looksChanged
      "select name using option value":
        topic: (browser)->
          browser.select "state", "dead"
        "should set value": (browser)-> assert.equal browser.querySelector("#field-state").value, "dead"
        "should select second option": (browser)->
          selected = (option.selected for option in browser.querySelector("#field-state").options)
          assert.deepEqual selected, [false, true]
        "should select first option on second click": (browser)->
          browser.select "state", "alive"
          selected = (option.selected for option in browser.querySelector("#field-state").options)
          assert.deepEqual selected, [true, false]
        "should fire change event": (browser)-> assert.ok browser.stateChanged

  "multiple select option":
    zombie.wants "http://localhost:3003/form"
      topic: (browser)->
        browser.querySelector("#field-hobbies").addEventListener "change", -> browser["hobbiesChanged"] = true
        @callback null, browser
      "select name using option value":
        topic: (browser)->
          browser.select "#field-hobbies", "Eat Brains"
          browser.select "#field-hobbies", "Sleep"
        "should select first and second options": (browser)->
          selected = (option.selected for option in browser.querySelector("#field-hobbies").options)
          assert.deepEqual selected, [true, false, true]
        "should unselect items": (browser)->
          browser.unselect "#field-hobbies", "Sleep"
          selected = (option.selected for option in browser.querySelector("#field-hobbies").options)
          assert.deepEqual selected, [true, false, false]
        "should fire change event": (browser)-> assert.ok browser.hobbiesChanged
        "should not fire change event if nothing changed": (browser)->
          browser["hobbiesChanged"] = false
          browser.select "#field-hobbies", "Eat Brains"
          assert.ok !browser.hobbiesChanged

  "reset form":
    "by calling reset":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.fill("Name", "ArmBiter").fill("likes", "Arm Biting").
            check("You bet").choose("Scary").select("state", "dead")
          browser.querySelector("form").reset()
          @callback null, browser
        "should reset input field to original value": (browser)-> assert.equal browser.querySelector("#field-name").value, ""
        "should reset textarea to original value": (browser)-> assert.equal browser.querySelector("#field-likes").value, "Warm brains"
        "should reset checkbox to original value": (browser)-> assert.ok !browser.querySelector("#field-hungry").value
        "should reset radio to original value": (browser)->
          assert.ok !browser.querySelector("#field-scary").checked
          assert.ok browser.querySelector("#field-notscary").checked
        "should reset select to original option": (browser)-> assert.equal browser.querySelector("#field-state").value, "alive"
    "with event handler":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.querySelector("form :reset").addEventListener "click", (event)=> @callback null, event
          browser.querySelector("form :reset").click()
        "should fire click event": (event)-> assert.equal event.type, "click"
    "with preventDefault":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.fill("Name", "ArmBiter")
          browser.querySelector("form :reset").addEventListener "click", (event)-> event.preventDefault()
          browser.querySelector("form :reset").click()
          @callback null, browser
        "should not reset input field": (browser)-> assert.equal browser.querySelector("#field-name").value, "ArmBiter"
    "by clicking reset input":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.fill("Name", "ArmBiter")
          browser.querySelector("form :reset").click()
          @callback null, browser
        "should reset input field to original value": (browser)-> assert.equal browser.querySelector("#field-name").value, ""

  "submit form":
    "by calling submit":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.fill("Name", "ArmBiter").fill("likes", "Arm Biting").check("You bet").
            check("Certainly").choose("Scary").select("state", "dead").select("looks", "Choose one").
            select("#field-hobbies", "Eat Brains").select("#field-hobbies", "Sleep").check("Brains?")

          browser.querySelector("form").submit()
          browser.wait @callback
        "should open new page": (browser)-> assert.equal browser.location, "http://localhost:3003/submit"
        "should add location to history": (browser)-> assert.length browser.window.history, 2
        "should send text input values to server": (browser)-> assert.equal browser.text("#name"), "ArmBiter"
        "should send textarea values to server": (browser)-> assert.equal browser.text("#likes"), "Arm Biting"
        "should send radio button to server": (browser)-> assert.equal browser.text("#scary"), "yes"
        "should send unknown types to server": (browser)-> assert.equal browser.text("#unknown"), "yes"
        "should send checkbox with default value to server": (browser)->
          assert.equal browser.text("#brains"), "yes"
        "should send checkbox with default value to server": (browser)->
          assert.equal browser.text("#green"), "Super green!"
        "should send multiple checkbox values to server": (browser)->
          assert.equal browser.text("#hungry"), '["you bet","certainly"]'
        "should send selected option to server": (browser)->
          assert.equal browser.text("#state"), "dead"
        "should send first selected option if none was chosen to server": (browser)->
          assert.equal browser.text("#unselected_state"), "alive"
          assert.equal browser.text("#looks"), ""
        "should send multiple selected options to server": (browser)->
          assert.equal browser.text("#hobbies"), '["Eat Brains","Sleep"]'

    "by clicking button":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.fill("Name", "ArmBiter").fill("likes", "Arm Biting").
            pressButton "Hit Me", @callback
        "should open new page": (browser)-> assert.equal browser.location, "http://localhost:3003/submit"
        "should add location to history": (browser)-> assert.length browser.window.history, 2
        "should send button value to server": (browser)-> assert.equal browser.text("#clicked"), "hit-me"
        "should send input values to server": (browser)->
          assert.equal browser.text("#name"), "ArmBiter"
          assert.equal browser.text("#likes"), "Arm Biting"
        "should not send other button values to server": (browser)->
          assert.equal browser.text("#image_clicked"), "undefined"

    "by clicking image button":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.fill("Name", "ArmBiter").fill("likes", "Arm Biting").
            pressButton "#image_submit", @callback
        "should open new page": (browser)-> assert.equal browser.location, "http://localhost:3003/submit"
        "should add location to history": (browser)-> assert.length browser.window.history, 2
        "should send image value to server": (browser)-> assert.equal browser.text("#image_clicked"), "Image Submit"
        "should send input values to server": (browser)->
          assert.equal browser.text("#name"), "ArmBiter"
          assert.equal browser.text("#likes"), "Arm Biting"
        "should not send other button values to server": (browser)->
          assert.equal browser.text("#clicked"), "undefined"

    "by clicking input":
      zombie.wants "http://localhost:3003/form"
        topic: (browser)->
          browser.fill("Name", "ArmBiter").fill("likes", "Arm Biting").
            pressButton "Submit", @callback
        "should open new page": (browser)-> assert.equal browser.location, "http://localhost:3003/submit"
        "should add location to history": (browser)-> assert.length browser.window.history, 2
        "should send submit value to server": (browser)-> assert.equal browser.text("#clicked"), "Submit"
        "should send input values to server": (browser)->
          assert.equal browser.text("#name"), "ArmBiter"
          assert.equal browser.text("#likes"), "Arm Biting"
    "by cliking a button without name":
      zombie.wants "http://localhost:3003/upload"
        topic: (browser)->
          browser.pressButton "Get Upload", @callback
        "should not send inputs without names": (browser)-> assert.equal browser.location.search, "?"

  "file upload (ascii)":
    zombie.wants "http://localhost:3003/upload"
      topic: (browser)->
        @filename = __dirname + "/data/random.txt"
        browser.attach("text", @filename).pressButton "Upload", @callback
      "should upload file": (browser)-> assert.equal browser.text("body").trim(), "Random text"
      "should upload include name": (browser)-> assert.equal browser.text("title"), "random.txt"

  "file upload (binary)":
    zombie.wants "http://localhost:3003/upload"
      topic: (browser)->
        @filename = __dirname + "/data/zombie.jpg"
        browser.attach("image", @filename).pressButton "Upload", @callback
      "should upload include name": (browser)-> assert.equal browser.text("title"), "zombie.jpg"

  "file upload (empty)":
    zombie.wants "http://localhost:3003/upload"
      topic: (browser)->
        browser.attach "text", ""
        browser.pressButton "Upload", @callback
      "should not upload any file": (browser)-> assert.equal browser.text("body").trim(), "undefined"

  "file upload (get)":
    zombie.wants "http://localhost:3003/upload"
      topic: (browser)->
        @filename = __dirname + "/data/random.txt"
        browser.attach("get_file", @filename).pressButton "Get Upload", @callback
      "should send just the file basename": (browser)->
        assert.equal browser.location.search, "?get_file=random.txt"

).export(module)
