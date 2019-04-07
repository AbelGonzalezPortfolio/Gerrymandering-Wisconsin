import geopandas as gpd

shapef_filename = "./data/shapef/Wards_Final_Geo_111312_2014_ED.shp"
shapefile = gpd.read_file(shapef_filename)

union_shape = shapefile.unary_union
shape_boundary = union_shape.boundary

#gpd.sjoin(shapefile, shape_boundary, how='left')

bounds = shapefile.envelope
boundary = bounds.intersects(shape_boundary)

boundary_list = []
for i in 1:boundary
    if boundary[i]
        push!(boundary_list, i)
    end
end
print(boundary)
