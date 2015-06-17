//
//  SpotifyManager.swift
//  Music Paint
//
//  Created by Anna Dickinson on 6/9/15.
//  Copyright (c) 2015 Wacky Banana Software. All rights reserved.
//

import UIKit

private let MusicPaintPlaylist = NSURL(string: "spotify:user:1248346814:playlist:2vjzaJmtHBvscVPBNTb55D")
private let DiskCacheSize: UInt = 1024 * 1024 * 64

struct SpectrumArrays {
    var left: UnsafeMutableBufferPointer<Float32>
    var right: UnsafeMutableBufferPointer<Float32>
    var maxMagnitudePtr: UnsafeMutablePointer<Float32>
    var maxFrequencyPtr: UnsafeMutablePointer<Float32>
    var timestampPtr: UnsafeMutablePointer<NSTimeInterval>
    
    var maxFrequency: Float32 { return maxFrequencyPtr.memory }
    var maxMagnitude: Float32 { return maxMagnitudePtr.memory }
    var timestamp: NSTimeInterval { return timestampPtr.memory }
}

class SpotifyManager: NSObject {
    var errorHandler: (NSError) -> ()
    
    let _spectrumArrays: SpectrumArrays    
    var spectrumArrays: SpectrumArrays? {
        if playState == .Playing {
            return _spectrumArrays
        }
        else {
            return nil
        }
    }
    
    init(errorHandler: (NSError) -> ()) {
        self.errorHandler = errorHandler

        let leftSpectrumArray = UnsafeMutableBufferPointer<Float32>(start: coreAudioController.spectrumData.leftPtr, count: coreAudioController.spectrumData.samples)
        let rightSpectrumArray = UnsafeMutableBufferPointer<Float32>(start: coreAudioController.spectrumData.rightPtr, count: coreAudioController.spectrumData.samples)
        
        _spectrumArrays = SpectrumArrays(left: leftSpectrumArray, right: rightSpectrumArray, maxMagnitudePtr: coreAudioController.spectrumData.maxMagnitudePtr, maxFrequencyPtr: coreAudioController.spectrumData.maxFrequencyPtr, timestampPtr: coreAudioController.spectrumData.timestampPtr)
    }

    enum PlayerState {
        case Playing
        case Stopped
        case Unknown
    }
    var playState: PlayerState {
        if let currentPlayer = player {
            return currentPlayer.isPlaying ? .Playing : .Stopped
        }
        else {
            return .Unknown
        }
    }
    
    var playbackDelegate: SPTAudioStreamingPlaybackDelegate? {
        didSet {
            player?.playbackDelegate = playbackDelegate
        }
    }
    
    private var coreAudioController = CoreAudioController()
    
    func play() {
        if playlistRequest == nil {
            createPlaylistRequest { self.play() }
            return
        }
        
        if playlistSnapshot == nil {
            createPlaylistSnapshot { self.play() }
            return
        }
        
        if player == nil {
            createPlayer { self.play() }
            return
        }
        
        let tracks = playlistSnapshot!.firstTrackPage.items
        var playOptions = SPTPlayOptions()
        playOptions.trackIndex = Int32((random() + Int(CACurrentMediaTime())) % tracks.count)

        coreAudioController.clearAudioBuffers()
        coreAudioController.resetSpectrumData()

        player!.playURIs(tracks, withOptions: playOptions) {
            (error: NSError?) in
            
            if error != nil {
                self.errorHandler(error!)
            }
        }
    }
    
    func stop() {
        player?.stop {
            (error: NSError?) in

            if error != nil {
                self.errorHandler(error!)
            }
        }
        
        coreAudioController.clearAudioBuffers()
        coreAudioController.resetSpectrumData()
    }
    
    var needsAuthentication: Bool {
        if let currentSession = SPTAuth.defaultInstance().session where currentSession.isValid() {
            return false
        }
        else {
            return true
        }
    }

    private var session: SPTSession {
        assert(needsAuthentication == false, "SpotifyManager always assumes session is valid.  Check authentication.")
        return SPTAuth.defaultInstance().session
    }
    
    var playlistRequest: NSURLRequest?
    
    func createPlaylistRequest(completion: () -> ()) {
        var playlistRequestError: NSError?
        playlistRequest = SPTPlaylistSnapshot.createRequestForPlaylistWithURI(MusicPaintPlaylist, accessToken: self.session.accessToken, error: &playlistRequestError)
        
        if playlistRequestError == nil {
            completion()
        }
        else {
            errorHandler(playlistRequestError!)
        }
    }
    
    var playlistSnapshot: SPTPlaylistSnapshot?
    
    func createPlaylistSnapshot(completion: () -> ()) {
        SPTRequest.sharedHandler().performRequest(playlistRequest!) {
            (error: NSError?, response: NSURLResponse?, data: NSData?) in
            
            if error == nil {
                var playlistSnapshotError: NSError?
                self.playlistSnapshot = SPTPlaylistSnapshot(fromData: data, withResponse: response, error: &playlistSnapshotError)
                if playlistSnapshotError == nil {
                    completion()
                }
                else {
                    self.errorHandler(playlistSnapshotError!)
                }
            }
            else {
                self.errorHandler(error!)
            }
        }
    }
    
    var player: SPTAudioStreamingController?
    
    func createPlayer(completion: () -> ()) {
        player = SPTAudioStreamingController(clientId: SPTAuth.defaultInstance().clientID, audioController: coreAudioController)
        player!.playbackDelegate = self.playbackDelegate
        player!.diskCache = SPTDiskCache(capacity: DiskCacheSize)
        player!.loginWithSession(self.session) {
            (error: NSError?) in
            
            if error == nil {
                completion()
            }
            else {
                self.errorHandler(error!)
            }
        }
    }
}


