from machine import UART, Pin
import shrike
import time

shrike.reset()
shrike.flash("pwm_uart.bin")

uart = UART(0, baudrate=115200, tx=Pin(0), rx=Pin(1))

def flip_bits(num):
    if num == 0:
        return 0
    a = []
    for i in range(8):
        a.append(num%2)
        num //= 2
    ans = 0
    for i in range(8):
        ans *= 2
        if a[i]==1:
            ans += 1
    return ans

def send_value(value):
    # Send raw byte over UART
    
    uart.write(bytes([flip_bits(value)]))
    
    # Print info
    #print("Sent (hex): 0x{:02X}".format(value))
    #print("Sent (bin): {:08b}".format(value))
    bits = [(value >> i) & 1 for i in range(7, -1, -1)]
    #print("Bits sent:", bits)

while True:
    cmd = int(input("brightness (0-255): "))
    send_value(cmd)
    time.sleep(0.2)