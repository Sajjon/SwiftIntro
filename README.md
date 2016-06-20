# 📱 My first Memory 🤔💭
#### _An introduction to iOS development with Swift._

A memory game implementation fetching images from Instagram. This project aims to introduce you to iOS development with Swift disregarding of your current skill level.

The app defaults to fetch the [Instagram images of Taylor Swift](https://www.instagram.com/taylorswift/) ([Alex](https://github.com/sajjon): _"Hehe he he..._ 😁, _yes_ [Miriam](https://github.com/MiriamTisander), _that is funny"_), but you can enter your own or another custom Instagram account and fetch images for it instead.

# Installation
There is no need for any _installation_ per se, you only need to download this project. You download the project by pressing the big green _Clone or download_ button you see in the top right side of this page. You can either download the project as a zip, or you can use _git_ to download the project by opening the terminal and entering:
```
git clone <PASTE_GITHUB_URL_HERE> 
```

After you have download the project, open the file called _SwiftIntro.xcworkspace_ (*not* _SwiftIntro.xcodeproj_).

# iOS development
All the _screens_ you see are called ```UIViewController``` which consists of smaller view elements called ```UIView```. Buttons (```UIButton```), text labels (```UILabel```), textfield for text input (```UITextField```) are all subclasses of the superclass ```UIView```. All instances of ```UIViewController``` have a view (```UIView```), which is the root view, the _canvas_ in which you can add buttons, labels and lists (```UITableView```).

iOS development follows the architecture called [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) by default, which stands for Model-View-Controller. 

## MVC
_The Model_, _the View_ and _the Controller_ are three different areas of responsibility within the app.

The idea is that the _Controller_ acts as a coordinator, fetching data from either internet or a local database, stored in _Models_ and passing those models into _Views_ that can display the data.

### ViewControllers (View and Controller)
For every _screen_ in your app you create your own subclass of ```UIViewController```. To that you add all the views you want your screen to consist of. You can do this in two ways, either you do it using _InterfaceBuilder_ or in code.

1. In _InterfaceBuilder_ (*IB* in short), which is a great drag and drop tool which aims to be a [WYSIWYG](https://en.wikipedia.org/wiki/WYSIWYG) (_What You See Is What You Get_). Allthough in Xcode 7.x.x IB is not capable of rendering all the views and different styling of those (rounded corners, blur effect etc..). Xcode 8 will be more capable os this. There are two different ways to use IB you can either use _Storyboards_ ([UIStoryBoard](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIStoryboard_Class/)) or you can use _.xib_ files (also called _nib_ files).

  1. In a storyboard you can create several UIViewControllers, maybe you create a _SignInViewController_, _SignUpViewController_ and a _ResetPasswordViewController_. In the Storyboard you can create flows between these ViewControllers, e.g. you can create a _Reset Password_ UIButton in the _SignInViewController_ and then you can define that when the user presses that button, the _ResetPasswordViewController_ is shown to the user. These _flows_ between UIViewControllers are called _Segue_ (pronounced "segway"). 

  2. The Xib file approach is an older technique which only allows for one UIViewController per Xib file. In Xib files you don't need to put UIViewControllers, you can instead put UIViews. The advantage of this is that they can be used by different UIViewControllers or UIViews in your project. So they are reusable through out the project. A good example of when to use Xib files is when you want to create a list (```UITableView```) or grid (```UICollectionView```) of views. This project uses a ```UICollectionView``` for displaying memory cards in a grid. The cards are ```UICollectionViewCells``` (subclass of ```UIViews```...). So each _item_ in a list or grid of view is called a _cell_. It is recommended to create each unique cell class in a separate Xib file.

2. Creating views in code (or _programmatically_ as you often say...). All ```UIButtons```, ```UILabels```, ```UITableviews```, ```UITextViews```, ```UITextField``` etc you drag and drop in Interface Builder can also be created and added to your view using pure Swift code. The syntax for this is typically:
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
A model is a s```truct``` or ```class``` that holds data. In this project we fetch data, sent over HTTP GET on the JSON format from Instagram. The images from Instagram are stored in a s```truct``` called _Cards.swift_. Structs and classes may seem very similar, and in terms of syntax they are. But the behave very differently in terms of memory and reference, after you have worked with this project you can have a look at this [WWDC video](https://developer.apple.com/videos/play/wwdc2015/414/) explaining the difference.

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
(tip: check out _CardCVCell.xib_ or _CardCVCell.swift_)

3. Change the duration of the flip card animation.

4. Change the username placeholder.<br/>
(tip: check out the method _setupLocalizableStrings()_ in _SettingsVC_, you also need to check out the file called Localizable.strings for each language)

5. Add support for your third favourite language 🇫🇷🇸🇾🇯🇵, you need to test this as well (by pressing ⌘+⬆+H in the simulator you go to its home screen, where you can find the Settings app where you have to change the system language to the one you just added.)

6. Change the flip card animation from using a horizontal flip to a vertical. <br/>
(tip: check out the _flipCard()_ method in the _CardCVCell_ class. [Here is the documentation for animations](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/#//apple_ref/occ/clm/UIView/animateWithDuration:delay:options:animations:completion:))


## 🐰 I think I've got a good grip of it

1. Change the _Quit_ button title, which currently is a text with the char _X_, to use an image 🏔 instead. 

2. Implement white space handling for the username textfield.

3. Set the background of the memory Card to be show an image 🏔 instead of just a color.<br/>
(tip: check out _CardCVCell.xib_ or _CardCVCell.swift_)

4. In the section [How to write good code](#how-to-write-good-code) we discussed the goal of writing small files, and the class _MemoryDataSourceAndDelegate_ with its almost 200 lines of code was mentioned. Can you split this class into several smaller classes that makes sense, so that no class is more than 100 lines?

5. Switch the position of the _Restart_ button with the _Quit_ button.<br/>
(tip: don't delete the buttons... 😜 then you have to recreate the _Segues_ ...)

6. Save the best score (lowest _clickCount_ for each level) a user has scored and present this score in the _GameOverVC_. <br/>
(Tip: Checkout [NSUserDefaults](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSUserDefaults_Class/) for saving.)

7. It is currently possible for a user to flip a third card while the flip animation of the two previous cards has not yet finished. Address this issue.

8. Create a timer ⏲ [NSTimer](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/) that counts the time for a game session. Display this time in the _GameOverVC_ after the game has finished.

## 🦄 Bring it on
1. Display a timer ⏲ [NSTimer](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSTimer_Class/) (could be the one you created in task 8 in [I think I've got a good grip of it](#i-think-ive-got-a-good-grip-of-it) ) that is counting upwards in the _GameVC_ showing elapsed time ⏰ since game start.

2. When you press the _Restart_ button from _GameOverVC_ the cards will have the same position as before, this makes it easy to cheat! Your task is to shuffle the cards before restarting the game.  

3. Change the feedback message in _GameOverVC_ from _Well done_ to a dynamic title that changes according to how well it went. Some examples strings: _Awesome_, _Not sooo bad_, _That was Horrible_ etc. This string should not be directly dependent on only _Level_, or only _clickCount_, but rather..?

4. Currently the project uses hard coded keys for localized strings (the key itself is a string), which is the standard iOS pattern - but it smells! Instead you can introduce an Enum for all the localized strings. So that you will be able to write something like this: 
```swift
	restartButton.setLocalizedTitle(LocalizedStrings.Restart)
```
(Tip: Either you do this by yourself, or you can use [SwiftGen](https://github.com/AliSoftware/SwiftGen) for this, if you know how to install it...)

5. Add some Error ☠ handling, e.g  displaying a message if the Instagram username doesn't exist, or if no images could be loaded.

6. Make it possible to set the number of cards to a custom number. Currently the number of cards are determined base on which difficulty level you chose in the SettingsVC. 

7. Enable Landscape mode for all the views.

8. Fetch the images from another source than Instagram. Maybe you can fetch the images from FourSquare, using its [API](https://developer.foursquare.com/), [Flickr](https://www.flickr.com/services/api/) or [Twitter](https://dev.twitter.com/rest/public). Please note all the above mentioned alternative image sources require an API token/secret. So you have to create those in order to use the APIs. Then you have to change the JSON parsing of the _Cards_ model. You also need to modify the _Photos_ 📷 route in the _Router_ class to go against the correct URL.

# Authors 

## [Alexander Cyon](https://github.com/sajjon) [@Redrum_237](https://twitter.com/redrum_237) 
Alexander has worked with app development since 2010 and enjoys Android but loves iOS 😍.

## [Miriam Tisander](https://github.com/MiriamTisander)
Miriam has worked with iOS development since 2015, she loves Swift but is currently working with Objective-C 😭🔫. 

