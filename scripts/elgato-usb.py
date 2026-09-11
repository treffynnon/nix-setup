"""Control an Elgato Key Light Neo over USB.

The Neo only serves the well known Elgato HTTP API when it runs in Wi-Fi mode,
and Wi-Fi mode needs a mains supply of at least 3A. Plugged into a Mac or a
dock it has no IP address at all and is a USB HID device instead, carrying the
same GET and PUT commands inside 512 byte frames.

Protocol reverse engineered by Zameer Manji:
https://zameermanji.com/blog/2026/3/4/elgato-key-light-neo-usb-protocol/
"""

import json
import sys

import hid

VENDOR_ID = 0x0FD9
PRODUCT_ID = 0x00A0

# A frame is a 6 byte header, the body, a terminator byte, then zero padding.
FRAME_SIZE = 512
BODY_SIZE = 505
READ_TIMEOUT_MS = 200

COMMANDS = {
    "get": "GET /elgato/lights",
    "on": 'PUT /elgato/lights {"lights":[{"on":1}]}',
    "off": 'PUT /elgato/lights {"lights":[{"on":0}]}',
}


def build_frames(payload):
    """Split a command into the 512 byte frames the light expects."""
    starts = range(0, len(payload), BODY_SIZE)
    chunks = [payload[at:at + BODY_SIZE] for at in starts] or [b""]
    total = len(chunks)
    frames = []
    for index, chunk in enumerate(chunks):
        length = len(chunk).to_bytes(2, "little")
        header = bytes([0x02, index, total, 0x03, *length])
        frames.append((header + chunk + b"\x03").ljust(FRAME_SIZE, b"\x00"))
    return frames


def read_reply(device):
    """Reassemble a reply, which arrives as one or more numbered frames."""
    chunks = {}
    total = 0
    while True:
        raw = device.read(FRAME_SIZE, READ_TIMEOUT_MS)
        if not raw:
            break
        index = raw[1]
        total = total or raw[2]
        length = int.from_bytes(raw[4:6], "little")
        chunks.setdefault(index, bytes(raw[6:6 + length]))
        if total and len(chunks) >= total:
            break
    return b"".join(chunks[index] for index in sorted(chunks))


def request(payload):
    device = hid.device()
    device.open(VENDOR_ID, PRODUCT_ID)
    try:
        for frame in build_frames(payload):
            # hidapi expects a leading report number byte
            device.write(b"\x00" + frame)
        return read_reply(device)
    finally:
        device.close()


def main():
    argument = sys.argv[1] if len(sys.argv) > 1 else ""
    command = COMMANDS.get(argument)
    if command is None:
        usage = "|".join(COMMANDS)
        print(f"usage: elgato-usb {usage}", file=sys.stderr)
        return 2

    try:
        reply = request(command.encode("utf-8")).decode("utf-8")
        # Parse before printing, so a truncated reply fails here rather than
        # being passed on to the caller as if it were a state.
        json.loads(reply)
    except (OSError, ValueError) as error:
        print(f"key light unreachable over USB: {error}", file=sys.stderr)
        return 1

    print(reply)
    return 0


if __name__ == "__main__":
    sys.exit(main())
