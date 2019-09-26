#!/bin/cat

BLM RentSchedu is CHARACTER, needs to be CAST to INTEGER

v.db.addcol BLM col="rent_class integer"
v.db.update BLM col=rent_class qcol="CAST(RentSchedu AS integer)" where="RentSchedu <> ''"


SLOPE SLOPE is CHARACTER, needs to be classified

db.select sql="SELECT DISTINCT SLOPE FROM SLOPE"

v.db.addcol SLOPE col="slope_class integer"
v.db.update SLOPE col=slope_class qcol="1" where="SLOPE = '0 to 2 Percent'"
v.db.update SLOPE col=slope_class qcol="2" where="SLOPE = '2 to 8 Percent'"
v.db.update SLOPE col=slope_class qcol="3" where="SLOPE = 'Greater than 8 percent'"

VEG TERRAIN_TY is CHARACTER, needs to be classified

db.select sql="SELECT DISTINCT TERRAIN_TY FROM NORTH"
Desert/Barren Land
Farmland
Forested
N/A
Open Water
Scrubbed/Flat
Urban

db.select sql="SELECT DISTINCT TERRAIN_TY FROM SOUTH"
Desert/Barren Land
Farmland
Forested
N/A
Open Water
Scrubbed/Flat
Urban

db.select sql="SELECT DISTINCT WETLAND FROM NORTH"
NWI
Wetlands (MT)

db.select sql="SELECT DISTINCT WETLAND FROM SOUTH"
NWI


v.db.addcol NORTH col="terrain_class integer"
v.db.update NORTH col=terrain_class qcol="1" where="TERRAIN_TY = 'Desert/Barren Land'"
v.db.update NORTH col=terrain_class qcol="2" where="TERRAIN_TY = 'Farmland'"
v.db.update NORTH col=terrain_class qcol="3" where="TERRAIN_TY = 'Forested'"
v.db.update NORTH col=terrain_class qcol="4" where="TERRAIN_TY = 'Open Water'"
v.db.update NORTH col=terrain_class qcol="5" where="TERRAIN_TY = 'Scrubbed/Flat'"
v.db.update NORTH col=terrain_class qcol="6" where="TERRAIN_TY = 'Suburban'"
v.db.update NORTH col=terrain_class qcol="7" where="TERRAIN_TY = 'Urban'"
v.db.update NORTH col=terrain_class qcol="8" where="WETLAND = 'NWI' OR WETLAND = 'Wetlands (MT)'"

v.db.addcol SOUTH col="terrain_class integer"
v.db.update SOUTH col=terrain_class qcol="1" where="TERRAIN_TY = 'Desert/Barren Land'"
v.db.update SOUTH col=terrain_class qcol="2" where="TERRAIN_TY = 'Farmland'"
v.db.update SOUTH col=terrain_class qcol="3" where="TERRAIN_TY = 'Forested'"
v.db.update SOUTH col=terrain_class qcol="4" where="TERRAIN_TY = 'Open Water'"
v.db.update SOUTH col=terrain_class qcol="5" where="TERRAIN_TY = 'Scrubbed/Flat'"
v.db.update SOUTH col=terrain_class qcol="6" where="TERRAIN_TY = 'Suburban'"
v.db.update SOUTH col=terrain_class qcol="7" where="TERRAIN_TY = 'Urban'"
v.db.update SOUTH col=terrain_class qcol="8" where="WETLAND = 'NWI'"

