customurl = '127.0.0.1:1234'
customhost, customport = customurl:match('^([^:]+):(%d+)')
print (customhost..customport)