import speech_recognition as sr
import subprocess
from pynput import keyboard

recognizer = sr.Recognizer()
stop_listening = False

#print("Listening...")

def listen_and_recognize():
    with sr.Microphone() as source:
        recognizer.adjust_for_ambient_noise(source)
        print("Listening...")
        try:
            audio = recognizer.listen(source)
            command = recognizer.recognize_google(audio)
            print(f"Recognized: {command}")
            return command
        except sr.UnknownValueError:
            print("Could not understand audio")
            return None
        except sr.RequestError as e:
            print(f"Could not request results; {e}")
            return None

def on_press(key):
    global stop_listening
    try:
        if key.char == 'q':
            stop_listening = True
            return False  # Stop listener
    except AttributeError:
        pass

listener = keyboard.Listener(on_press=on_press)
listener.start()

out = ""

while True:
    if stop_listening:
        print("Stopping listening due to key press.")
        break
    captured_text = listen_and_recognize()
    if captured_text:
        if captured_text.lower() == "stop listening":
            print("Stopping listening.")
            break
        else:
          print(captured_text)
          out = out + "\n" + captured_text

listener.join()

out = captured_text
out
