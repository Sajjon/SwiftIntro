# 📱 My first Memory 🤔💭
#### _An introduction to iOS development with Swift._

A memory game implementation fetching images from Wikimedia. This project aims to introduce you to iOS development with Swift disregarding of your current skill level.

> **Architecture & design decisions:** [DESIGN.md](DESIGN.md)
> **AI assistant instructions:** [CLAUDE.md](CLAUDE.md)

# Installation
## OBS! This project has been migrated to Swift 6.01 so you need Xcode 26.1 to open it
There is no need for any _installation_ per se, you only need to download this project. You download the project by pressing the big green _Clone or download_ button you see in the top right side of this page. You can either download the project as a zip, or you can use _git_ to download the project by opening the terminal and entering:
```
git clone <PASTE_GITHUB_URL_HERE> 
```

### After you have download the project, open the file called _SwiftIntro.xcworkspace_ (*not* _SwiftIntro.xcodeproj_).

# iOS development
All the _screens_ you see are called ```UIViewController``` which consists of smaller view elements called ```UIView```. Buttons (```UIButton```), text labels (```UILabel```), textfield for text input (```UITextField```) are all subclasses of the superclass ```UIView```. All instances of ```UIViewController``` have a view (```UIView```), which is the root view, the _canvas_ in which you can add buttons, labels and lists (```UITableView```).

iOS development follows the architecture called [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) by default, which stands for Model-View-Controller. 

## MVC
_The Model_, _the View_ and _the Controller_ are three different areas of responsibility within the app.

The idea is that the _Controller_ acts as a coordinator, fetching data from either internet or a local database, stored in _Models_ and passing those models into _Views_ that can display the data.

