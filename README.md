# ADoSnipsLights

Snips.ai skill for controlling lights written in Julia;
to be used together with the framework SnipsHermesQnD.


Lights are defined in the ```config.ini``` as lines like:
```
bulb1=livingroom,Stehlampe,shellybulb,192.168.1.101
```
where
* `bulb1` is a unique id of the device
* `livingroom` is the siteId of the room with the device. It must
  match the siteId of the respective Snips satelite and the value
  of the slot, returned as room by the intent `ADoSnipsOnOffDE`
* `floor_lamp` must match the value of the slot, returned as device
  by the intent `ADoSnipsOnOffDE` in must be unique
  in combination with siteId.
* `shellybulb` is the driver technology used to control the device.
   Currently ```shellybulb``` (and ```GPIO``` not yet) are supported.
* `192.168.1.101` all following parameters depend on the driver
  (IP-address for shellybulb, GPIO-ID for GPIO)

For the moment, only German and English are supported.

# Installation

For more details and installation of the framework look
in the documentation of the
[ADoSnipsQnD-framework](https://andreasdominik.github.io/ADoSnipsQnD/dev)
