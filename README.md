# pipe.cb
Two-photon + Behavioral Integration - Burgess Lab

pipe.cb has 3 wrappers. Manual input is required after each wrapper:
wrapper1: write Tiffs, read+align nidaq, write eye video (.avi) -> Facemap/DLC + jupyter notebook to convert (raise issue)
wrapper2: stimuli + behavior -> run Suite2p
wrapper3: process neural data from Suite2p, integrate some behavior
Begin Spyder analysis:


The pipeline is based on inputting entire paths to functions. 
This avoids common parsing issues, doesn't force folder renames, maintains accurate filePaths, and allows easy portability between machines/servers.

findFILE is integral to running pipe.cb

The only user steps to run pipe.cb are 
1. clone this repo
2. clone facemap + Suite2p
3. selecting (indexing) the files to analyze in wrapper1-3 
4. adjusting paths [ijroot (tiffLoop), and bhv file template in bhv2Convert]


# In the works - Shell to run through constitutively 

 Alexa Faulkner 2020

Huge thank you to Arthur Sugden for access to pipe and his general guidance, thanks to Rohan for access to previous code!
