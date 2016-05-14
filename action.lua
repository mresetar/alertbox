mqttConfig = mqttConfig or {}
mqttConfig.chipid = node.chipid()
mqttConfig.keepalive = 10
mqttConfig.username = ''
mqttConfig.password = ''
mqttConfig.qos = 2
mqttConfig.retain = 0
mqttConfig.useSsl = 0
mqttConfig.rootTopic = 'mresetar/alertbox/'..node.chipid()
mqttConfig.lwtTopic = mqttConfig.rootTopic..'/lwt'
mqttConfig.topic = mqttConfig.rootTopic..'/alert'

-- serialize mqttConfig as JSON
ok, mqttJson = pcall(cjson.encode, mqttConfig)
if ok then
  print('Serialized message'..mqttJson)
else
  print("Failed to encode!")
  node.dsleep(0)
end

-- init mqtt client
m = mqtt.Client(node.chipid(), mqttConfig.keepalive, mqttConfig.username, mqttConfig.password)
-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt(mqttConfig.lwtTopic, mqttJson, 0, 0)

function publish(topic, message, qos, retain) 
	m:publish(topic, message, qos, retain, 
		function(client) 
			print("MQTT message has been sent"..mqttJson)
			blinkOn(100, 1)
			print("Going for deep sleep in 3 sec.")
			tmr.alarm(1, 3000, tmr.ALARM_SINGLE, function() node.dsleep(0) end)
		end) 
end

-- this function is not really implemented so no output
m:on("connect", 
	function(client) 
		print("On connect.")
	end)

m:on("offline", 
	function(client) 
		print ("Went offline message.") 
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
m:connect(mqttConfig.hostname, mqttConfig.port, mqttConfig.useSsl, 
	function(client) 
		print("Connected")
		-- wait half a sec.
		tmr.alarm(0, 500, tmr.ALARM_SINGLE, 
			function() 
				publish(mqttConfig.topic, mqttJson, mqttConfig.qos, mqttConfig.retain) 
			end)
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