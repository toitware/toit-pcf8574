// Copyright (C) 2021 Alfred Stier <xal@quantentunnel.de>.
// Copyright (C) 2024 Florian Loitsch <florian@loitsch.com>
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

/**
A basic example for the PCF8574.
*/

import gpio
import i2c
import pcf8574 show *

main:
  sda := gpio.Pin 26
  scl := gpio.Pin 27
  bus := i2c.Bus --sda=sda --scl=scl --frequency=100_000

  device := bus.device Pcf8574.I2C-ADDRESS-A
  pcf := Pcf8574 device

  // Reads the value of all pins.
  values := pcf.read
  print "PCF read $values"

  // Sets pin 2 to ground.
  pcf.set --pin=2 0
  sleep --ms=1000

  // Sets pin 2 to open-drain high.
  // In this state the pin is high-impedance, and any pull-up resistor pulls the pin high.
  // Alternatively, the pin can now be used as input again.
  pcf.set --pin=2 1

  5.repeat:
    pcf.toggle --pin=5
    sleep --ms=300

