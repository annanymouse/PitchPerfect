//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Anna Hull on 1/24/16.
//  Copyright © 2016 Anna Hull. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseResumeButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var pauseResumeBool: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingInProgress.text = "Tap to Record"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        //hide the stop button
        stopButton.hidden = true
        recordButton.enabled = true
        recordingInProgress.text = "Tap to Record"
        recordingInProgress.hidden = false
        pauseResumeButton.setBackgroundImage(UIImage(named: "pause_80_blue.png"), forState: UIControlState.Normal)
        pauseResumeBool = true
    }

    @IBAction func recordAudio(sender: UIButton) {
        recordButton.enabled = false
        stopButton.hidden = false
        recordingInProgress.text = "Recording"
        print("in recordAudio")
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            print("Recording was not successful")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    @IBAction func pauseResume(sender: UIButton) {
        if (pauseResumeBool == true) {
            audioRecorder.pause()
            recordingInProgress.text = "Recording Paused"
            pauseResumeButton.setBackgroundImage(UIImage(named: "resume_80_blue.png"), forState: UIControlState.Normal)
        } else {
        audioRecorder.record()
        recordingInProgress.text = "Recording Resumed"
        pauseResumeButton.setBackgroundImage(UIImage(named: "pause_80_blue.png"), forState: UIControlState.Normal)
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
        
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        recordingInProgress.hidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }

}

