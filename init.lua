-- init.lua

fileToExecute = "boot-alertbox.lua"
l = file.list()
fileFound = false
for k,v in pairs(l) do
	if k == fileToExecute then
		fileFound = true
		print("*** You've got 4 sec to stop timer 0 ***")
		tmr.alarm(0, 4000, tmr.ALARM_SINGLE, function()
			print("Executing "..fileToExecute)
			dofile(fileToExecute)
		end)
	else 
	end
end
if not fileFound then 
	print("File to execute not found: "..fileToExecute)
end