mqttConfig = mqttConfig or {}
--node = node or { chipid = function() return 1234 end}
-- add some client config for troubleshooting 
---[[
mqttConfig.client = {}
mqttConfig.client.chipid = node.chipid()
--Get current Station configuration
mqttConfig.client.ssid, _pass_, mqttConfig.client.bssid_set, mqttConfig.client.bssid = wifi.sta.getconfig()
mqttConfig.client.ip, _nm_, _gw_ = wifi.sta.getip()
--]]
mqttConfig.keepalive = 10
mqttConfig.username = ''
mqttConfig.password = ''
mqttConfig.qos = 2
mqttConfig.retain = 0
mqttConfig.useSsl = 0
mqttConfig.rootTopic = 'mresetar/alertbox/'..mqttConfig.client.chipid
mqttConfig.lwtTopic = mqttConfig.rootTopic..'/lwt'
mqttConfig.topic = mqttConfig.rootTopic..'/alert'

-- serialize mqttConfig as JSON
function toJson(tableObject)
	serializedOk, serializedString = pcall(cjson.encode, tableObject)
	if serializedOk then
	  print('Serialized message'..serializedString)
	end
	return serializedString
end

-- init mqtt client
m = mqtt.Client(node.chipid(), mqttConfig.keepalive, mqttConfig.username, mqttConfig.password)
-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt(mqttConfig.lwtTopic, toJson(mqttConfig), 0, 0)

local count = 0
local messageSent = false
function publish(topic, message, qos, retain) 
	m:publish(topic, message, qos, retain, 
		function(client) 
			print("MQTT message has been sent"..message)
			blinkOn(100, 1)
			messageSent = true
			m:close()
			print("Going for deep sleep in 3 sec.")
			tmr.alarm(1, 3000, tmr.ALARM_SINGLE, function() node.dsleep(0) end)
		end) 
end

function connectToMqtt() 
	m:connect(mqttConfig.hostname, mqttConfig.port, mqttConfig.useSsl, 0,
		function(client) 
			print("Connected")
			-- wait half a sec.
	--		tmr.alarm(0, 500, tmr.ALARM_SINGLE, 
	--			function()
					message = {}
					message.pushes = mqttConfig.pushes
					publish(mqttConfig.topic, toJson(message), mqttConfig.qos, mqttConfig.retain) 
	--			end)
	--[[
				m:subscribe("/topic",0, 
				function(client) 
					print("subscribe success") 
			end)
	--]]
		end, 
		function(client, reason) 
			print("Failed with reason: "..reason) 
			wifi.sta.disconnect()
			wifi.sta.config("","")
			file.remove('customurl.txt')
			node.dsleep(0)
	end)
end

-- this function is not really implemented so no output
m:on("connect", 
	function(client) 
		print("On connect.")
	end)

m:on("offline", 
	function(client)
		if not messageSent then
			if count < 10 then
	  		print ("(" .. count .. ") MQTT reconnect.")
				tmr.alarm(1, 1000, 0, function() connectToMqtt() end)
			else 
				switchToOtaMode()
			end
			count = count + 1
		else
			print ("Message sent. Going offline")
		end
	end)

-- on message receive event
--[[
m:on("message", 
	function(client, topic, data) 
		print(topic .. ":" ) 
		if data ~= nil then
		print(data)
		end
	end)
--]]

print("About to connect to MQTT server "..mqttConfig.hostname.." on port "..mqttConfig.port)
connectToMqtt()