--[[
    Some more or less useful experiments with the macos event system
    see http://www.hammerspoon.org/docs
]]--

logger = hs.logger.new('ststefa')
logger.LogLevel = "debug"

--[[
    Show PID of active window and copy to clipboard (plus some useless experiments)
]]--
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "p",
    function()
        local win = hs.window.focusedWindow()
        local app = win:application()
        local pasteboard = require("hs.pasteboard") -- http://www.hammerspoon.org/docs/hs.pasteboard.html

        hs.notify.new({title=app:title(), informativeText="PID " .. app:pid()}):send()
        hs.alert.show("PID " .. app:pid() .. " (copied)")
        pasteboard.setContents(app:pid())
        --hs.speech.new("com.apple.speech.synthesis.voice.Zarvox"):speak("process ID: " .. app:pid())

        -- also send as imessage, just for testing
        --hs.messages.iMessage("steinert@me.com", "PID " .. app:pid())
    end
)

--[[
--Draw highlight circle at mouse position
mouseCircle = nil
mouseCircleTimer = nil
function mouseHighlight()
    -- Delete an existing highlight if it exists
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    mousePos = hs.mouse.getAbsolutePosition()

    mouseCircle = hs.drawing.circle(hs.geometry.rect(mousePos.x-60, mousePos.y-60, 120, 120))
    mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    mouseCircle:setFill(false)
    mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    mouseCircleTimer = hs.timer.doAfter(1, function() mouseCircle:delete() end)
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "d", mouseHighlight)
]]--

--[[
-- Dialog test
function testDialog()
    local testCallbackFn = function(result) print("Callback Result: " .. result) end
    hs.dialog.alert(50, 50, testCallbackFn, "Message", "Informative Text", "Button One", "Button Two", "NSCriticalAlertStyle")
    hs.dialog.alert(200, 200, testCallbackFn, "Message", "Informative Text", "Single Button")
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "e", testDialog)
]]--

--[[
    Auto-reload config if file changes
]]--
function reloadConfig(files)
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            hs.reload()
            break
        end
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config reloaded")

--[[
    Generic exec
]]--
function streamCallback(task, stdOut, stdErr)
    return true
end
function execCallback(exitCode, stdOut, stdErr)
    if (exitCode ~= 0) then
        hs.alert.show("Execution error, see hammerspoon console")
    end
    print("rc:" .. exitCode)
    print("stdOut:" .. stdOut)
    print("stdErr:" .. stdErr)
end
function run_command(command, arg_list)
    print(command .. ' ' .. table.concat(arg_list,' ') .. " ...")
    task=hs.task.new(command, execCallback, streamCallback, arg_list)
    task:start()
    task:waitUntilExit()
    print('done')
end

--[[
    Experiments
]]--
print("Default voice:" .. hs.speech.defaultVoice())
--print(table.concat(hs.speech.availableVoices(true),'\n'))

print("Audio devices:")
for k,v in pairs(hs.audiodevice.allDevices()) do
    print(string.format("  %s: %s", k, v:name()))
end

-- Should print stdout but doesn't ?!?
run_command('/bin/echo', {"test"})

-- Some session properties. Note usage of inspect()
print("Session properties: " .. hs.inspect.inspect(hs.caffeinate.sessionProperties()))

-- Monitor distributed notifications for no apparent reason
notifyWatcher = hs.distributednotifications.new(
    function(name, object, userInfo)
        print(string.format("Distributed notification; name: %s, object: %s, userInfo: %s", name, object, hs.inspect(userInfo)))
    end
)
notifyWatcher:start()

-- https://www.hammerspoon.org/docs/hs.urlevent.html#httpCallback
--[[
    function printHttp(scheme, host, params, fullURL, senderPID)
        print("Scheme:" .. scheme)
        print("Host:" .. host)
        print("Params:")
        print(table.concat(params, '\n'))
        print("FullURL:" .. fullURL)
        print("SenderPID:" .. senderPID)
    end
    hs.urlevent.httpCallback = printHttp
]]--

