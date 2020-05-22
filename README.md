# pipe.cb
Two-photon + Behavioral Integration - Burgess Lab

pipe.cb has 3 wrappers. The end of a wrapper indicates a break point in the pipe where manual input is required (Cell clicking, pupil detection, etc).

The pipeline is based on inputting entire paths to functions. This avoids common parsing issues (if files are named differently), allows skipping renaming files/folders while maintaining accurate filePaths, and allows easy portability between machines/servers.

findFILE is integral to running pipe.cb

The only user changes to run pipe.cb are selecting (indexing) the files to analyze in the wrappers, adjusting paths [ijroot (tiffLoop), and bhv file template in bhv2Convert]

# In the works - Shell to run through constitutively 

 Alexa Faulkner 2020


Thank you to Arthur Sugden for his essential guidance, and Rohan Ramesh for allowing us to use his old code (there's gotta be a better way to say this)
