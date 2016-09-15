//
//  VNShare.swift
//  FFSwift
//
//  Created by Cong Can NGO on 8/15/16.
//  Copyright © 2016 Vicnisoft. All rights reserved.
//

import Foundation
import MessageUI

typealias VNShareCompletion = (success: Bool, errorMessage: String?)->Void

class VNShare : NSObject   {
    
    
    static let sharedInstance = VNShare()
    
    
    func sendViaMessage(message value: String, params: [String: AnyObject]?, recipients : [String]?,  fromController: UIViewController,completion: VNShareCompletion?){
        
        if MFMessageComposeViewController.canSendText() == false {
            if let block = completion {
                block(success: false,errorMessage: nil)
            }
        } else {
            let mVC = MFMessageComposeViewController.init()
            mVC.body = value
            mVC.recipients = recipients
            mVC.messageComposeDelegate = self
            
            if MFMessageComposeViewController.canSendAttachments() {
                
            }
            
            fromController.presentViewController(mVC, animated: true, completion: { () -> Void in
                
            })
            
        }
        
    }
    
    
    func sendViaEmail(title value: String?, body: String, isHTML: Bool , params: [String: AnyObject]?, recipients : [String]?,  fromController: UIViewController, completion: VNShareCompletion?){
        
        if MFMailComposeViewController.canSendMail() == false {
            if let block = completion {
                block(success: false,errorMessage: nil)
            }
        } else {
            let mVC = MFMailComposeViewController.init()
            mVC.title = value
            mVC.setMessageBody(body, isHTML: isHTML)
            mVC.setToRecipients(recipients)
            mVC.mailComposeDelegate = self
            
            if MFMessageComposeViewController.canSendAttachments() {
                
            }
            
            fromController.presentViewController(mVC, animated: true, completion: { () -> Void in
                
            })
            
        }
        
    }
    
    
    
    func shareViaOthers(title value: String, stringUrl: String, fromController: UIViewController) {
        
        if let url = NSURL(string: stringUrl) {
            let objectsToShare = [value, url]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            fromController.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    
    
}

extension VNShare : MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {

        controller.dismissViewControllerAnimated(true, completion: nil)

    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
}



