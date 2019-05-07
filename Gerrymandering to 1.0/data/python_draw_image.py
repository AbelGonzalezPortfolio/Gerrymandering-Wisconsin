import geopandas as gpd
import matplotlib.pyplot as plt

shapefile_df = gpd.read_file("wi14/wi14.shp")


shapefile_df.plot()