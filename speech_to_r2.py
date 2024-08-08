# pip install SpeechRecognition
# pip install pyAudio

import speech_recognition as sr
import subprocess

recognizer = sr.Recognizer()

def execute_command(command):
    # Use subprocess to call R script or command
    subprocess.call(["Rscript", "-e", command])

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

while True:
    captured_text = listen_and_recognize()
    if captured_text:
        if captured_text.lower() == "stop listening":
            print("Stopping listening.")
            break
        execute_command(f'cat("{captured_text}")')

captured_text
