#! /bin/bash
ffmpeg -i i2c_1_zxf4.wav -i i2c_2_zxf4.wav -i i2c_3_zxf4.wav -i i2c_4_zxf4.wav -i i2c_5_zxf4.wav -i i2c_6_zxf4.wav -filter_complex '[0:0][1:0][2:0][3:0][4:0][5:0]concat=n=6:v=0:a=1[out]' -map '[out]' i2c_zxf4.wav
