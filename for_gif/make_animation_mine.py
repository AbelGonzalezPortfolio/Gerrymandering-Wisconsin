#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 22 12:33:34 2019

@author: lambm
"""
import imageio
import pathlib

images_folder = pathlib.Path("images/")
filenames = [f for f in images_folder.glob('*.*')]

with imageio.get_writer('animation.mp4', mode='I', fps=3) as writer:
    for i in range(0,len(filenames)):
        image_path = pathlib.Path("images/shape_{}.png".format(i))
        image = imageio.imread(image_path)
        writer.append_data(image)
        
