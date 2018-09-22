import time
import paho.mqtt.client as mqtt
from random import randint

mqttc=mqtt.Client()
mqttc.connect("127.0.0.1",1883,60)
mqttc.loop_start()

while 1:
    t = randint(1,100)
    (result,mid)=mqttc.publish("SURS1/Data",t,2)
    time.sleep(1)

#mqttc.loop_stop()
#mqttc.disconnect()

