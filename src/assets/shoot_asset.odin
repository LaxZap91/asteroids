package assets

SHOOT_PATH :: `assets\shoot.wav`
SHOOT_EXT :: ".wav"

@(rodata)
SHOOT_DATA := #load(`..\..\` + SHOOT_PATH)
SHOOT_PTR := raw_data(SHOOT_DATA)
SHOOT_SIZE := i32(len(SHOOT_DATA))
