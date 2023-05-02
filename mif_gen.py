#!/usr/bin/env python3
from PIL import Image
from sys import argv, exit
from itertools import zip_longest, count
import struct


def convert_image_to_bw(image: Image.Image):
    # Convert every 4 bytes in the image
    # into a big-endian integer
    #
    # Every 4 bytes that are read are
    # structured in an RGBA, where each
    # channel takes up one byte of space
    pix_ints = struct.iter_unpack("!I", image.tobytes())

    # Convert to a bit string, where every bit
    # represents one pixel, and the pixel is active
    # only if it is non-zero
    return "".join("0" if pix == 0 else "1" for pix, *_ in pix_ints)


def convert_image_to_color(image: Image.Image) -> Image.Image:
    return image.tobytes()


def group_into_ns(data, n=12):
    return (data[i : i + 8] for i in range(0, len(data), 8))


def write_mif(file, bit_strings, names=None):
    file.write("% GENERATED CONTENT %")
    file.write("Depth = 512;\n")
    file.write("Width = 12;\n")
    file.write("Address_radix = dec;\n")
    file.write("Data_radix = bin;\n")
    file.write("Content Begin\n")

    addr = 0
    for bit_string, name in zip_longest(
        bit_strings,
        names if names else [],
    ):
        file.write("\n")
        if name:
            file.write(f"% Data for '{name}' %")
        for eight_bits in group_into_ns(bit_strings, n=12):
            file.write(f"{addr:08d} : {eight_bits};")

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
    color = convert_image_to_color(image)
    print(color.getbands())
