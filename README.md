 process-ctd-profile-matlab present a simple method to automatically processed CTD oceanograhic data. It uses the [RSKTools package](https://bitbucket.org/rbr/rsktools/src/master/) developed by RBR. Further development is needed to clearly make the tool compatible with a number of instruments. As of now this is only an example of application method.

# Tool installation
 To install the tool:
 1. Clone the whole package locally, either through a git command of by downloading the package.
 2. Add the package directory and subdirectories to your MatLab paths.

# How To
 You can now run the processing tool by sending the following command within MatLab:

``` matlab
 processProfileData([rawFilePath (String): *.rsk,*.tob, etc]) 
 ```

A similar function exist specifically for the Caspian Sea:

``` matlab
 processCaspianProfiles([rawFilePath (String): *.rsk,*.tob]) 
 ```

A series of corrections and transformations are then applied to the data. If the data is sucessfully processed, an ODV format text format will be ouputted.