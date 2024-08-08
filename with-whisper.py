import ctypes
import whisper
import sounddevice as sd
import numpy as np
import queue
import threading
import keyboard

# Manually load the PortAudio library
ctypes.cdll.LoadLibrary('/opt/homebrew/lib/libportaudio.dylib')
ctypes.cdll.LoadLibrary('/opt/homebrew/lib/libz.1.dylib')

# Load the Whisper model
model = whisper.load_model("base")

q = queue.Queue()

def callback(indata, frames, time, status):
    q.put(indata.copy())

def recognize_speech():
    print("Start speaking...")
    rec = sd.InputStream(callback=callback)
    rec.start()
    audio_data = []
    while not stop_listening_event.is_set():
        audio_data.append(q.get())
    rec.stop()
    audio_array = np.concatenate(audio_data, axis=0)
    result = model.transcribe(audio_array, fp16=False)  # Using fp16=False for compatibility
    print(f"Recognized text: {result['text']}")
    execute_command(result['text'])

def execute_command(command):
    print(f'Executing: foo("{command}")')
    # Replace the following line with your command execution logic
    # os.system(f'Rscript -e \'foo("{command}")\'')  # for R
    # os.system(f'code --command "{command}"')  # for VS Code (example)

stop_listening_event = threading.Event()

def start_listening():
    stop_listening_event.clear()
    recognize_thread = threading.Thread(target=recognize_speech)
    recognize_thread.start()

def stop_listening():
    stop_listening_event.set()

keyboard.add_hotkey('ctrl+shift+s', start_listening)
keyboard.add_hotkey('ctrl+shift+e', stop_listening)

print("Press Ctrl+Shift+S to start listening, Ctrl+Shift+E to stop listening.")
keyboard.wait('esc')
