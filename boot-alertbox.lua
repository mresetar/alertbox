--variable for connecting retries
dofile('blink.lua')
cnt = 0

mqttConfig = {
  hostname = nil,
  port = nil
}

print("Starting AlertBox")

--simple function to check for a file and content
function file_exists(name)
  fileresult=file.open(name,"r")
  if fileresult~=nil then file.close(fileresult) return true else return false end
end

function switchToOtaMode()
  blinkOn(1000, 1)
  wifi.sta.disconnect()
  wifi.sta.config("","")
  dofile("setwifi.lua")
end

function writePushes(pushes)
  file.remove("pushes.txt")
  tmr.delay(1000)
  file.open("pushes.txt", "w")
  file.write(pushes)
  file.flush()
  file.close()  
end

blinkOn(200, 1)
-- count the button pushes and store in a local txt file
if file_exists("pushes.txt") then 
  file.open("pushes.txt", "r")
  psh = file.readline()
  file.close()
  psh = psh+1
  print("Button has been pushed "..psh.." times.")
else
  print("Button has been pushed for the first time.")
  psh = 1
end

-- write new value for pushes
writePushes(psh)
mqttConfig.pushes = psh
-- if customurl file is set (exists) then we load the url
if file_exists("customurl.txt") then 
  print("Custom URL")
  file.open("customurl.txt", "r")
  customurl = file.readline()
  file.close()
  mqttConfig.hostname, mqttConfig.port = customurl:match('^([^:]+):(%d+)')
  print("Will use server: "..mqttConfig.hostname..':'..mqttConfig.port)
  -- try to connect to Wi-Fi ten times
  -- if dont get a valid IP go to Wi-Fi set up
  -- else do main stuff
  tmr.alarm(1, 1000, 1, 
    function()
      if wifi.sta.getip()== nil then
          cnt = cnt + 1
          print("(" .. cnt .. ") Waiting for IP...")
          if cnt == 10 then
            tmr.unregister(1)
            switchToOtaMode()   
          end
      else
          tmr.unregister(1)
          print("Connected to Wifi")
          print(wifi.sta.getip())
          dofile("action.lua")
      end
    end)  
  -- if custom url is not defined, then reset all Wi-Fi information and change to OTA config mode
else
  switchToOtaMode()
end
