from icecream import ic


def note2midi(s):
    s = s.lower()
    notes = ["c", "c#", "d", "d#", "e", "f", "f#", "g", "g#", "a", "a#", "b"]
    octave = int(s[-1])
    note_name = s[:-1]
    for i, v in enumerate(notes):
        if v == note_name:
            return i + octave * 12
    return -1


assert note2midi("C4") == 48
assert note2midi("C#5") == 61


with open("chords.txt", "r") as f:
    for line in f:
        note_list = []
        notes = line.split()
        for _, note in enumerate(notes):
            note_num = note2midi(note)
            note_list.append(note_num)
        while len(note_list) < 11:
            note_list.append(0)
        print(note_list)
