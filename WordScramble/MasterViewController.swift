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
}

