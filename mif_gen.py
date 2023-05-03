#!/usr/bin/env python3
from PIL import Image
from sys import argv, exit
from itertools import zip_longest, count
import struct

def convert_image_to_bin_strings(image: Image.Image) -> Image.Image:
    data = image.getdata()
    print(f"Channels: {image.getbands()}")
    return [f'{r>>4:04b}{g>>4:04b}{b>>4:04b}{1 if a else 0}' for r, g, b, a in data]


def group_into_ns(data, n=12):
    return (data[i : i + n] for i in range(0, len(data), n))


def write_bin_strings(file, bit_strings):
    file.write("% GENERATED CONTENT %\n")
    file.write("Depth = 512;\n")
    file.write("Width = 13;\n")
    file.write("Address_radix = dec;\n")
    file.write("Data_radix = bin;\n")
    file.write("Content Begin\n")

    for i, bit_string in enumerate(bit_strings):
        file.write(f"{i:08d} : {bit_string};\n")
        

    file.write("END;")


if __name__ == "__main__":
    image: Image.Image
    try:
        image = Image.open(argv[1])
    except IndexError:
        print("Expected a file as a second argument")
        exit(1)

    # Convert image into binary,
    # split the binary into lines of 8 bits,
    # and then print the lines
    bin_strings = convert_image_to_bin_strings(image)
    with open("modelsim/bird_rom.mif", "w") as file:
        write_bin_strings(file, bin_strings)
    print("Done!")
