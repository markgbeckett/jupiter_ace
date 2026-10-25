#! /bin/bash
ffmpeg -i lcd_1_zxf4.wav -i lcd_2_zxf4.wav -i lcd_3_zxf4.wav -i lcd_4_zxf4.wav -i lcd_5_zxf4.wav -i lcd_6_zxf4.wav -i lcd_7_zxf4.wav -i lcd_8_zxf4.wav -i lcd_9_zxf4.wav -filter_complex '[0:0][1:0][2:0][3:0][4:0][5:0][6:0][7:0][8:0]concat=n=9:v=0:a=1[out]' -map '[out]' lcd_zxf4.wav
