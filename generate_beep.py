import wave
import math
import struct

def generate_beep(filename, duration=0.1, freq=440.0, volume=0.5):
    sample_rate = 44100
    num_samples = int(duration * sample_rate)
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        # Add a small fade in and fade out to avoid clicks
        fade_len = int(sample_rate * 0.01)
        for i in range(num_samples):
            # Sine wave
            val = math.sin(2.0 * math.pi * freq * i / sample_rate)
            # Apply fade
            if i < fade_len:
                val *= (i / fade_len)
            elif i > num_samples - fade_len:
                val *= ((num_samples - i) / fade_len)
            
            value = int(volume * 32767.0 * val)
            wav.writeframesraw(struct.pack('<h', value))

if __name__ == "__main__":
    generate_beep('e:/AntiGravity_Projects/breath-timer/assets/audio/beep.wav')
