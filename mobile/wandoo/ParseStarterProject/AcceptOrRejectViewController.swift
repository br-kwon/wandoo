//
//  AcceptOrRejectViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Brian Kwon on 1/2/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class AcceptOrRejectViewController: UITableViewController {
    
    @IBOutlet var interestedTable: UITableView!
    var allInterestedInfo: Array<NSMutableDictionary>?
    var interestedModel = InterestedModel.sharedInterestedInstance
    var userModel = UserModel()
    
    var myWandooInfo: NSDictionary?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInterestedPeople { () -> Void in
            print("poop")

            for (index, interestedPeople) in self.allInterestedInfo!.enumerate() {
                if(interestedPeople["selected"] as! Int == 1) {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    let cell = self.interestedTable.cellForRowAtIndexPath(indexPath) as! InterestedCell
                    cell.accept.backgroundColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 0.5)
                }
            }
        }
    }
    
    @IBAction func rejectButton(sender: UIButton) {
        if(sender.backgroundColor != UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 0.5)){
            let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
            let cell = interestedTable.cellForRowAtIndexPath(indexPath)
            let wandooID = allInterestedInfo![sender.tag]["wandooID"] as! Int
            let userID = allInterestedInfo![sender.tag]["userID"] as! Int
            interestedModel.acceptedOrRejected(wandooID, userID: userID, accepted: false)
            sender.backgroundColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 0.5)
            cell!.userInteractionEnabled = false
        }
    }
    
    @IBAction func acceptButton(sender: UIButton) {
        if(sender.backgroundColor != UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 0.5)){
            let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
            let cell = interestedTable.cellForRowAtIndexPath(indexPath)
            let wandooID = allInterestedInfo![sender.tag]["wandooID"] as! Int
            let userID = allInterestedInfo![sender.tag]["userID"] as! Int
            interestedModel.acceptedOrRejected(wandooID, userID: userID, accepted: true)
            sender.backgroundColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 0.5)
            cell!.userInteractionEnabled = false
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let interestedCell = tableView.dequeueReusableCellWithIdentifier("interestedCell", forIndexPath: indexPath) as! InterestedCell
        if self.allInterestedInfo![indexPath.row]["selected"] as! Int == 1 {
            interestedCell.accept.backgroundColor = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 0.5)
        }
        interestedCell.name.text = self.allInterestedInfo![indexPath.row]["name"] as? String
        interestedCell.age.text = "Age: " + String(self.allInterestedInfo![indexPath.row]["age"]!)
        interestedCell.sex.text = "Sex: " + String(self.allInterestedInfo![indexPath.row]["sex"]!)
        if(self.allInterestedInfo![indexPath.row]["employer"] as? String != nil) {
            interestedCell.employer.text = "Employer" + String(self.allInterestedInfo![indexPath.row]["employer"]!)
        }
        else {
            interestedCell.employer.text = ""
        }
        interestedCell.reject.tag = indexPath.row
        interestedCell.accept.tag = indexPath.row
        
        interestedCell.picture.image = self.allInterestedInfo![indexPath.row]["profile_picture"] as? UIImage
        interestedCell.picture.layer.borderWidth = 1
        interestedCell.picture.layer.masksToBounds = false
        interestedCell.picture.layer.borderColor = UIColor.whiteColor().CGColor
        interestedCell.picture.layer.cornerRadius = interestedCell.picture.frame.height/2
        interestedCell.picture.layer.cornerRadius = interestedCell.picture.frame.width/2
        interestedCell.picture.clipsToBounds = true
        
        interestedCell.reject.layer.borderWidth = 1
        interestedCell.reject.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        interestedCell.accept.layer.borderWidth = 1
        interestedCell.accept.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        return interestedCell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if allInterestedInfo == nil {
            return 0
        } else {
            return allInterestedInfo!.count
        }
    }
    
    func getInterestedPeople(completion: () -> Void) {
        let wandooID = self.myWandooInfo!["wandooID"] as! Int
        
        interestedModel.getInterestedPeople(wandooID, completion: { (result) -> Void in

            self.allInterestedInfo = result as? Array<NSMutableDictionary>
            var count = 0
            dispatch_async(dispatch_get_main_queue()){
                for interestedPeople in self.allInterestedInfo! {
                    self.userModel.getUserInfoByUserID(interestedPeople["userID"] as! Int, completion: { (result) -> Void in
                        interestedPeople["name"] = result["name"]
                        interestedPeople["age"] = String(result["age"]!)
                        interestedPeople["sex"] = result["sex"]
                        interestedPeople["employer"] = result["employer"]
                        let picString = result["profile_picture"] as! String
                        let picURL = NSURL(string: picString)
                        if let pic = NSData(contentsOfURL: picURL!) {
                            interestedPeople["profile_picture"] = UIImage(data: pic)
                            count++
                            if count == self.allInterestedInfo!.count {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.interestedTable.reloadData()
                                }
                            }
                            
                        }
                        
                    })
                }
            }
        })
    }
    
}