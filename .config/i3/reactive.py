import colorsys
from random import random

from openrazer.client import DeviceManager
from pynput import mouse

openrazer_device_manager = DeviceManager()

for device in openrazer_device_manager.devices:
    if device.type == "mousemat":
        firefly = device
        break
else:
    raise Exception("Could not find firefly!")


def react(x, y, button, down):
    print(x, y, button, down)

    # Don't change color on button release
    if down:
        firefly.fx.reactive(0, 255, 0, 1)
    firefly.trigger_reactive()


while True:
    try:
        with mouse.Listener(
                on_click=react) as mouse_listener:
            mouse_listener.join()
    except Exception as e:
        print(e)
