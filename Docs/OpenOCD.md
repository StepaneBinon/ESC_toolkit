# OpenOCD

OpenOCD (Open On Chip Debuger - doc [1]) is used to get low to none overhead debug from the chip using the TPIU [2].

To connect the server to the chip, once plugged into the computer
```bash
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg
```
You should have ![alt text](.\Images\OpenOCD\connect_result.png)


## Ressources

[1] OpenOCD documentation: https://openocd.org/pages/documentation.html

[2] Orbcode article on TPIU: https://orbcode.org/orbuculum/single-wire-output/ 