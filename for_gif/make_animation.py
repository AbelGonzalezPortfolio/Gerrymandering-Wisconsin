#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 22 12:33:34 2019

@author: lambm
"""
import imageio
import os
os.chdir('/Users/lambm/Documents/GitHub/MTH-398-Independent-Study/Gerrymandering to 1.0/images/')
filenames = [f for f in os.listdir() if f[:5] == 'shape' and f[6].isdigit()]
filenames = sorted(filenames, key = lambda f: int(''.join([c for c in f if c.isdigit()])), reverse=True)
with imageio.get_writer('animation.mp4', mode='I', fps=5) as writer:
    for filename in filenames:
        image = imageio.imread(filename)
        writer.append_data(image)
