//
//  ContentView.swift
//  Icon Midi Translator
//
//  Created by Aarón Rodríguez Pérez on 6/25/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var midiManager: MIDIManager
    
    @ObservedObject var appState: AppState = .shared
    
    var body: some View {
        VStack{
            VStack(spacing: 20) {
                
                HStack {
                    Text("Modo CC")
                        .font(.title3)
                    Toggle("", isOn: $appState.mixerMode)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        /*.onChange(of: appState.mixerMode) { newValue in
                            print("modoFader ahora vale: \(newValue)")
                        }*/
                    Text("Modo Fader")
                        .font(.title3)
                }
                
                HStack {
                    Text("Icon M+ conectado:")
                    Circle()
                        .fill(AppState.shared.isPlatformMPlusConnected ? Color.green : Color.gray)
                        .frame(width: 20, height: 20)
                }
                .padding()
                
                HStack(spacing: 50) {
                    VStack(spacing: 10) {
                        Text("Fader Pitchbend")
                            .font(.headline)
                        ForEach(0..<9) { i in
                            let val = appState.faderValues[Int(i)]
                            Text("Fader \(i + 1): \(val)")
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Text("MIDI CC")
                            .font(.headline)
                        ForEach(0..<9) { index in
                            if (index<4) {
                                Text("CC: \(appState.midiCCValues[(index)])")
                            } else {
                                Text("CC:")
                            }
                        }
                         
                    }
                    
                }
                .padding()
                
                Button("Close UI") {
                    if let window = NSApp.windows.first {
                        NSApp.hide(nil)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.top, 50)
        }
        .frame(minWidth: 720, minHeight: 400)
    }
}


#Preview {
    ContentView()
        .environmentObject(MIDIManager())
}
