//
//  GlobalVariables.swift
//  Icon Midi Translator
//
//  Created by Aarón Rodríguez Pérez on 7/31/25.
//
//  Estas son variables globales usadas tanto por el Content View para actualizar la UI como por el MidiManager.
//
import Foundation
import Combine

class AppState: ObservableObject {
    
    static let shared = AppState() // Singleton compartido

    enum MidiMode {
        case iacIconMixer
        case iacIconMidiCC
    }
    
    @Published var currentMidiMode: MidiMode = .iacIconMixer
    
    @Published var mixerMode: Bool = false

    @Published var isPlatformMPlusConnected: Bool = false

    @Published var faderValues: [Int] = Array(repeating: 0, count: 9)
    @Published var midiCCValues: [Int] = [1, 11, 76, 2, 0, 0, 0, 0, 0]
    
    private init() {} // Impide que se creen otras instancias
}
