//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Anna Hull on 2/6/16.
//  Copyright © 2016 Anna Hull. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var session: AVAudioSession!
    var audioPlayer:AVAudioPlayer!
    var echoPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
        audioPlayer = try! AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        echoPlayer = try! AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stopReset() {
        audioPlayer.stop()
        audioEngine.stop()
        echoPlayer.stop()
        audioEngine.reset()
        audioPlayer.currentTime = 0
        echoPlayer.currentTime = 0
    }

    func playAudioWithVariableSpeed(rate: Float) {
        stopReset()
        audioPlayer.rate = rate
        audioPlayer.play()
    }
    
    @IBAction func playSlowAudio(sender: UIButton) {
        playAudioWithVariableSpeed(0.5)
    }

    @IBAction func playFastAudio(sender: AnyObject) {
        playAudioWithVariableSpeed(1.5)
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        stopReset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        
        audioPlayerNode.play()
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    //inspired by http://sandmemory.blogspot.com/2014/12/how-would-you-add-reverbecho-to-audio.html
    @IBAction func playEcho(sender: UIButton) {
        
        //stop and reset any running audio players
        stopReset()
        
        //set the delay effect
        let delay:NSTimeInterval = 0.5
        var echoOffset:NSTimeInterval
        echoOffset = echoPlayer.deviceCurrentTime + delay
        echoPlayer.volume = 0.5
        
        audioPlayer.play()
        echoPlayer.playAtTime(echoOffset)
    }
    
    //inspired by https://github.com/credli/PitchPerfect
    @IBAction func playReverb(sender: UIButton) {
        stopReset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let reverbEffect = AVAudioUnitReverb()
        reverbEffect.loadFactoryPreset(.Cathedral)
        reverbEffect.wetDryMix = 50
        
        audioEngine.attachNode(reverbEffect)
        
        audioEngine.connect(audioPlayerNode, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        
        audioPlayerNode.play()
    }
    
    @IBAction func stopAllAudio(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
        echoPlayer.stop()
        audioEngine.reset()
        audioPlayer.currentTime = 0
        echoPlayer.currentTime = 0
    }

}
