.equ portb_addr,  0x25
.equ ddrb_addr,   0x24
.equ pinb_addr,   0x23

.equ portd_addr,  0x2b
.equ ddrd_addr,   0x2a
.equ pind_addr,   0x29

.equ tccr2a_addr, 0xb0
.equ tccr2b_addr, 0xb1
.equ ocr2b_addr,  0xb4

.equ ir_pin,      0
.equ switch_pin,  2
.equ led_pin,     4
.equ servo_pin,   3

.equ ir_mask,     1 << ir_pin
.equ switch_mask, 1 << switch_pin
.equ led_mask,    1 << led_pin
.equ servo_mask,  1 << servo_pin

.equ servo_0_deg,    64
.equ servo_180_deg,  180

.section .text
.global start
.global AutomaticBin

start:
    ldi r16, 0xFF
    out 0x3D, r16
    ldi r16, 0x08
    out 0x3E, r16

   lds r16, ddrb_addr
   andi r16, ~ir_mask
   sts ddrb_addr, r16

   lds r16, portb_addr
   ori r16, ir_mask
   sts portb_addr, r16

   lds r16, ddrd_addr
   andi r16, ~switch_mask
   sts ddrd_addr, r16

   lds r16, portd_addr
   ori r16, switch_mask
   sts portd_addr, r16

   lds r16, ddrd_addr
   ori r16, led_mask
   sts ddrd_addr, r16

   lds r16, portd_addr
   andi r16, ~led_mask
   sts portd_addr, r16

   lds r16, ddrd_addr
   ori r16, servo_mask
   sts ddrd_addr, r16

   ldi r16, (1 << 5) | (1 << 0)
   sts tccr2a_addr, r16

   ldi r16, (1 << 2)
   sts tccr2b_addr, r16

   ldi r16, servo_0_deg
   sts ocr2b_addr, r16

   rjmp main_loop

AutomaticBin:
   lds r16, pind_addr
   sbrs r16, switch_pin
   rjmp switch_off

   lds r16, pinb_addr
   sbrs r16, ir_pin
   rjmp ir_detected

no_detection:
   lds r16, portd_addr
   andi r16, ~led_mask
   sts portd_addr, r16

   ldi r16, servo_0_deg
   sts ocr2b_addr, r16

   rjmp do_delay

ir_detected:
   lds r16, portd_addr
   ori r16, led_mask
   sts portd_addr, r16

   ldi r16, servo_180_deg
   sts ocr2b_addr, r16

   rjmp do_delay

switch_off:
   lds r16, portd_addr
   andi r16, ~led_mask
   sts portd_addr, r16

   ldi r16, servo_0_deg
   sts ocr2b_addr, r16

   ldi r18, 100
sw_off_delay1:
   ldi r19, 200
sw_off_delay2:
   dec r19
   brne sw_off_delay2
   dec r18
   brne sw_off_delay1

   ret

do_delay:
   ldi r18, 200
delay1:
   ldi r19, 200
delay2:
   dec r19
   brne delay2
   dec r18
   brne delay1

   ret

main_loop:
   rcall AutomaticBin
   rjmp main_loop