--[[
    Application events
]]--
function printAudio()
    print("Input:")
    for k,v in pairs(hs.audiodevice.current(true)) do
        print(string.format("  %s: %s", k, v))
    end
    print("Output:")
    for k,v in pairs(hs.audiodevice.current(false)) do
        print(string.format("  %s: %s", k, v))
    end
end
function applicationWatcher(appName, eventType, appObject)
    -- Note that LUA has this funny behaviour of indexing lists starting from 1 by default
    local eventNames = {[0]="launching", "launched", "terminated", "hidden", "unhidden", "activated", "deactivated"}
    -- Too noisy
    if (eventType ~= hs.application.watcher.activated) and (eventType ~= hs.application.watcher.deactivated) then
        print(string.format("APP Event: %s %s", appName, eventNames[eventType]))
    end
    if (appName == "OBS Studio") then
        print(string.format("APP Event %s: %s", appName, eventNames[eventType]))
        if (eventType == hs.application.watcher.launched) then
            --run_command('/opt/homebrew/bin/SwitchAudioSource', {"-t", "input", "-s", "ToApp"})
            print("Current audio setup:")
            printAudio()
            hs.audiodevice.findDeviceByName("ToApp"):setDefaultInputDevice()
            --hs.audiodevice.findDeviceByName("FromApp"):setDefaultOutputDevice()
            print("New audio setup:")
            printAudio()
            hs.alert.show("OBS looped into audio path",hs.alert.defaultStyle,hs.screen.mainScreen(),7)
        elseif (eventType == hs.application.watcher.terminated) then
            --run_command('/opt/homebrew/bin/SwitchAudioSource', {"-t", "input", "-s", "MacBook Pro-Mikrofon"})
            print("Current audio setup:")
            printAudio()
            hs.audiodevice.findDeviceByName("MacBook Pro-Mikrofon"):setDefaultInputDevice()
            --hs.audiodevice.findDeviceByName("MacBook Pro-Lautsprecher"):setDefaultOutputDevice()
            print("New audio setup:")
            printAudio()
            hs.alert.show("OBS removed from audio path",hs.alert.defaultStyle,hs.screen.mainScreen(),7)
        end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

--[[
    Battery/Power-source events
]]--
lastPowerSource=hs.battery.powerSource()
batteryWatcher = hs.battery.watcher.new(
    function()
        powerSource = hs.battery.powerSource()
        print("BAT event: " .. powerSource)
        if (powerSource ~= lastPowerSource) then
            print("Power source changed from " .. lastPowerSource .. " to " .. powerSource)
            lastPowerSource = powerSource
            if (powerSource == "Battery Power") then
                --[[
                -- Must not caffeinate if lid closed. Otherwise will never sleep and drain battery
                if not activeTimer then
                    caffeinate()
                else
                    print("already caffeeinating")
                end
                -- Warn about AC loss, now handled by iStatMenus
                hs.alert.show("Lost AC power")
                ]]--
            else
                --[[
                -- Not de-caffeeinating. Kills network connections in case lid is still closed while plugging in power
                if activeTimer then
                    activeTimer:fire()
                else
                    print("not caffeeinating, nothing to change")
                end
                ]]--
            end
        end
    end
)
batteryWatcher:start()

--[[
    Power management events
]]--
pmWatcher=hs.caffeinate.watcher.new(
    function(event)
        -- Note that LUA has this funny behaviour of indexing lists starting from 1 by default
        local evNames={[0]="didWake", "willSleep", "willPowerOff", "screensDidSleep", "screensDidWake", "sessionDidResignActive", "sessionDidBecomeActive", "screensaverDidStart", "screensaverWillStop", "screensaverDidStop", "screensDidLock", "screensDidUnlock"}

        print("PM event:" .. event .. " (" .. evNames[event] .. ")")

        --if (event == 1 or event == 3) then
        --    if (is_sleeping == false) then
        --        print("disable caffeeination")
        --        is_sleeping=true
        --    end
        --elseif (event == 0 or event == 4) then
        --    if (is_sleeping == true) then
        --        print("enable caffeeination")
        --        is_sleeping=false
        --    end
        --end
    end
)
pmWatcher:start()


