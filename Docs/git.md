# Git command

## Git submodule

Git command to setup mail and username
```bash
# Set email and username
git config --global user.email "binon.stepane@gmail.com"
git config --global user.name "Stepane B"
# Verify
git config --global --list
```

Add a submodule
```bash
git submodule add https://github.com/STMicroelectronics/STM32CubeG4.git ESC_TOOLKIT_TARGET_STM32G431RB/STM32CubeG4
# Push and then
git submodule update --init --recursive
```