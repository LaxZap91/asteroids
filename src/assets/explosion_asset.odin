package assets

EXPLOSION_PATH :: `assets\explosion.wav`
EXPLOSION_EXT :: ".wav"

EXPLOSION_DATA :: #load(`..\..\` + EXPLOSION_PATH)
EXPLOSION_PTR := raw_data(EXPLOSION_DATA)
EXPLOSION_SIZE := i32(len(EXPLOSION_DATA))
