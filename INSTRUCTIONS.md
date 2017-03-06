## Instructions ##

### Compile and Run ###

- Download OpenCV for iOS from [1] y extract it
- Copy the file opencv2.framework into EffectsTimeApp/Externals/ folder
- open in Xcode EffectsTimeApp/EffectsTimeApp.xcodeproj
- Solve the signing of the app
- Run

Note: this app  was developer and tested with Xcode 8.2.1

### Usage ###

Using this application is pretty simple:
* the orange button at the bottom starts/stops the video camera.
* There are three panes where the camera capture will be drawn. The one at the
  top-left corner shows the original buffer converted to an UIImage.  The one
  at its right side, uses OpenCV to modify the content, and finally displays
  using the same technique (conversion to UIImage).  And the third, at the
  bottom, uses OpenGL. The frame is uploaded as a texture as it is and the
  effect (flip and inversion of color) are applied in the vertex and fragment
  shader.  
* It is possible to enable/disable the flipping and color inversion from the
  UI using the switch buttons under "Effects".
* Under each image there is a switch, to turn that pane on and off (and its
  processing behind). This can be quite usefull to measure performance and CPU
  usage.

[1] https://sourceforge.net/projects/opencvlibrary/files/opencv-ios/3.2.0/opencv-3.2.0-ios-framework.zip/download
