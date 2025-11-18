# Git command

## Git submodule

Add a submodule
```bash
git submodule add https://github.com/STMicroelectronics/STM32CubeG4.git ESC_TOOLKIT_TARGET_STM32G431RB/STM32CubeG4
# Push and then
git submodule update --init --recursive
```