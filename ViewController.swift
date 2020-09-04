//
//  ViewController.swift
//  API Demo
//
//  Created by Rob Percival on 21/06/2016.
//  Copyright © 2016 Appfish. All rights reserved.
//

import UIKit

// NOTE: (Ted)  Most of iOS app development is about asking a simple question.
//              What happens if I don't have X?
//
//              Writing code is usually some form of methodically stepping through all of the things
//              that might not go the way you want them to, and making sure you handle that scenario.
//
//              In this app, a few things can go wrong, and we need to handle those things gracefully.
//
//              1. What if the developer didn't hook up the IBOutlets?
//              2. What if they did hook up the outlets, but there's no text entered when someone hits the submit button?
//              3. What if the text they entered is a valid city, but no results are returned? What do you display?
//
//              And so on.
//
//              Always keep asking "what does this do when things don't go well?" and then make sure there's some logic for it.

class ViewController: UIViewController {

    // NOTE: (Ted)  I prefer to do these as plain optionals to give you more control over what happens if there is no underlying value at the time they are
    //              accessed.
    //
    //              For example, you can do a thing called an assertionFailure which makes it so the app will crash in a debug build but
    //              won't crash in a production build.
    //
    //              Then you can define a separate behavior for a production build that keeps the user going without crashing the app (if it's appropriate).
    //
    //              Lots of dumb people think crashing is always the worst thing that can happen in an app. It's NOT! Crashing is a system behavior specifically
    //              designed to prevent a far worse outcome, namely data corruption. Also, crashing can help you find where a problem occurs since the debugger will
    //              take you straight to the line of code with the problem.
    @IBOutlet var resultLabel: UILabel?
    @IBOutlet var cityTextField: UITextField?

    @IBAction func submit(_ sender: AnyObject) 
    {
        // NOTE: (Ted)  The two labels will successfully unwrap if they are hooked up in interface builder. You will notice that
        //              the variables appear as plain non-optional instances after this statement.
        //
        //              I generally prefer to unwrap all the optional stuff up front. Then I know I'm dealing with plain variables downstream.
        //              It's much easier to reason about things when you know they definitely have a value. It also simplifies the code following the
        //              point where you do the unwrapping. From that point forward, there are no surprises.
        guard 
            let resultLabel = resultLabel,
            let cityTextField = cityTextField
        else
        {
            // NOTE: (Ted)  In a debug build, the app should crash at this line if you didn't hook up one of the IBOutlets.
            assertionFailure("All IBOutlets need to be hooked up in order for this app to function as intended")

            // NOTE: (Ted)  Code from this line to the return statement only gets hit if it's a production build,
            //              so an alert would only appear if you didn't hook up the outlets and you shipped the app to the 
            //              App Store. It's an uncommon scenario, since you'll probably find the problem in a debug build,
            //              but technically it can happen.
            let alert = UIAlertController(title: nil, 
                                          message: "Your developer didn't hook up the interface builder outlets. This will only appear in a production build", 
                                          preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default) 
            alert.addAction(okayAction)
            present(alert, animated: true, completion: nil)
            return
        }

        // NOTE: (Ted)  Unwrapping with a guard gracefully handles the situation where someone didn't enter text into the textfield. If you use (!), the app will
        //              crash whenever there's no text in that textfield, and crashing isn't the right thing to do in that scenario. Especially when there's a better
        //              non-crashing alternative like simply asking people to enter some data.
        guard let cityText = cityTextField.text else
        {
            resultLabel.text = "Please enter a city"
            return
        }

        // NOTE: (Ted)  I don't usually get too persnickety about code readability, but having the right indentation levels does make a big difference.
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=" + cityText.replacingOccurrences(of: " ", with: "%20") + ",uk&appid=08e64df2d3f3bc0822de1f0fc22fcb2d") 
        {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in // URLSession.shared().dataTask(with: url) { (data, response, error) is now URLSession.shared.dataTask(with: url) { (data, response, error)
                
                if error != nil {
                    
                    print(error!)
                    
                } else {
                   
                    // NOTE: (Ted)  You can just use the same variable name when unwrapping with an if-let statement.
                    //              No need to get fancy and come up with new names.
                    if let data = data 
                    {
                        do {
                            
                            let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject // Added "as anyObject" to fix syntax error in Xcode 8 Beta 6
                            
                            print(jsonResult)
                            
                            print(jsonResult["name"])
                           
                            if let description = ((jsonResult["weather"] as? NSArray)?[0] as? NSDictionary)?["description"] as? String 
                            {
                                // NOTE: (Ted)  Most of the time, you'll go with async when submitting code blocks to different 
                                //              dispatch queues. That's because async will simply schedule the code to get run later
                                //              and won't stall the CPU running your code immediately.
                                //
                                //              Since this doesn't need to happen right away, scheduling it for the next available pass on
                                //              the UI thread is more appropriate.
                                DispatchQueue.main.async { [weak self] in
                                    self?.resultLabel.text = description
                                }
                            }
                            
                        } catch 
                        {
                            print("JSON Processing Failed")
                        }
                    }
                }
                
            }
        
            task.resume()
            
        } else 
        {
            resultLabel.text = "Couldn't find weather for that city - please try another."
        }
        
    }


    // NOTE: (Ted)  I usually get rid of boilerplate class overrides that aren't used.
    //              You can always bring back viewDidLoad if you need to do something there.

}

