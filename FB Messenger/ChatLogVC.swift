//
//  ChatLogVC.swift
//  FB Messenger
//
//  Created by Tan Wei Liang on 22/11/2017.
//  Copyright © 2017 Tan Wei Liang. All rights reserved.
//

import Foundation
import UIKit

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let cellId = "cellId"
    
    var messages: [Message]?
    
    var friend: Friend? {
        didSet {
            navigationItem.title = friend?.name
            
            messages = friend?.messages?.allObjects as? [Message]
            
            messages = messages?.sorted(by: {$0.date!.compare($1.date!) == .orderedAscending})
        }
    }
    
    //setting for the messageInputContainer
    let messageInputContainer : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    //setting for the inputTextField
    let inputTextField : UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message....."
        return textField
    }()
    
    //setting for the sendButton
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSend() {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let message = FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, context: context, mintuesAgo: 0, isSender: true)
        
        do {
            try context.save()
            
            messages?.append(message)
            
            let item = messages!.count - 1
            let insertionIndexPath = NSIndexPath(item: item, section: 0)
            
            collectionView?.insertItems(at: [insertionIndexPath as IndexPath])
            collectionView?.scrollToItem(at: insertionIndexPath as IndexPath, at: .bottom, animated: true)
            inputTextField.text = nil
            
        } catch let err {
            print(err)
        }
    }
    
    var bottomConstraint: NSLayoutConstraint?
    
    @objc func simulate() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let message = FriendsController.createMessageWithText(text: "Here's a text message that was sent a few minutes ago...", friend: friend!, context: context, mintuesAgo: 1)
        
        do {
            try context.save()
            
            messages?.append(message)
            
            messages = messages?.sorted(by: {$0.date!.compare($1.date!) == .orderedAscending})
            
            if let item = messages?.index(of: message) {
                let receivingIndexPath = NSIndexPath(item: item, section: 0)
                collectionView?.insertItems(at: [receivingIndexPath as IndexPath])
            }
            
        } catch let err {
            print(err)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulator", style: .plain, target: self, action: #selector(simulate))
        
        //need to hide the tab bar in order to show the text message field
        self.tabBarController?.tabBar.isHidden = true
        
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        view.addSubview(messageInputContainer)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainer)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainer)
        
        bottomConstraint = NSLayoutConstraint(item: messageInputContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        
        setupInputComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            print(keyboardFrame as Any)
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
                if isKeyboardShowing {
                    //                    let lastItem = self.fetchedResultsControler.sections![0].numberOfObjects - 1
                    //                    let indexPath = NSIndexPath(item: lastItem, section: 0)
                    //                    self.collectionView?.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
                    //                    or
                    let viewheight = self.view.frame.height - keyboardFrame!.height
                    let yOffset = CGFloat( (Float( (self.collectionView?.contentSize.height)! - (viewheight)  ) ) )
                    let contentOffset = CGPoint(x: 0, y: yOffset)
                    self.collectionView?.setContentOffset(contentOffset, animated: true)
                    
                }
                
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        messageInputContainer.addSubview(inputTextField)
        messageInputContainer.addSubview(sendButton)
        messageInputContainer.addSubview(topBorderView)
        
        messageInputContainer.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField,sendButton)
        messageInputContainer.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainer.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        
        messageInputContainer.addConstraintsWithFormat(format:"H:|[v0]|", views: topBorderView)
        messageInputContainer.addConstraintsWithFormat(format:"V:|[v0(0.5)]", views: topBorderView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = messages?.count {
            return count
        }
        
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        
        cell.messageTextView.text = messages?[indexPath.item].text
        
        if let message = messages?[indexPath.item], let messageText = message.text, let profileImageName = message.friend?.profileImageName {
            
            cell.profileImageView.image = UIImage(named: profileImageName)
            
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)], context: nil)
            
            if !message.isSender {
                
                //incoming sending message
                cell.messageTextView.frame = CGRect(x:48 + 8, y: 0 , width: estimatedFrame.width + 16 , height: estimatedFrame.height + 13)
                
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: 0 , width: estimatedFrame.width + 20 + 16, height: estimatedFrame.height + 13)
                
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                cell.profileImageView.isHidden = false
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
                cell.messageTextView.textColor = UIColor.black
                
            } else {
                
                //outgoing sending message
                cell.messageTextView.frame = CGRect(x:view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0 , width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4 , width: estimatedFrame.width + 16 + 8 + 10, height: estimatedFrame.height + 20 + 6)
                
                cell.profileImageView.isHidden = true
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
                cell.messageTextView.textColor = UIColor.white
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if let messageText = messages?[indexPath.item].text {
            let size = CGSize(width: 250, height: 1200)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18)], context: nil)
            
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        
        return CGSize(width: view.frame.width, height: 100)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //adjust the layout of the edge of the UI
        return UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
    }
    
}

class ChatLogMessageCell: BaseCell {
    
    //setting for the messageTextView
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Sample message "
        textView.backgroundColor = UIColor.clear
        textView.isEditable = false
        return textView
    }()
    
    //setting for the textBubbleView
    let textBubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        return view
    }()
    
    //setting for the profileImageView
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    //setting for the tail of the chat bubble
    static let grayBubbleImage = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    static let blueBubbleImage = UIImage(named: "bubble_blue")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
    
    //setting for the bubbleImageView
    let bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "bubble_gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26)).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor(white: 0.90, alpha: 1)
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(textBubbleView)
        addSubview(messageTextView)
        
        addSubview(profileImageView)
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
        profileImageView.backgroundColor = UIColor.red
        
        textBubbleView.addSubview(bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "H:|[v0]|", views: bubbleImageView)
        textBubbleView.addConstraintsWithFormat(format: "V:|[v0]|", views: bubbleImageView)
        
    }
}

