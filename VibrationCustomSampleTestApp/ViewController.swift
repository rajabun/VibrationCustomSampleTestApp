//
//  ViewController.swift
//  VibrationCustomSampleTestApp
//
//  Created by Muhammad Rajab Priharsanto on 07/10/19.
//  Copyright © 2019 Muhammad Rajab Priharsanto. All rights reserved.
//

import UIKit
import AudioToolbox
import CoreHaptics

class ViewController: UIViewController
{

    var engine: CHHapticEngine?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        prepareHaptic()
    }
    
    func prepareHaptic()
    {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do
        {
            engine = try CHHapticEngine()
            try engine?.start()
        }
        catch
        {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        
        //Stopped Handler & Reset Handler
        
        // The engine stopped; print out why
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = { [weak self] in
            print("The engine reset")

            do
            {
                try self?.engine?.start()
            }
            catch
            {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
    
    @IBAction func vibrateButton(_ sender: UIButton)
    {
        print("Vibrate Pressed")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    @IBAction func hapticButton(_ sender: UIButton)
    {
        print("Haptic Triggered")
        //Create Haptic Feedback
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
    }
    
    @IBAction func customHapticButton(_ sender: UIButton)
    {
        print("Custom Haptic")
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        sharpTapPattern()
    }
    
    @IBAction func customHapticSeriesButton(_ sender: UIButton)
    {
        print("Series Haptic")
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        seriesTapPattern()
    }
    
    @IBAction func customHapticMixedButton(_ sender: UIButton)
    {
        print("Mixed Haptic")
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        mixedTapPattern()
    }
    
    
    //this creates one strong, sharp tap whenever you touch the button :
    func sharpTapPattern()
    {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do
        {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        }
        catch
        {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    //this creates a series of taps, starting strong and sharp and fading away to weak and dull over a second:
    
    func seriesTapPattern()
    {
        var events = [CHHapticEvent]()

           for i in stride(from: 0, to: 1, by: 0.1)
           {
               let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
               let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
               let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
               events.append(event)
           }

           do
           {
               let pattern = try CHHapticPattern(events: events, parameters: [])
               let player = try engine?.makePlayer(with: pattern)
               try player?.start(atTime: 0)
           }
           catch
           {
               print("Failed to play pattern: \(error.localizedDescription).")
           }
    }
    
    //this taps out the Morse code for SOS (...---...) on the Taptic engine by mixing transient events (brief taps) with continuous events (long buzzes over a period of time):
    
    func mixedTapPattern()
    {
        let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
        let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
        let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
        let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
        let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
        let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
        let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)

        do
        {
            let pattern = try CHHapticPattern(events: [short1, short2, short3, long1, long2, long3, short4, short5, short6], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        }
        catch
        {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

