#!/usr/bin/env python3
from PIL import Image
from sys import argv, exit
from itertools import zip_longest, count
from pathlib import Path

def convert_image_to_bin_strings(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    print(f"Channels: {image.getbands()}")

    width, height = image.size
    data = []
    for row in range(height):
        for col in range(width):
            r, g, b, a = image.getpixel((col, row))
            data.append(f'{1 if a else 0}{r>>4:04b}{g>>4:04b}{b>>4:04b}')

    return data

# 001 000

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
        print("Expected a path to an image as a first argument")
        exit(1)
    
    try:
        output_path = Path(argv[2])
        if not output_path.is_file():
            raise IndexError()
    except IndexError:
        print("Expected the second argument to be an path to the output file (a .mif file)")
        exit(2)

    # Convert image into binary,
    # split the binary into lines of 8 bits,
    # and then print the lines
    bin_strings = convert_image_to_bin_strings(image)
    with open(output_path, "w") as file:
        write_bin_strings(file, bin_strings)
    print("Done!")
