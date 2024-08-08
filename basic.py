import ctypes
import sounddevice as sd
import numpy as np

# Manually load the PortAudio library
ctypes.cdll.LoadLibrary('/opt/homebrew/lib/libportaudio.dylib')

def callback(indata, frames, time, status):
    print(indata.shape)

try:
    with sd.InputStream(callback=callback):
        sd.sleep(5000)  # Record for 5 seconds
except Exception as e:
    print(f"Error: {e}")
