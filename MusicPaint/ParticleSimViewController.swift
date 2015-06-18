//
//  ParticleSimViewController.swift
//  Music Paint
//
//  Created by Anna Dickinson on 5/28/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

class ParticleSimViewController: GLKViewController {
    

    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var spriteRenderingView: SpriteRenderingView!
    
    func handleGesture(sender: UIGestureRecognizer) {
        if let tapGestureRecognizer = sender as? UITapGestureRecognizer {
//            for index in 0..<tapGestureRecognizer.numberOfTouches() {
//                let touchLocationInView = tapGestureRecognizer.locationOfTouch(index, inView: spriteRenderingView)
//                
//                effect?.addEmitterAtPosition(Position.new(touchLocationInView))
//            }
        }
    }
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    var spotifyManager: SpotifyManager!
    var effect: PulseEffect<PulseEffectState>?
    
    @IBOutlet weak var spotifyButton: UIButton!
    @IBAction func spotifyButtonPressed(sender: AnyObject) {
        if spotifyManager.needsAuthentication {
            let sptAuthViewController = SPTAuthViewController.authenticationViewController()
            sptAuthViewController.delegate = self
            presentViewController(sptAuthViewController, animated: true, completion: nil)
            return
        }

        switch (spotifyManager.playState) {
        case .Playing:
            spotifyManager.stop()
            break
        case .Stopped:
            spotifyManager.play()
            break
        case .Unknown:
            spotifyManager.play()
            break
        }
    }
    
    func handleSpotifyError(error: NSError) {
        println(__FUNCTION__, "Spotify error: \(error.localizedDescription)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spriteRenderingView.particleTextureImage = UIImage(named:"ParticleTexture")
        spriteRenderingView.sampleSourceTextureImage = UIImage(named: "Eye")
        
        self.delegate = self
        
        spotifyButton.setTitle("Play", forState: UIControlState.Normal)
        
        spotifyManager = SpotifyManager(errorHandler: handleSpotifyError)
        spotifyManager.playbackDelegate = self
        
        spriteRenderingView.clearFramebufferBeforeDrawing = true
    }
    
    override func viewDidAppear(animated: Bool) {
        var initialEffectState = PulseEffectState()
    }
}


extension ParticleSimViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(controller: GLKViewController!) {
        effect?.update(GlobalSimTime, timestep: Float(controller.timeSinceLastUpdate))
    }
}

extension ParticleSimViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        spriteRenderingView.sampleSourceTextureImage = image
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ParticleSimViewController: SPTAuthViewDelegate {
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        spotifyButtonPressed(self)
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
    }
}

extension ParticleSimViewController: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
//            effect = PulseEffect<AnySimulationState>(spriteRenderingView: spriteRenderingView)
//            effect!.fillRect(spriteRenderingView.frame)
//            effect!.spectrumArrays = spotifyManager.spectrumArrays

            spotifyButton.setTitle("Stop", forState: UIControlState.Normal)
        }
        else {
            spotifyButton.setTitle("Play", forState: UIControlState.Normal)
        }
    }
}