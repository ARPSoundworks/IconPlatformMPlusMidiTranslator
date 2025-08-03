//
//  MidiManager.swift
//  Icon Midi Translator
//
//  Created by Aarón Rodríguez Pérez on 6/25/25.
//
import Foundation
import CoreMIDI
import Combine

class MIDIManager: ObservableObject {
    
    @Published var destinations: [String] = []
    @Published var activeDestinationIndex: Int = 0

    var inPort = MIDIPortRef()
    @Published var receivedCC: UInt8 = 0
    @Published var receivedValue: UInt8 = 0
    @Published var receivedPitchbend: UInt16 = 8192
    
    @Published var currentCC: UInt8 = 0
    @Published var currentCCValue: UInt8 = 0

    @Published var isIconConnected: Bool = false
    
    var midiClient = MIDIClientRef()
    var outPort = MIDIPortRef()
    
    var iconSource: MIDIEndpointRef? = nil
    var iconDestination: MIDIEndpointRef? = nil

    //var iacIconMixerSource: MIDIEndpointRef? = nil
    var iacIconMixerEndpoint: MIDIEndpointRef? = nil
    var iacIconMidiCCEndpoint: MIDIEndpointRef? = nil
    
    init() {
        setupMIDI()
    }
    
    func setupMIDI() {
        MIDIClientCreate("MidiClient" as CFString, nil, nil, &midiClient)
        MIDIOutputPortCreate(midiClient, "OutputPort" as CFString, &outPort)
        MIDIInputPortCreate(midiClient, "InputPort" as CFString, midiReadProc, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                            &inPort)
        
        refreshDestinations()
        
        connectToIcon()
        connectToIacIconMixer()
        connectToIacIconMidiCC()
        
        guard let destination = iconDestination else {
            print("No ICON destination endpoint available")
            return
        }
        
        for channel in 0..<9 {
            // status pitch bend para el canal (0xE0 + canal)
            let status = UInt8(0xE0 + channel)
            // valor pitch bend = 0 (LSB y MSB)
            sendMIDIMessage(destination: destination, status: status, data1: 0, data2: 0)
        }
    }
    
    func refreshDestinations() {
        var names: [String] = []
        let count = MIDIGetNumberOfDestinations()
        for i in 0..<count {
            let endpoint = MIDIGetDestination(i)
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
            names.append(name?.takeRetainedValue() as String? ?? "Unknown")
        }
        DispatchQueue.main.async {
            self.destinations = names
            if self.activeDestinationIndex >= names.count {
                self.activeDestinationIndex = 0
            }
        }
    }
    
    func connectToIcon() {
        let sourceCount = MIDIGetNumberOfSources()
        for i in 0..<sourceCount {
           let endpoint = MIDIGetSource(i)
           
           var name: Unmanaged<CFString>?
           MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
           
           let deviceName = name?.takeRetainedValue() as String? ?? "Desconocido"
           
           if deviceName.contains("Platform M+ V2.16") {
               MIDIPortConnectSource(inPort, endpoint, nil)
               AppState.shared.isPlatformMPlusConnected = true
               print("Conectado al dispositivo: \(deviceName)")
               break
           }
        }
        
        let destinationCount = MIDIGetNumberOfDestinations()
        for i in 0..<destinationCount {
            let endpoint = MIDIGetDestination(i)
            
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
            
            let deviceName = name?.takeRetainedValue() as String? ?? "Desconocido"
            
            if deviceName.contains("Platform M+ V2.16") {
                iconDestination = endpoint
                print("Conectado al dispositivo: \(deviceName)")
                break
            }
        }
        
    }
    
    func connectToIacIconMixer() {
        
        let destinationCount = MIDIGetNumberOfDestinations()
        for i in 0..<destinationCount {
            let endpoint = MIDIGetDestination(i)
            
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
            
            let deviceName = name?.takeRetainedValue() as String? ?? "Desconocido"
            
            if deviceName.contains("IconMixer2DAW") {
                iacIconMixerEndpoint = endpoint
                print("Conectado al dispositivo: \(deviceName)")
                break
            }
        }
        
    }
    
    func connectToIacIconMidiCC() {
        
        let destinationCount = MIDIGetNumberOfDestinations()
        for i in 0..<destinationCount {
            let endpoint = MIDIGetDestination(i)
            
            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &name)
            
            let deviceName = name?.takeRetainedValue() as String? ?? "Desconocido"
            
            if deviceName.contains("IconMidiCC") {
                iacIconMidiCCEndpoint = endpoint
                print("Conectado al dispositivo: \(deviceName)")
                break
            }
        }
        
    }
}

func midiReadProc(packetList: UnsafePointer<MIDIPacketList>, readProcRefCon: UnsafeMutableRawPointer?, srcConnRefCon: UnsafeMutableRawPointer?) {
    let manager = Unmanaged<MIDIManager>.fromOpaque(readProcRefCon!).takeUnretainedValue()
    var packet = packetList.pointee.packet
    for _ in 0..<packetList.pointee.numPackets {
        
        if  (manager.iconSource == srcConnRefCon?.assumingMemoryBound(to: MIDIEndpointRef.self).pointee) {
            manager.receiveAndForwardMIDIPacket(packet: packet)
            manager.updateFaderValuesFrom(packet: packet)
        }
        
        packet = MIDIPacketNext(&packet).pointee
        
    }
}
