// Copyright (C) 2021 Alfred Stier <xal@quantentunnel.de>. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import binary show BIG-ENDIAN
import serial
import i2c
import gpio

/**
Toit driver for the PCF8574 i2c I/O port expander.
*/

class PCF8574:
  device_ /i2c.Device

  /** The default I2C address base for the PCF8574 plus Jumper setting A2, A1, A0. */
  static I2C-ADDRESS ::= 0x20
  static I2C-ADDRESS-000 ::= 0x20
  static I2C-ADDRESS-001 ::= 0x21
  static I2C-ADDRESS-010 ::= 0x22
  static I2C-ADDRESS-011 ::= 0x23
  static I2C-ADDRESS-100 ::= 0x24
  static I2C-ADDRESS-101 ::= 0x25
  static I2C-ADDRESS-110 ::= 0x26
  static I2C-ADDRESS-111 ::= 0x27

  _state := 0b00000000         // default to all OFF, after power on

  /** The alternate I2C address base for the PCF8574A. */
  static I2C-ADDRESS-ALT ::= 0x38

  constructor .device_:
    _bytes := device_.read 1
    _state = _bytes[0] ^ 0b11111111

  /**
  Reads the current state of the expander pins.
  Returns a list of 8 values, where each value is either 0 or 1.
  */
  read -> List:
    // No filter, alway returns an array with 8 elements.
    _bytes := device_.read 1
    // Inverted result 1 = ON.
    _state = _bytes[0] ^ 0b11111111

    result := List 8
    state := _state
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
    _state |= mask
    device_.write #[_state ^ 0b11111111]

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
    _state &= mask ^ 0b11111111
    device_.write #[_state ^ 0b11111111]

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
    _state ^= mask
    device_.write #[_state ^ 0b11111111]







