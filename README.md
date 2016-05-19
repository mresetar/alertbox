# AlertBox - NodeMCU MQTT enabled button

## Fork off SmartButton project

Please find SmartButton details [here](https://github.com/iboboc/smartbutton).

## Hardware details

For this project I have used [WeMos D1 mini](http://www.wemos.cc/Products/d1_mini.html) based board. 
Using D1 mini board original design (of SmartButton) are alleviated. 

TODO: Make a circuit scheme

## Software details

This project requires MQTT broker instance. You can use publicly available test instance like 
[test.mosquitto.org](http://test.mosquitto.org/) or you can host your own. 

For details about the topics in use look into [action.lua](action.lua), specifically mqttConfig object. 

## How it works

1. When red button is pressed circuit is waken up (reset)
1. After [init.lua](init.lua) is executed it enters into setup by executing [boot-alertbox.lua](boot-alertbox.lua)
1. At this point it should be connected to configured Wi-Fi, if not it opens Wi-Fi hotspot with name `AlertBox-[chipId]` 
    * If in setup mode connect to Wi-Fi hotspot and configure device via [http://192.168.1.1](http://192.168.1.1)
1. If is connected to configured Wi-Fi, [action.lua](action.lua) is executed.
    * MQTT connection is opened 
    * If successful, message will be posted to configured topic
    * Device shuts down
