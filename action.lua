GPIO_LED_SENT = 1

-- init mqtt client with keepalive timer 120sec
m = mqtt.Client(node.chipid(), 120, "", "")

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)

function pubFun(topic) 
	m:publish(topic,"{'message':'Button pressed'}", 0, 0, 
		function(client) 
			print("sent")
			blinkOn(100, 1)
			tmr.alarm(1, 3000, tmr.ALARM_SINGLE, 
				function() 
					print("Going for deep sleep")
					node.dsleep(0)
				end)
		end) 
end

-- this function is not really implemented so no output
m:on("connect", 
	function(client) 
		print("on connect")
	end)

m:on("offline", 
	function(client) 
		print ("offline") 
	end)

-- on publish message receive event
m:on("message", 
	function(client, topic, data) 
		print(topic .. ":" ) 
		if data ~= nil then
		print(data)
		end
	end)

-- for TLS: m:connect("192.168.11.118", secure-port, 1)
print("About to connect to MQTT server "..mqConfig.hostname.." on port "..mqConfig.port)
m:connect(mqConfig.hostname, mqConfig.port, 0, 
	function(client) 
		print("connected")
		-- wait half a sec.
		tmr.alarm(0, 500, tmr.ALARM_SINGLE, 
			function() 
				pubFun("/alert/"..node.chipid()) 
			end)
--		m:subscribe("/topic",0, 
--			function(client) 
--				print("subscribe success") 
--		end)
	end, 
	function(client, reason) 
		print("failed reason: "..reason) 
		wifi.sta.disconnect()
		wifi.sta.config("","")
		file.remove('customurl.txt')
end)