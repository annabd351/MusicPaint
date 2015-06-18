//
//  ViewController.swift
//  Music Paint
//
//  Created by Anna Dickinson on 5/28/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

class ViewController: GLKViewController {
    
    @IBOutlet var spriteRenderingView: SpriteRenderingView!
    
    @IBAction func imageButtonPressed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    var spotifyManager: SpotifyManager!
    var effect: SwirlEffect<SwirlEffectState>?
    
    @IBAction func clearButtonPressed(sender: AnyObject) {
        spriteRenderingView.clear()
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBAction func playButtonPressed(sender: AnyObject) {
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
        
        playButton.setTitle("Play", forState: UIControlState.Normal)
        
        spotifyManager = SpotifyManager(errorHandler: handleSpotifyError)
        spotifyManager.playbackDelegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        effect = SwirlEffect(initialState: SwirlEffectState(), spriteBuffer: spriteRenderingView.spriteBuffer, bounds: view.frame, spectrumArrays: spotifyManager.spectrumArrays)
        effect?.currentState.eraseColor = view.backgroundColor!.simColor
    }
}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(controller: GLKViewController!) {
        effect?.update(GlobalSimTime, timestep: Float(controller.timeSinceLastUpdate))
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        spriteRenderingView.sampleSourceTextureImage = image
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ViewController: SPTAuthViewDelegate {
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        playButtonPressed(self)
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
    }
}

extension ViewController: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            effect?.start()
            playButton.setTitle("Stop", forState: UIControlState.Normal)
        }
        else {
            effect?.stop()
            spotifyManager.resetSpectrumArrays()
            playButton.setTitle("Play", forState: UIControlState.Normal)
        }
    }
}