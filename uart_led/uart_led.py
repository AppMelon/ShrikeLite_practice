from machine import UART, Pin
import shrike
import time

shrike.reset()
shrike.flash("uart_led	.bin")
# Initialize UART0 (TX=GPIO0, RX=GPIO1)
uart = UART(0, baudrate=115200, tx=Pin(0), rx=Pin(1))

def send_value(value):
    # Send raw byte over UART
    uart.write(bytes([value]))
    
    # Print info
    #print("Sent (hex): 0x{:02X}".format(value))
    #print("Sent (bin): {:08b}".format(value))
    bits = [(value >> i) & 1 for i in range(7, -1, -1)]
    #print("Bits sent:", bits)

while True:
    cmd = input("Type 'on' or 'off': ").strip().lower()
    
    if cmd == "on":
        send_value(0x61)
        print ("LED on")
    elif cmd == "off":
        send_value(0x62)
        print ("LED off")
    else:
        print("Invalid input, type 'on' or 'off'")
    
    time.sleep(0.2)
