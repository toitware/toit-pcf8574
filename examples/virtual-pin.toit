// Copyright (C) 2024 Florian Loitsch <florian@loitsch.com>
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

/**
Use a virtual pin to pipe IO through the PCF8574.
*/

import gpio
import i2c
import pcf8574 show *

main:
  sda := gpio.Pin 22
  scl := gpio.Pin 21
  bus := i2c.Bus --sda=sda --scl=scl --frequency=100_000

  device := bus.device Pcf8574.I2C-ADDRESS-A
  pcf := Pcf8574 device

  // Applications that bit-bang the pins should work as expected with
  // virtual pins that are backed by the PCF8574.

  pin0 := gpio.VirtualPin:: pcf.set --pin=0 it
  pin1 := gpio.VirtualPin:: pcf.set --pin=1 it

  pin0.set 0
  pin0.set 1
  pin1.set 0
  pin1.set 1
