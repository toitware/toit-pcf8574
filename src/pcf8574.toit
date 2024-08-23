// Copyright (C) 2021 Alfred Stier <xal@quantentunnel.de>. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import binary show BIG-ENDIAN
import serial
import i2c
import gpio

/**
Toit driver for the PCF8574 i2c I/O port expander.

The PCF8574 is bidirectional, and uses open-drain outputs. That is, it pulls
  the output low, but does not drive it high. To drive the output high, a pull-up
  resistor is required.
*/

class PCF8574:
  /** The default I2C address base for the PCF8574 with jumper setting A2, A1, A0. */
  static I2C-ADDRESS ::= 0x20
  static I2C-ADDRESS-000 ::= 0x20
  static I2C-ADDRESS-001 ::= 0x21
  static I2C-ADDRESS-010 ::= 0x22
  static I2C-ADDRESS-011 ::= 0x23
  static I2C-ADDRESS-100 ::= 0x24
  static I2C-ADDRESS-101 ::= 0x25
  static I2C-ADDRESS-110 ::= 0x26
  static I2C-ADDRESS-111 ::= 0x27

  /** The I2C address base for the PCF8574A with jumper setting A2, A1, A0. */
  static I2C-ADDRESS-A ::= 0x38
  static I2C-ADDRESS-A-000 ::= 0x38
  static I2C-ADDRESS-A-001 ::= 0x39
  static I2C-ADDRESS-A-010 ::= 0x3A
  static I2C-ADDRESS-A-011 ::= 0x3B
  static I2C-ADDRESS-A-100 ::= 0x3C
  static I2C-ADDRESS-A-101 ::= 0x3D
  static I2C-ADDRESS-A-110 ::= 0x3E
  static I2C-ADDRESS-A-111 ::= 0x3F

  device_/i2c.Device
  /**
  At power on the pins are all high.
  We can't guarantee that the device is in a known state, but there isn't much
    we can do about it.
  */
  state_/int := 0b11111111

  constructor .device_:

  /**
  Reads the current state of the expander pins.
  Returns a list of 8 values, where each value is either 0 or 1.

  Reads the state of the expander pins. Setting all pins to high (using $set)
    will not automatically result in a list of 1s. The expander is open-drain,
    so something would need to pull the pins high. However, if a pin is set
    to low, then that pin will read as low.
  */
  read -> List:
    // No filter, alway returns an array with 8 elements.
    bytes := device_.read 1

    result := List 8
    state := bytes[0]
    8.repeat:
      result[it] = state & 1
      state >>= 1
    return result

  /** Sets all expander pins to 1. */
  set:
    set --mask=0b11111111

  /**
  Sets the given $pin to 1.
  Other pins remain unaffected.
  */
  set --pin/int:
    if not 0 <= pin < 8: throw "INVALID_PIN"
    set --mask=(1 << pin)

  /**
  Sets the pins identified by the given $mask to 1.
  Other pins remain unaffected.
  */
  set --mask/int:
    if not 0 <= mask <= 0xFF: throw "INVALID_MASK"
    state_ |= mask
    device_.write #[state_]

  /** Clears all expander pins, setting them to 0. */
  clear:
    clear --mask=0b11111111

  /**
  Clears the given $pin, setting it to 1.
  Other pins remain unaffected.
  */
  clear --pin/int:
    if not 0 <= pin < 8: throw "INVALID_PIN"
    clear --mask=(1 << pin)

  /**
  Clears the pins identified by the given $mask, setting them to 0.
  Other pins remain unaffected.
  */
  clear --mask/int:
    if not 0 <= mask <= 0xFF: throw "INVALID_MASK"
    state_ &= ~mask
    device_.write #[state_]

  /**
  Toggles all expander pins.
  If a pin is 0, it becomes 1.
  If a pin is 1, it becomes 0.
  */
  toggle:
    toggle --mask=0b11111111

  /**
  Toggles the given $pin.
  If the pin is 0, it becomes 1.
  If the pin is 1, it becomes 0.
  */
  toggle --pin/int:
    if not 0 <= pin < 8: throw "INVALID_PIN"
    toggle --mask=(1 << pin)

  /**
  Toggles the pins identified by the given $mask.
  If a pin is 0, it becomes 1.
  If a pin is 1, it becomes 0.
  Other pins remain unaffected.
  */
  toggle --mask/int:
    if not 0 <= mask <= 0xFF: throw "INVALID_MASK"
    state_ ^= mask
    device_.write #[state_]







