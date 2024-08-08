# pip install SpeechRecognition
# pip install pyAudio

import speech_recognition as sr
import subprocess
import time

recognizer = sr.Recognizer()

def listen_and_recognize():
    with sr.Microphone() as source:
        recognizer.adjust_for_ambient_noise(source)
        try:
            audio = recognizer.listen(source) #, timeout = 5, phrase_time_limit = 5)
            command = recognizer.recognize_google(audio, language="en-US")
            #print(f"Recognized: {command}")
            return command
        except sr.UnknownValueError:
            #print("Could not understand audio")
            return None
        except sr.RequestError as e:
            print(f"Could not request results; {e}")
            return None
        except sr.WaitTimeoutError:
            return "stop listening"
        
inactivity_timeout = 3
out = ""
while True:
    captured_text = listen_and_recognize()
    if captured_text:
        last_activity_time = time.time()
        if captured_text.lower() == "stop listening":
            #print("Stopping listening.")
            break
        else:
          print(captured_text)
          out = out + "\n" + captured_text
    if time.time() - last_activity_time > inactivity_timeout:
        #print("Stopping listening due to inactivity timeout.")
        break
        
out
