import random
import time

OPERAND_WIDTH = 512

N_BYTES = int(OPERAND_WIDTH/8)

# Get user choice
choice = input("Enter operation (x for addition, y for comparison, e for equal test): ")

# Generate mode bytes
if choice == 'x':
    mode_bytes = bytearray([0xFF] * N_BYTES)
elif choice == 'y':
    mode_bytes = bytearray([0x00] * N_BYTES)
elif choice == 'e':
    mode_bytes = bytearray([0x00] * N_BYTES)  # Use comparison mode
else:
    print("Invalid choice!")
    exit()

A = random.randrange(2**(OPERAND_WIDTH-1), 2**OPERAND_WIDTH-1)

# For equal test, make B the same as A
if choice == 'e':
    B = A
else:
    B = random.randrange(2**(OPERAND_WIDTH-1), 2**OPERAND_WIDTH-1)

if choice == 'x':
    res = A + B
    print("A     = ", hex(A))
    print("B     = ", hex(B))
    print("A + B = ", hex(res))
elif choice == 'y':
    res = 1 if A == B else 0
    print("A     = ", hex(A))
    print("B     = ", hex(B))
    print("A == B:", A == B)
else:  # choice == 'E'
    res = 1  # Should always be 1 for equal test
    print("EQUAL TEST: Sending the same value twice")
    print("A     = ", hex(A))
    print("B     = ", hex(B))
    print("A == B: True (Expected result: 1)")

# FIX: Add proper padding to ensure exactly 64 bytes
A_bytes = bytearray.fromhex(format(A, '0128x'))  # 128 hex digits = 64 bytes
B_bytes = bytearray.fromhex(format(B, '0128x'))  # 128 hex digits = 64 bytes

import serial
ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=10)

# Send mode bytes
for mode_byte in mode_bytes:
    hex_byte = ("{0:02x}".format(mode_byte))
    ser.write(bytearray.fromhex(hex_byte))
    time.sleep(0.001)

for op_byte in A_bytes:
    hex_byte = ("{0:02x}".format(op_byte))
    ser.write(bytearray.fromhex(hex_byte))
    time.sleep(0.001)

for op_byte in B_bytes:
    hex_byte = ("{0:02x}".format(op_byte))
    ser.write(bytearray.fromhex(hex_byte))
    time.sleep(0.001)

res_rcvd = ser.read(N_BYTES+1)

res2 = int.from_bytes(res_rcvd, "big")

if res2==res:
    print("Result received correctly!")
    print("Expected   = ", hex(res))
    print("Received   = ", hex(res2))
else:
    print("Result INCORRECT!")
    print("Expected   = ", hex(res))
    print("Received   = ", hex(res2))