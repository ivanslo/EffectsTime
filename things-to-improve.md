### Things to be improved ###

- The textures are redendered in mode "Stretch and Fill", which doesn't look
  nice in all the configurations.
  
  A better solution will be to crop the texture in order to Fill the area
  without stretching (leaving part of the texture out).  
  
  In openGL changing the textCoord, in OpenCV cropping the image buffer, and
  same for the original.  
  
  This problem may be more evident when choosing a different
  AVCaptureSessionPreset.


- It can be clearer when I am recording and when not. Perhaps altering the
  color of the background is a good idea.

