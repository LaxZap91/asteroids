package assets

LOGO_PATH :: `assets\logo.png`
LOGO_EXT :: ".png"

@(rodata)
LOGO_DATA := #load(`..\..\` + LOGO_PATH)
LOGO_PTR := raw_data(LOGO_DATA)
LOGO_SIZE := i32(len(LOGO_DATA))