--[[
    Toggle caffeinate state (i.e. caffeinate if not caffeinating, disable caffeination if caffeinating)
    Some commands need to be allowed via sudo (NOPASSWD).
]]--
--[[
is_sleeping=false
-- make sure sleep is enabled in case a hammerspoon reload happens while a timer was active
run_command('/usr/bin/sudo', {"/usr/bin/pmset", "disablesleep", "0"})

function caffeinate()
    local timed_sleep_handler = function(exitCode, stdout, stderr)
        if (exitCode == 0) then
            hs.alert.show("Caffeinating for 5 minutes")
            print("Caffeinating for 5 minutes")
            -- Immediately schedule cleanup function
            activeTimer = hs.timer.doAfter(5 * 60, function()
                -- https://superuser.com/questions/1018140/keep-macbook-running-with-lid-closed-for-specified-duration/1018150
                run_command('/usr/bin/sudo', {"/usr/bin/pmset", "-b", "sleep", "5"})
                run_command('/usr/bin/sudo', {"/usr/bin/pmset", "disablesleep", "0"})
                activeTimer=nil
                hs.alert.show("De-caffeinated")
                print("De-caffeinated")
            end)
            print("de-caffeination timser set")
        else
            hs.alert.show("Could not caffeinate, see hammerspoon console")
            print("Could not caffeinate")
        end
        print("rc:" .. exitCode)
        print("stdout:" .. stdout)
        print("stderr:" .. stderr)
    end

    if activeTimer then
        activeTimer:fire()
    else
        if (is_sleeping == true) then
            print("not caffeeinating, lid closed")
        else
            -- https://superuser.com/questions/1018140/keep-macbook-running-with-lid-closed-for-specified-duration/1018150
            run_command('/usr/bin/sudo', {"/usr/bin/pmset", "-b", "sleep", "0"})
            task=hs.task.new('/usr/bin/sudo', timed_sleep_handler, streamCallback, {"/usr/bin/pmset", "disablesleep", "1"})
            task:start()
            task:waitUntilExit()
            print("pmset disablesleep 1 ended")
        end
    end
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", function() caffeinate() end)
]]--

--[[
    Tap into URL dispatching. Hammerspoon is the default "browser" and
    intercepts all invocations, making them manageable.
]]--

hs.loadSpoon("URLDispatcher")
--spoon.URLDispatcher.logger.setLogLevel("debug")
spoon.URLDispatcher.default_handler = "com.choosyosx.Choosy"

