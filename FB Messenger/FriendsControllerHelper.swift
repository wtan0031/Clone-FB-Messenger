//
//  FriendsControllerHelper.swift
//  FB Messenger
//
//  Created by Tan Wei Liang on 21/11/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import UIKit
import CoreData

extension FriendsController {
    
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            do {
                let entityNames = ["Friend", "Message"]
                
                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    
                    let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                    
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                try(context.save())
                
            }catch let err {
                print(err)
            }
        }
    }
    
    //the place to key in your message
    func setupData() {
        //you need to clear the data so there will be no more duplicated chat log
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            let jeff = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            jeff.name = "Jeff Bezos"
            jeff.profileImageName = "Jeff"
            
            let gates = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            gates.name = "Bill Gates"
            gates.profileImageName = "BillGates"
            
            let kendall = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            kendall.name = "Kendall Jenner"
            kendall.profileImageName = "VS11"
            
            let gigi = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
            gigi.name = "Gigi"
            gigi.profileImageName = "VS16"
            
            createCindyMessagesWithContext(context: context)
            
            FriendsController.createMessageWithText(text: "Do you want to buy or sell anything? You have come to the right person. Welcome to Amazon!!!", friend: jeff, context: context, mintuesAgo: 0)
            FriendsController.createMessageWithText(text: "Hi, I'm the founder of Microsoft, and the richest man in the world at the same time.", friend: gates, context: context, mintuesAgo: 10)
            FriendsController.createMessageWithText(text: "Good morning, we need to talk.", friend: gigi, context: context, mintuesAgo: 60 * 24 * 3)
            FriendsController.createMessageWithText(text: "Like and follow my instagram please...", friend: kendall, context: context, mintuesAgo: 60 * 24 * 3)
            
            do {
                try(context.save())
            } catch let err {
                print(err)
            }
        }
        loadData()
    }
    
    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            if let friends = fetchFriends(){
                
                messages = [Message]()
                
                for friend in friends {
                    
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                    // sort the user by their name
                    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                    //limit the request to 1
                    fetchRequest.fetchLimit = 1
                    
                    do {
                        let fetchedMessage = try(context.fetch(fetchRequest)) as? [Message]
                        messages?.append(contentsOf: fetchedMessage!)
                    } catch let err {
                        print(err)
                    }
                }
                messages = messages?.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
            }
            
            // sort the message by the date(time)
            
        }
    }
    
    
    //testing for the isSender func
    private func createCindyMessagesWithContext(context: NSManagedObjectContext) {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        let context = delegate?.persistentContainer.viewContext
        let cindy = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context!) as! Friend
        cindy.name = "Cindy Burma"
        cindy.profileImageName = "VS14"
        
        FriendsController.createMessageWithText(text: "Good Morning", friend: cindy, context: context!, mintuesAgo: 8 * 60 * 24)
        FriendsController.createMessageWithText(text: "Thanks for accepting the friend request!", friend: cindy, context: context!, mintuesAgo: 7 * 60 * 24)
        FriendsController.createMessageWithText(text: "I just new to Malaysia, do you feel free to show me around?", friend: cindy, context: context!, mintuesAgo: 10)
        FriendsController.createMessageWithText(text: "Thank you very much!!", friend: cindy, context: context!, mintuesAgo: 8)
        FriendsController.createMessageWithText(text: "I will treat you dinner after this!!", friend: cindy, context: context!, mintuesAgo: 7)
        FriendsController.createMessageWithText(text: "Noted, thank you so much!!!", friend: cindy, context: context!, mintuesAgo: 0)
        
        //response message
        FriendsController.createMessageWithText(text: "Good morning?? Is there anything that I can help you?", friend: cindy, context: context!, mintuesAgo: 20, isSender: true)
        FriendsController.createMessageWithText(text: "Erm.....okay, but I have to go early... ", friend: cindy, context: context!, mintuesAgo: 9, isSender: true)
        FriendsController.createMessageWithText(text: "Its okay, you can save it.", friend: cindy, context: context!, mintuesAgo: 6, isSender: true)
        FriendsController.createMessageWithText(text: "By the way please take note that, there will be rain , please bring along your umbrella", friend: cindy, context: context!, mintuesAgo: 5, isSender: true)
        
    }
    
    private func fetchFriends() -> [Friend]? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.persistentContainer.viewContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            
            do {
                return try context.fetch(request) as? [Friend]
            } catch let err{
                print(err)
            }
        }
        return nil
    }
    
    static func createMessageWithText(text:String, friend:Friend,context: NSManagedObjectContext, mintuesAgo: Double, isSender: Bool = false) -> Message {
        
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.friend = friend
        message.text = text
        message.date = NSDate().addingTimeInterval(-mintuesAgo * 60) as Date
        message.isSender = NSNumber(value: isSender) as! Bool
        // your friend message will sort by the correct order (descending)
        friend.lastMessage = message
        return message
    }
}
//            or you can do it this way, note: parameter for texting and label the user

//            let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
//            message.friend = najib
//            message.text = "Selamat Pagi dan Salam Satu Malaysia, apa khabar adik?"
//            message.date = NSDate() as Date

//            let messageGates = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
//            messageGates.friend = blanca
//            messageGates.text = "Your assignment deadline is tomorrow"
//            messageGates.date = NSDate() as Date

// no longer using load data , cuz NSfetchResultsController has replace this






// can be exclude since you had already called it in your core data model (relationship)


//class Friend: NSObject {
//
//    var name: String?
//    var profileImageName: String?
//}
//
//class Message: NSObject {
//
//    var text: String?
//    var date: NSDate?
//
//    var friend: Friend?
//}
