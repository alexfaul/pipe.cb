import numpy as np
import pandas as pd
import math

def areaCalc(row):
    # Vertical Distance
    vert1x = (float(row["5"]) - float(row["2"]))**2
    vert1y = (float(row["6"]) - float(row["3"]))**2

    d1 = math.sqrt(vert1x + vert1y)

    # Horizontal Distance
    vert2x = (float(row["11"]) - float(row["8"]))**2
    vert2y = (float(row["12"]) - float(row["9"]))**2

    d2 = math.sqrt(vert2x + vert2y)

    # Finisher

    area = math.pi * (d1 / 2) * (d2 / 2)
    return area


# Read in DLC .csv file
dlc_path = conversionVars.path
dlc_data = pd.read_csv(dlc_path)


# Read in host .npy file
data =vnp.load("Sut3_191120_001_eye_proc.npy", allow_pickle=True).item()


# Clean up csv and create area col
temp1 = dlc_data.drop(dlc_data.index[0])
temp2 = temp1.drop(temp1.index[0])
temp2.columns = [str(x) for x in range(1,17)]
temp2["area"] = temp2.apply(areaCalc, axis=1)


# Create an area array to insert into host npy file
areaList = temp2["area"].to_list()
areaArray = np.asarray(areaList)

# Edit OG data
data["pupil"][0]["area"] = areaArray
data["iframes"] = dlc_data.iloc[-1,0]
