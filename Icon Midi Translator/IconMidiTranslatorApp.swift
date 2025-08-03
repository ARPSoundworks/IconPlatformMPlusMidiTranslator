//
//  IconMidiTranslatorApp.swift
//  Icon Midi Translator
//
//  Created by Aarón Rodríguez Pérez on 6/25/25.
//

import SwiftUI

import SwiftUI
import CoreMIDI

@main
struct Icon_Midi_TranslatorApp: App {
    
    let runWithUI = true
    let midiManager = MIDIManager()
   
    @StateObject var appState = AppState.shared
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        
        appDelegate.midiManager = midiManager
        
        if !runWithUI {
            DispatchQueue.global().async {
                RunLoop.current.run()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(midiManager)
                .environmentObject(appState)
        }
    }
}
