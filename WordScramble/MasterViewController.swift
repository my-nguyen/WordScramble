//
//  MasterViewController.swift
//  WordScramble
//
//  Created by My Nguyen on 8/6/16.
//  Copyright © 2016 My Nguyen. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {

    var objects = [String]()
    var allWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new UIBarButtonItem using the "add" system icon, and configure it to run promptForAnswer() method when tapped
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(promptForAnswer))

        // get the full path to file named "start.txt"
        if let filePath = NSBundle.mainBundle().pathForResource("start", ofType: "txt") {
            // load the whole file contents into a giant string
            if let fileContents = try? String(contentsOfFile: filePath, usedEncoding: nil) {
                // based on newline, split the giant string into an array of strings
                allWords = fileContents.componentsSeparatedByString("\n")
            }
        } else {
            allWords = ["silkworm"]
        }

        startGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

    func startGame() {
        // shuffle all words
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        // set title as first word
        title = allWords[0]
        // remove all from objects, which is supplied by Xcode template
        objects.removeAll(keepCapacity: true)
        // reload tableView, which is instance variable of parent class UITableViewController
        tableView.reloadData()
    }

    func promptForAnswer() {
        // create a UIAlertController
        let alertController = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .Alert)
        // add an editable text field to the UIAlertController
        alertController.addTextFieldWithConfigurationHandler(nil)
        // trailing closure syntax: handler, the very last parameter, is an anonymous closure (callback), so it becomes a block of code itself
        // self (the current view controller) and alertController are referenced inside the closure, so they need to be declared as unowned (weak) reference to avoid the circular-reference problem
        // self is declared because the closure calls submitAnswer() method which is defined in the current view controller
        // the closure accepts a UIAlertAction as parameter
        // "in" marks the actual beginning of the closure code
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, alertController] (action: UIAlertAction!) in
            let answer = alertController.textFields![0]
            self.submitAnswer(answer.text!)
        }
        // add submitAction to the UIAlertController
        alertController.addAction(submitAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

    func submitAnswer(answer: String) {
        let lowerAnswer = answer.lowercaseString
        let title: String
        let message: String

        if wordIsPossible(lowerAnswer) {
            if wordIsOriginal(lowerAnswer) {
                if wordIsReal(lowerAnswer) {
                    // add answer to the start of objects
                    objects.insert(answer, atIndex: 0)
                    // tell tableView that a new row has been placed at row 0 and section 0, so it can animate the new cell appearing
                    // this is done in lieu of calling reloadData(), which is inefficient
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    // withRowAnimation = .Automatic: use standard system animation, which is to slide the new row in from the top
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    // answer is valid
                    return
                } else {
                    title = "Word not recognized"
                    message = "You can't just make them up, you know!"
                }
            } else {
                title = "Word used already"
                message = "Be more original!"
            }
        } else {
            title = "Word not possible"
            message = "You can't spell that word from '\(self.title!.lowercaseString)'!"
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }

    func wordIsPossible(word: String) -> Bool {
        // tmp is a working copy of word, with all letters converted to lowercase
        var tmp = title!.lowercaseString
        // extract and loop through each character in word
        for letter in word.characters {
            // find the letter in tmp
            if let index = tmp.rangeOfString(String(letter)) {
                // remove letter from tmp
                tmp.removeAtIndex(index.startIndex)
            } else {
                return false
            }
        }
        return true
    }
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    func wordIsReal(word: String) -> Bool {
        // UITextChecker is an iOS class to spot spelling errors
        let checker = UITextChecker()
        // createa range between 0 and word's length
        let range = NSMakeRange(0, word.characters.count)
        // param 1: word
        // param 2: range to scan (the whole string)
        // param 5: language (English)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
}

