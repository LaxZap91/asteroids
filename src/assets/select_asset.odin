package assets

SELECT_PATH :: `assets\select.wav`
SELECT_EXT :: ".wav"

@(rodata)
SELECT_DATA := #load(`..\..\` + SELECT_PATH)
SELECT_PTR := raw_data(SELECT_DATA)
SELECT_SIZE := i32(len(SELECT_DATA))