--- List containing optional redirection decoders (other than the known Slack
--- decoder, which is enabled by `URLDispatcher.decode_slack_redir_urls` to
--- apply to URLs before dispatching them. Each list element must be a list
--- itself with a maximum of five elements:
---   * `decoder-name`: (String) a name to identify the decoder;
---   * `decoder-pattern-or-function`: (String or Function) if a string is
---     given, it is used as a [Lua pattern](https://www.lua.org/pil/20.2.html)
---     to match against the URL. If a function is given, it will be called with
---     arguments `scheme`, `host`, `params`, `fullUrl`, `senderPid` (the same
---     arguments as passed to
---     [hs.urlevent.httpCallback](https://www.hammerspoon.org/docs/hs.urlevent.html#httpCallback)),
---     and must return a string that contains the URL to be opened. The
---     returned value will be URL-decoded according to the value of `skip-decode-url` (below).
---   * `pattern-replacement`: (String) a replacement pattern to apply if a
---     match is found when a decoder pattern (previous argument) is provided.
---     If a decoder function is given, this argument is ignored.
---   * `skip-decode-url`: (Boolean, optional) whether to skip URL-decoding of the
---     resulting string (defaults to `false`, by default URLs are always decoded)
---   * `source-application`: (String or Table, optional): a pattern or list of
---     patterns to match against the name of the application from which the URL
---     was opened. If this parameter is present, the decoder will only be
---     applied when the application matches. Default is to apply the decoder
---     regardless of the application.
--- If given as strings, `decoder-pattern-or-function` and `pattern-replacement`
--- are passed as arguments to
--- [string.gsub](https://www.lua.org/manual/5.3/manual.html#pdf-string.gsub)
--- applied on the original URL.
spoon.URLDispatcher.url_redir_decoders = {
    {
        "msteams",
        "^https://statics.teams.cdn.office.net(.*)?url=([^&]*)(.*)",
        "%2",
        false,
        nil
    },
}
print("Redir decoders")
print(hs.inspect(spoon.URLDispatcher.url_redir_decoders))

-- Requires the net.url package in ~/.hammerspoon
url = require "net.url"
-- we need to know this for url handling. Subtract 3600 so that it's not too soon after lua init
startTime = os.time() - 3600

function dropUrl(url)
    print("URLDispatcher: Dropping " .. url)
end
function openUrl(urlString)
    -- see https://github.com/golgote/neturl
    u = url.parse(urlString)
    print("URLDispatcher: Handling " .. u)
    shouldOpen = true
    now = os.time()

    -- kubectl oidc plugin (localhost:8000)
    if (u.host == 'localhost' and u.port == 8000) then
        if (os.date("*t", now).hour < 8) or (os.date("*t", now).hour > 20) then
            print('URLDispatcher: Out of working hours (' .. os.date("%H:%M", now) .. ')')
            shouldOpen = false
        else
            if (os.date("*t", now).wday == 1) or (os.date("*t", now).wday == 7) then
                print('URLDispatcher: Weekend')
                shouldOpen = false
            else
                if ((now - startTime) < 1800) then
                    print('URLDispatcher: Too soon (' .. (now - startTime) .. 's)')
                    shouldOpen = false
                else
                    startTime = now
                end
            end
        end
    end

    if shouldOpen then
    --if true then
        print("URLDispatcher: Opening")
        hs.urlevent.openURLWithBundle(urlString, spoon.URLDispatcher.default_handler)
    else
        print("URLDispatcher: Dropping")
    end

end

---  A table containing a list of dispatch rules. Rules are evaluated in the
---  order they are declared. Each rule is a table with the following structure:
---  `{ url-patterns, app-bundle-ID-or-function, function, app-patterns }`
---  * `url-patterns` can be: (a) a single pattern as a string, (b) a table
---    containing a list of strings, or (c) a string containing the path of a
---    file from which the patterns will be read (if the string contains a valid
---    filename it's used as a file, otherwise as a pattern). In case (c), a
---    watcher will be set to automatically re-read the contents of the file
---    when it changes. If a relative path is given (not starting with a "/"),
---    then it is considered to be relative to the Hammerspoon configuration
---    directory.
---  * If `app-bundle-ID-or-function` is specified as a string, it is
---    interpreted as a macOS application ID, and that application will be used
---    to open matching URLs. If it is a function pointer, or not given but
---    "function" is provided, it is expected to be a function that accepts a
---    single argument, and it will be called with the URL.
---  * If `app-patterns` is given, it should be a string or a table containing a
---    pattern/list of patterns, and the rule will only be evaluated if the URL
---    was opened from an application whose name matches one of those patterns.
---  * Note that the patterns are [Lua patterns](https://www.lua.org/pil/20.2.html)
---    and not regular expressions.
---  * Defaults to an empty table, which has the effect of having all URLs
---    dispatched to the `default_handler`.
spoon.URLDispatcher.url_patterns = {
    -- Example URL to always drop
    --{
    --    "^http://localhost:8000",
    --    nil,
    --    dropUrl,
    --    nil
    --},
    {
        ".*",
        nil,
        openUrl,
        nil
    },
}
print("URL patterns")
print(hs.inspect(spoon.URLDispatcher.url_patterns,'\n'))
spoon.URLDispatcher:start()
