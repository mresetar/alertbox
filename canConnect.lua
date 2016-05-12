
function canConnect(ipAddress, port, callback)
	conn = net.createConnection(net.TCP, false)
	conn:on("receive", callback )
	conn:connect(port, ipAddress)
	local ok, err = conn:send("state\n")
	conn:close()	
end

cannConnect = function(sck, c) connectionSuccess = true end
canConnect('8.8.8.8', 80)
