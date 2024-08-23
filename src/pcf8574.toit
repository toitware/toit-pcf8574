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

class Pcf8574:
  /** The default I2C address base for the PCF8574 with jumper setting A2, A1, A0. */
  static I2C-ADDRESS ::= 0x20
  /** The I2C address for a PCF8574 with jumper setting A2=0, A1=0, A0=0. */
  static I2C-ADDRESS-000 ::= 0x20
  /** The I2C address for a PCF8574 with jumper setting A2=0, A1=0, A0=1. */
  static I2C-ADDRESS-001 ::= 0x21
  /** The I2C address for a PCF8574 with jumper setting A2=0, A1=1, A0=0. */
  static I2C-ADDRESS-010 ::= 0x22
  /** The I2C address for a PCF8574 with jumper setting A2=0, A1=1, A0=1. */
  static I2C-ADDRESS-011 ::= 0x23
  /** The I2C address for a PCF8574 with jumper setting A2=1, A1=0, A0=0. */
  static I2C-ADDRESS-100 ::= 0x24
  /** The I2C address for a PCF8574 with jumper setting A2=1, A1=0, A0=1. */
  static I2C-ADDRESS-101 ::= 0x25
  /** The I2C address for a PCF8574 with jumper setting A2=1, A1=1, A0=0. */
  static I2C-ADDRESS-110 ::= 0x26
  /** The I2C address for a PCF8574 with jumper setting A2=1, A1=1, A0=1. */
  static I2C-ADDRESS-111 ::= 0x27

  /** The I2C address base for the PCF8574A with jumper setting A2, A1, A0. */
  static I2C-ADDRESS-A ::= 0x38
  /** The I2C address for a PCF8574A with jumper setting A2=0, A1=0, A0=0. */
  static I2C-ADDRESS-A-000 ::= 0x38
  /** The I2C address for a PCF8574A with jumper setting A2=0, A1=0, A0=1. */
  static I2C-ADDRESS-A-001 ::= 0x39
  /** The I2C address for a PCF8574A with jumper setting A2=0, A1=1, A0=0. */
  static I2C-ADDRESS-A-010 ::= 0x3A
  /** The I2C address for a PCF8574A with jumper setting A2=0, A1=1, A0=1. */
  static I2C-ADDRESS-A-011 ::= 0x3B
  /** The I2C address for a PCF8574A with jumper setting A2=1, A1=0, A0=0. */
  static I2C-ADDRESS-A-100 ::= 0x3C
  /** The I2C address for a PCF8574A with jumper setting A2=1, A1=0, A0=1. */
  static I2C-ADDRESS-A-101 ::= 0x3D
  /** The I2C address for a PCF8574A with jumper setting A2=1, A1=1, A0=0. */
  static I2C-ADDRESS-A-110 ::= 0x3E
  /** The I2C address for a PCF8574A with jumper setting A2=1, A1=1, A0=1. */
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
    bytes := device_.read 1

    result := List 8
    state := bytes[0]
    8.repeat:
      result[it] = state & 1
      state >>= 1
    return result

  /**
  Reads the current state of the expander pins.

  Returns a single integer where each bit represents the state of a pin.

  The argument $raw must be true.
  */
  read --raw/bool -> int:
    if not raw: throw "INVALID_ARGUMENT"

    bytes := device_.read 1
    return bytes[0]

  /**
  Writes the given $value to the expander pins.

  Each bit in the value represents the state of a pin.
  Since the expander is open-drain, a 1 in the value will not necessarily
    result in a high pin. However, a 0 in the value will result in a low pin.

  The argument $raw must be true.
  */
  write --raw/bool value/int -> none:
    if not raw: throw "INVALID_ARGUMENT"
    if not 0 <= value <= 0xFF: throw "INVALID_ARGUMENT"
    state_ = value
    device_.write #[value]

  /**
  The current state of the expander pins.

  Returns a single integer where each bit represents the state of a pin.

  This is the value that was last written to the expander. It might contain
    more 1s than the actual state of the pins, since the expander is open-drain.
  */
  state -> int:
    return state_

  /**
  Sets the given $pin to the given $value.
  Other pins remain unaffected.

  Uses the $state to avoid modifying other pins.
  */
  set --pin/int value/int:
    if not 0 <= pin < 8: throw "INVALID_PIN"
    if value == 1:
      write --raw (state_ | (1 << pin))
    else if value == 0:
      write --raw (state_ & ~(1 << pin))
    else:
      throw "INVALID_ARGUMENT"

  /**
  Toggles the given $pin.

  Uses the $state to know the current value of the pin, and to avoid
    modifying other pins.
  */
  toggle --pin/int:
    if not 0 <= pin < 8: throw "INVALID_PIN"
    write --raw (state_ ^ (1 << pin))
