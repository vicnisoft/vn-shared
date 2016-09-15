//
//  RecordViewController.swift
//  LiveStreamApp
//
//  Created by Cong Can NGO on 9/14/16.
//  Copyright © 2016 vns. All rights reserved.
//


import ReplayKit
import UIKit

class RecordViewController: UIViewController, RPPreviewViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: #selector(startRecording))
    }
    
    func startRecording() {
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.startRecordingWithMicrophoneEnabled(true) { [unowned self] (error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .Plain, target: self, action: #selector(self.stopRecording))
            }
        }
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.sharedRecorder()
        
        recorder.stopRecordingWithHandler { [unowned self] (preview, error) in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .Plain, target: self, action: #selector(self.startRecording))
            
            if let unwrappedPreview = preview {
                unwrappedPreview.previewControllerDelegate = self
                self.presentViewController(unwrappedPreview, animated: true, completion: nil)
            }
        }
    }
    
    func previewControllerDidFinish(previewController: RPPreviewViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
