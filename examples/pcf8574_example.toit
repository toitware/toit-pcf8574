// Copyright (C) 2021 Alfred Stier <xal@quantentunnel.de>. All rights reserved.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

/**
A basic example for the PCF8574.
*/

import gpio
import serial.protocols.i2c as i2c
import pcf8574 show *

main:
  sda := gpio.Pin 22
  scl := gpio.Pin 21
  bus := i2c.Bus --sda=sda --scl=scl --frequency=100_000

  device := bus.device PCF8574.I2C-ADDRESS-ALT
  pcf := PCF8574 device

  ret := pcf.read        // Reads status of all port and returns list.
  print "PCF read $ret"

  pcf.set --pin=2              // Turn LED 2 on   ( range from 0..7 ).
  sleep --ms=5000

  pcf.set --pin=6              // Turn LED 6 on.
  sleep --ms=5000

  pcf.clear              // No Pin parameter -> clear all pins.
  sleep --ms=5000

  pcf.set --pin=6
  sleep --ms=5000

  pcf.toggle             // No Pin parameter -> toggle all pins.

