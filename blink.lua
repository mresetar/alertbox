function blinkOn(delay, pin)
	local lighton=1
	gpio.write(pin, gpio.HIGH)
	tmr.unregister(3)
	tmr.alarm(3, delay, tmr.ALARM_AUTO, function()
			if lighton==0 then
					lighton=1
					gpio.write(pin, gpio.HIGH)
			else
					lighton=0
					gpio.write(pin, gpio.LOW)
			end
	end)
end

function blinkOff(pin)
	gpio.write(pin, gpio.LOW)
	tmr.unregister(3)
end
