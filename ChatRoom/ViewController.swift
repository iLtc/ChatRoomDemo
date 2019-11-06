//
//  ViewController.swift
//  ChatRoom
//
//  Created by Alan Luo on 11/2/19.
//  Copyright © 2019 iLtc. All rights reserved.
//

import UIKit

// Remember to import Firebase
import Firebase
import Messages

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // We need the next two lines to usefirestore
    let db = Firestore.firestore()
    var ref: DocumentReference? = nil
    
    var name = "Anonymous"
    
    // formatter is used to format date
    let formatter = DateFormatter()
    
    let messages = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        // We define the format of date here
        self.formatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // This method will pop up a window and ask the user for their name
        
        let alert = UIAlertController(title: "Your Name", message: "What is your name?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "Your Name"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            
            if (textField.text != "") {
                self.name = textField.text!
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "default")
        
        if (cell == nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "default")
        }
        
        let message = self.messages[self.messages.count - 1 - indexPath.row] as! Message;
        
        cell!.textLabel!.text = message.message
        cell!.detailTextLabel!.text = "\(message.name): \(message.time)"
        
        return cell!
    }

    @IBAction func sendButtonPressed(_ sender: Any) {
        if (self.textField.text == "") {
            alert("Error", "Please enter something before send the message!")
        } else {
            let message = self.textField.text
            
            // Add message, name, and time to firestore
            self.ref = db.collection("chatroom").addDocument(data: [
                "message": message,
                "name": self.name,
                "time": self.formatter.string(from: Date())
            ]) { err in
                if let err = err {
                    self.alert("Error", "Error adding document: \(err)")
                } else {
                    self.textField.text = ""
                    
                    self.refresh();
                }
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        refresh();
    }
    
    func alert(_ title: String, _ message: String) {
        // This method will pop up a window and show an error with title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
    
    func refresh() {
        self.messages.removeAllObjects()
        
        // Read data from the firestore
        db.collection("chatroom").order(by: "time").getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.alert("Error", "Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    let message = Message(data["message"] as! String, withName: data["name"] as! String, andTime: data["time"] as! String)
                    
                    self.messages.add(message)
                }
            }
            
            self.tableView.reloadData()
        }
    }
}

