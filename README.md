# ADoSnipsLights

Snips.ai skill for controlling lights written in Julia;
to be used together with the framework SnipsHermesQnD.

### Update:
NLU (natural language understanding) definition files are added for
English and German and make it possible to use the skill with
Susi (Susi is no Snips) without Snips or the Snips console!

### Configuration
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
and [Susi](https://github.com/andreasdominik/Susi).

### Install skill for Susi
* Change to the root skills directory (default `/opt/Susi/Skills`)
* clone this repo
* copy the 'config.ini.template' to 'config.ini' and
  edit the file to configure your lights.

```
cd /opt/Susi/Skills
git clone https://github.com/andreasdominik/ADoSnipsLights.git
cd ADoSnipsLights
cp config.ini.template config.ini
```
