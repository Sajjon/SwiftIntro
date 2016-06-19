# 📱 My first Memory 🤔💭
#### _An introduction to iOS development with Swift._

A memory game implementation fetching images from Instagram. This project aims to introduce you to iOS development with Swift disregarding of your current skill level.

The app defaults to fetch the [Instagram images of Taylor Swift](https://www.instagram.com/taylorswift/) ([Alex](https://github.com/sajjon): _"Hehe he he..._ 😁, _yes_ [Miriam](https://github.com/MiriamTisander), _that is funny"_), but you can enter your own or another custom Instagram account and fetch images for it instead.

## Tasks 

### 🐌 This looks interesting 
 
1. Change the color ❤️💛💚💙💜 of the _Play!_ button.

2. Change the the backgroundcolor of the cards (_CardCVCell_).

3. Change the duration of the flip card animation.

4. Change the username placeholder (tip: check out the method _setupLocalizableStrings()_ in _SettingsVC_, you also need to check out the file called Localizable.strings for each language).

5. Add support for your third favourite language 🇫🇷🇸🇾🇯🇵, you need to test this as well (by pressing ⌘+⬆+H in the simulator you go to its home screen, where you can find the Settings app where you have to change the system language to the one you just added.)

6. Change the flip card animation from using a horizontal flip to a vertical (tip: check out the _flipCard()_ method in the _CardCVCell_ class. [Here is the documentation for animations](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/#//apple_ref/occ/clm/UIView/animateWithDuration:delay:options:animations:completion:))


### 🐰 I think I've got a good grip of it

* Change the _Quit_ button title, which currently is a text with the char _X_, to use an image 🏔 instead. 

* Implement white space handling for the username textfield.

* Set the background of the memory Card (_CardCVCell_) to be show an image 🏔 instead of just a color.

* Refactor the name of a variable/class/function you don't understand to a more understandable description. 

* Switch the position of the _Restart_ button with the _Quit_ button (don't delete the buttons... 😜)

* Save the best score (lowest _clickCount_ for each level) a user has scored and present this score in the _GameOverVC_. (Tip: Checkout [NSUserDefaults](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/) for saving.)

* It is currently possible for a user to flip a third card while the flip animation of the two previous cards has not yet finished. Address this issue.

* Create a timer ⏲ [NSTimer](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/) that counts the time for a game session. Display this time in the _GameOverVC_ after the game has finished.

### 🦄 Bring it on
* Display a timer ⏲ [NSTimer](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/) (could be the one you created in task _ ) that is counting upwards in the _GameVC_ showing elapsed time ⏰ since game start.

* When you press the _Restart_ button from _GameOverVC_ the cards will have the same position as before, this makes it easy to cheat! Your task is to shuffle the cards before restarting the game.  

* Change the feedback message in _GameOverVC_ from _Well done_ to a dynamic title that changes according to how well it went. Some examples strings: _Awesome_, _Not sooo bad_, _That was Horrible_ etc. This string should not be directly dependent on only _Level_, or only _clickCount_, but rather..?
* Currently the project uses hard coded keys for localized strings (the key itself is a string), which is the sta
ndard iOS pattern - but it smells! Instead you can introduce an Enum for all the localized strings. So that you will be able to write something like this: (Tip: Either you do this by yourself, or you can use [SwiftGen](https://github.com/AliSoftware/SwiftGen) for this, if you know how to install it...)
```swift
	restartButton.setLocalizedTitle(LocalizedStrings.Restart)
``` 

* Add some Error ☠ Handeling, e.g  displaying a message if the Instagram username doesn't exist, or if no images could be loaded.

* Make it possible to set the number of cards to a custom number. Currently the number of cards are determined base on which difficulty level you chose in the SettingsVC. 

* Enable Landscape mode for all the views.

* Fetch the images from another source than Instagram. Maybe you can fetch the images from FourSquare, using its [API](https://developer.foursquare.com/), [Flickr](https://www.flickr.com/services/api/) or [Twitter](https://dev.twitter.com/rest/public). Please note all the above mentioned alternative image sources require an API token/secret. So you have to create those in order to use the APIs. Then you have to change the JSON parsing of the _Cards_ model. You also need to modify the _Photos_ 📷 route in the _Router_ class to go against the correct URL.

## Authors 

### [Alexander Cyon](https://github.com/sajjon) [@Redrum_237](https://twitter.com/redrum_237) 
Alexander has worked with app development since 2010 and enjoys Android but loves iOS 😍.

### [Miriam Tisander](https://github.com/MiriamTisander)
Miriam has worked with iOS development since 2015, she loves Swift but is currently working with Objective-C 😭🔫. 