### ViewControllers (View and Controller)
For every _screen_ in your app you create your own subclass of ```UIViewController```. To that you add all the views you want your screen to consist of. You can do this in two ways, either you do it using _InterfaceBuilder_ or in code. This project does it in code. The syntax for this is typically:
```swift
	private func myMethodCreatingLabel() {
		let resetPasswordLabel = UILabel()
		resetPasswordLabel.text = "Have you forgot your password?"
		resetPasswordLabel.textAlignment = .Center
		resetPasswordLabel.textColor = UIColor.redColor()
		view.addSubview(resetPasswordLabel)
		/* Here we should proceed with creating NSLayoutConstraints
		which are rules that tells iOS where to place the view and
		how big the view should be.
		*/
	}
```
### Model
A model is a ```struct``` or ```class``` that holds data. In this project we fetch data, sent over HTTP GET on the JSON format from Wikimedia. The images from Wikimedia are stored in a ```struct``` called _Cards.swift_. Structs and classes may seem very similar, and in terms of syntax they are. But the behave very differently in terms of memory and reference, after you have worked with this project you can have a look at this [WWDC video](https://developer.apple.com/videos/play/wwdc2015/414/) explaining the difference.

## How to write good code
iOS apps actually have a quite confusing MVC pattern, because the ```UIViewController``` is the controller, but it also has its own ```UIView```, so in a way the ```UIViewController``` is also the view 😬😅. The MVC patterin in iOS has often been critized ([here](http://clean-swift.com/clean-swift-ios-architecture/), [here](https://www.objc.io/issues/13-architecture/mvvm/) and [here](https://realm.io/news/andy-matuschak-refactor-mega-controller/)) and called _*Massive*-View-Controller_, because the ```UIViewController``` classes you create tend grow to many hundreds lines of code. This project aims to not have any _*Massive*_ ```UIViewController```. The project has four ```UIViewControllers``` (_GameVC_, _SettingsVC_, _GameOverVC_ and _LoadingDataVC_) and the biggest is not even 100 lines of code. Try to aim for that less than 100 lines of code! Unfortunatly it's rare to work in a project where *any* ```UIViewController``` is less than 100 lines of code. So if you make it a habbit then you will be a skilled iOS developer from start 🦄. A great way of achieving small UIViewControllers is to split a single screen into multiple ```UIViewControllers```, or to use ```extensions```, [here is a great article](http://khanlou.com/2016/02/many-controllers/) on how ```extensions``` of ```UIViewController``` can make your ```UIViewControllers``` smaller. 

Another general guideline is to try to keep under less than 200 lines of code for *all* files (classes, structs or enums). When you notice that a class grows, maybe you can try to split it into two or three classes instead. In fact all files in this project is less than 100 lines of code, with one exception - _MemoryDataSourceAndDelegate_ - which still is less than 200 lines.

### SwiftLint
A good way to enforce writing good code is to install a tool called [SwiftLint](https://github.com/realm/SwiftLint) which we have used durint the development of this project. If you have [Homebrew](http://brew.sh/) installed you can install it using this terminal command:
```bash
brew install swiftlint
```

# Tasks

## 🐌 This looks interesting
 
1. Change the color ❤️💛💚💙💜 of the _Play!_ button.

2. Change the the backgroundcolor of the cards.<br/>
(tip: check out _CardCVCell.swift_)

3. Change the duration of the flip card animation.

4. Change the username placeholder.<br/>
(tip: check out the method _setupLocalizableStrings()_ in _SettingsVC_, you also need to check out the file called Localizable.strings for each language)

5. Add support for your third favourite language 🇫🇷🇸🇾🇯🇵, you need to test this as well (by pressing ⌘+⬆+H in the simulator you go to its home screen, where you can find the Settings app where you have to change the system language to the one you just added.)

6. Change the flip card animation from using a horizontal flip to a vertical. <br/>
(tip: check out the _flipCard()_ method in the _CardCVCell_ class. [Here is the documentation for animations](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/#//apple_ref/occ/clm/UIView/animateWithDuration:delay:options:animations:completion:))


## 🐰 I think I've got a good grip of it

1. Change the _Quit_ button title, which currently is a text with the char _X_, to use an image 🏔 instead. 

2. Set the background of the memory Card to be show an image 🏔 instead of just a color.<br/>
(tip: check out _CardCVCell.swift_)

3. In the section [How to write good code](#how-to-write-good-code) we discussed the goal of writing small files, and the class _MemoryDataSourceAndDelegate_ with its almost 200 lines of code was mentioned. Can you split this class into several smaller classes that makes sense, so that no class is more than 100 lines?

4. Switch the position of the _Restart_ button with the _Quit_ button.<br/>
(tip: don't delete the buttons... 😜 then you have to recreate the _Segues_ ...)

5. Save the best score (lowest _clickCount_ for each level) a user has scored and present this score in the _GameOverVC_. <br/>
(Tip: Checkout [NSUserDefaults](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/) for saving.)

6. It is currently possible for a user to flip a third card while the flip animation of the two previous cards has not yet finished. Address this issue.

7. Create a timer ⏲ [NSTimer](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/) that counts the time for a game session. Display this time in the _GameOverVC_ after the game has finished.

## 🦄 Bring it on
1. Display a timer ⏲ [NSTimer](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/) (could be the one you created in task 8 in [I think I've got a good grip of it](#i-think-ive-got-a-good-grip-of-it) ) that is counting upwards in the _GameVC_ showing elapsed time ⏰ since game start.

2. When you press the _Restart_ button from _GameOverVC_ the cards will have the same position as before, this makes it easy to cheat! Your task is to shuffle the cards before restarting the game.  

3. Implement white space handling for the username textfield.

4. Change the feedback message in _GameOverVC_ from _Well done_ to a dynamic title that changes according to how well it went. Some examples strings: _Awesome_, _Not sooo bad_, _That was Horrible_ etc. This string should not be directly dependent on only _Level_, or only _clickCount_, but rather..?

5. Currently the project uses hard coded keys for localized strings (the key itself is a string), which is the standard iOS pattern - but it smells! Instead you can introduce an Enum for all the localized strings. So that you will be able to write something like this: 
```swift
	restartButton.setLocalizedTitle(LocalizedStrings.Restart)
```
(Tip: Either you do this by yourself, or you can use [SwiftGen](https://github.com/AliSoftware/SwiftGen) for this, if you know how to install it...)

6. Add some Error ☠ handling, e.g  displaying a message if the Instagram username doesn't exist, or if no images could be loaded.

7. Make it possible to set the number of cards to a custom number. Currently the number of cards are determined base on which difficulty level you chose in the SettingsVC. 

8. Enable Landscape mode for all the views.

9. Fetch the images from another source than Instagram. Maybe you can fetch the images from FourSquare, using its [API](https://developer.foursquare.com/), [Flickr](https://www.flickr.com/services/api/) or [Twitter](https://dev.twitter.com/rest/public). Please note all the above mentioned alternative image sources require an API token/secret. So you have to create those in order to use the APIs. Then you have to change the JSON parsing of the _Cards_ model. You also need to modify the _Photos_ 📷 route in the _Router_ class to go against the correct URL.