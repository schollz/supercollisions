#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "python-osc",
# ]
# ///
import os
import random
import math
import time
from pythonosc import osc_message_builder
from pythonosc import udp_client


def send_sampler_osc(
    filename,
    host="127.0.0.1",
    port=57121,
    volume_db=0.0,
    rate=1.0,
    pitch=0.0,
    xfade=0.01,
    bpm_source=120.0,
    bpm_target=120.0,
    retrig_num_total=0.0,
    retrig_rate_change_beats=1.0,
    retrig_rate_start=1.0,
    retrig_rate_end=0.0,
    retrig_pitch_change=0.0,
    retrig_volume_change=0.0,
    slice_attack_beats=0.001,
    slice_duration_beats=1.0,
    slice_release_beats=0.001,
    slice_num=0.0,
    slice_count=32.0,
    effect_dry=1.0,
    effect_comb=0.0,
    effect_delay=0.0,
    effect_reverb=0.0,
):
    try:
        # Create OSC client
        client = udp_client.SimpleUDPClient(host, port)

        # Generate absolute path for the filename
        filename = os.path.abspath(filename)

        # Send OSC message with all parameters in the correct order
        # Based on the SuperCollider code, the message format is:
        # [address, sender_info, timestamp, filename, volumeDB, rate, pitch, xfade, ...]
        client.send_message(
            "/sampler",
            [
                filename,  # msg[3]
                volume_db,  # msg[4]
                rate,  # msg[5]
                pitch,  # msg[6]
                xfade,  # msg[7]
                bpm_source,  # msg[8]
                bpm_target,  # msg[9]
                retrig_num_total,  # msg[10]
                retrig_rate_change_beats,  # msg[11]
                retrig_rate_start,  # msg[12]
                retrig_rate_end,  # msg[13]
                retrig_pitch_change,  # msg[14]
                retrig_volume_change,  # msg[15]
                slice_attack_beats,  # msg[16]
                slice_duration_beats,  # msg[17]
                slice_release_beats,  # msg[18]
                slice_num,  # msg[19]
                slice_count,  # msg[20]
                effect_dry,  # msg[21]
                effect_comb,  # msg[22]
                effect_delay,  # msg[23]
                effect_reverb,  # msg[24]
            ],
        )

        print(f"OSC message sent to {host}:{port} with filename: {filename}")
        return True

    except Exception as e:
        print(f"Error sending OSC message: {e}")
        return False


# Example usage:
if __name__ == "__main__":

    # Advanced usage with custom parameters
    bpm_target = 180
    slice_num = 16
    # create a set defined permutation
    for i in range(900):
        if (i % 32) == 0:
            slice_permutation = random.sample(list(range(1, 17)), k=16)
            slice_permutation = list(range(1, 17))
            # slice_permutation = slice_permutation[:4]

        retrigger_num_total = 0.0
        retrig_rate_start = 0.0
        retrigger_rate_end = 0.0
        beat_duration = 60 / bpm_target / 2
        retrig_volume_change = 0
        retrig_pitch_change = 0
        volume_db = 0
        effect_comb = 0
        effect_reverb = 0
        slice = i % 16
        if random.randint(1, 8) < 2:
            retrigger_num_total = random.randint(1, 64)
            retrig_rate_start = random.randint(1, 16) / 4
            retrigger_rate_end = retrig_rate_start
            if random.randint(1, 8) < 2:
                retrigger_rate_end = retrig_rate_start * random.randint(1, 5)
            retrig_volume_change = random.choice([-2, 1, 0, 0, 0, 1, 2])
            retrig_pitch_change = random.choice([-2, -1, -1, 0, 0, 0, 0, 0, 1, 1, 2])
            if retrig_volume_change > 0:
                volume_db = retrigger_num_total * -1 * retrig_volume_change / 8

            beat_duration = beat_duration * random.choice([1, 2, 4, 8, 16])

        if random.randint(1, 8) < 4:
            slice = random.randint(0, slice_num - 1)

        if random.randint(1, 8) < 2:
            effect_comb = 1.0
            print("COMB")
        if random.randint(1, 8) < 2:
            effect_reverb = 1.0
            print("REVERB")
        send_sampler_osc(
            filename="/home/zns/Documents/supercollisions/amen_0efedaab_beats8_bpm165.flac",
            volume_db=volume_db,
            bpm_source=165,
            bpm_target=bpm_target,
            slice_num=slice,
            slice_count=slice_num,
            retrig_num_total=retrigger_num_total,
            retrig_rate_start=retrig_rate_start,
            retrig_rate_end=retrigger_rate_end,
            retrig_volume_change=retrig_volume_change,
            retrig_pitch_change=retrig_pitch_change,
            effect_comb=effect_comb,
            effect_reverb=effect_reverb,
            slice_duration_beats=8,
        )
        time.sleep(beat_duration)
