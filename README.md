# SwiftIntro
A memory game implementation fetching images from Instagram. This project aims to introduce you to Swift whatever experience level you are currently at!

## Tasks

### This looks interesting 
 
* Change the color of the "Play!" button.
* Change the the backgroundcolor of the cards ("CardCVCell").
* Change the duration of the flip card animation.
* Change the username placeholder.

### I think I've got a good grip of it

* Change the "Quit" button title, which currently is a text with the char "X", to use an image instead. 
* Implement white space handling for the username textfield.
* Set the background of the memory Card ("CardCVCell") to be show an image instead of just a color.

### Bring it on
* When you press the "Restart" button from "GameOverVC" the cards will have the same position as before, this makes it easy to cheat! Your task is to shuffle the cards before restarting the game.  
* Change the feedback message in "GameOverVC" from "Well done" to a dynamic title that changes according to how well it went. Some examples strings: "Awesome", "Not sooo bad", "That was Horrible" etc. This string should not be directly dependent on only "Level", or only "clickCount", but rather..?
* Add some Error Handeling, e.g  displaying a message if the Instagram username doesn't exist, or if no images could be loaded.
* Make it possible to set the number of cards to a custom number. Currently the number of cards are determined base on which difficulty level you chose in the SettingsVC. 
* Enable Landscape mode of all the views.
* Fetch the images from another source than Instagram. Maybe you can fetch the images from FourSquare, using its [API](https://developer.foursquare.com/) or [Flickr](https://www.flickr.com/services/api/)


