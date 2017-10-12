# InteractiveTransitioningContainer

A UIKit custom container component that supports interactive transitions for switching between its containees.

## Motivation

In date of creating this project there is no direct support nor official documentation for creating your own custom container that would support interactive transitions between its child view controllers. If you also stand before this challenge, you are at the right place.

## Example of usage

To provide an example of using the `InteractiveTransitioningContainer` skeleton class, we implemented `SwipeToSlideInteractiveTransitioningContainer` that supports interactive transitions by swiping a screen. This container is also a part of this repository, so you can directly use it if this is what you are looking for.

`SwipeToSlideInteractiveTransitioningContainer` container uses `SwipeToSlideTransitionAnimation` custom animation for switching between two child controllers. Interactivity is managed by a custom `SwipeToSlidePanGestureInteractiveTransition` that subclasses `InteractiveTransitionContainerPercentDrivenInteractiveTransition`.

To use `SwipeToSlideInteractiveTransitioningContainer` as a container, you just need to hand its initializer the array of its child viewControllers. You can set its delegate to listen to transition performed event (there is a boolean flag to differ between cancelled and successful transition). See following `AppDelegate` code as an example.

```swift
//
//  AppDelegate.swift
//  InteractiveTransitioningContainerSampleProject
//
//  Created by Milan Nosáľ on 03/02/2017.
//  Copyright © 2017 Svagant. All rights reserved.
//

import UIKit
import InteractiveTransitioningContainer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SwipeToSlideInteractiveTransitioningContainerDelegate {

    var window: UIWindow?
    
    let vcs = [
        AppDelegate.vc(bgColor: .blue),
        AppDelegate.vc(bgColor: .cyan),
        AppDelegate.vc(bgColor: .green),
        AppDelegate.vc(bgColor: .red)
    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let container = SwipeToSlideAutolayoutInteractiveTransitioningContainer(with: vcs)
        container.delegate = self
        
        self.window!.rootViewController = container
        self.window!.makeKeyAndVisible()

        return true
    }
    
    static func vc(bgColor: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = bgColor
        return vc
    }
    
    func swipeToSlideInteractiveTransitioningContainer(_ swipeToSlideInteractiveTransitioningContainer: SwipeToSlideInteractiveTransitioningContainer, didFinishTransitionTo viewController: UIViewController, wasCancelled: Bool) {
        // callback for a finished transition event
    }

}
```

If `SwipeToSlideInteractiveTransitioningContainer` is not what you are looking for, you can always subclass `InteractiveTransitioningContainer` yourself using `SwipeToSlideInteractiveTransitioningContainer` as an example. If you should decide to do so, we recommend to start by reading the two articles mentioned in Acknowledgements below.

## Installation using CocoaPods

To install using CocoaPods, just add the following line to your Podfile:

```
pod 'InteractiveTransitioningContainer'
```

## Acknowledgements

Joachim Bondo wrote a great article about [Custom Container View Controller Transitions](https://www.objc.io/issues/12-animations/custom-container-view-controller-transitions/). We recommend reading it as first resource, if you want to implement your own custom container (even when using our skeleton).

Alek Åström continued where Joachim Bondo left, and added a support for interactive custom transitions. Read his [blog entry](http://www.iosnomad.com/blog/2014/5/12/interactive-custom-container-view-controller-transitions) to learn more.

Our work builds upon these two.
