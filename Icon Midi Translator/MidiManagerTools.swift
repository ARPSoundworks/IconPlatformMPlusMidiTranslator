//
//  MidiManagerTools.swift
//  Icon Midi Translator
//
//  Created by Aarón Rodríguez Pérez on 7/31/25.
//
import Foundation
import CoreMIDI
import Combine

extension MIDIManager {
    
    //Depende del estado de currentMidiMode, que se modifica con 
    func receiveAndForwardMIDIPacket(packet: MIDIPacket) {
        if AppState.shared.mixerMode {
            sendToIACIconMixer(packet: packet)
        } else {
            sendToIACIconMidiCC(packet: packet)
        }
    }
    
    //Enviamos el paquete a IAC tal cual lo envía la platform m+
    func sendToIACIconMixer(packet: MIDIPacket) {
        guard let destination = iacIconMixerEndpoint else {
            print("No IAC IconMixer endpoint available")
            return
        }

        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        MIDISend(outPort, destination, &packetList)
    }
    
    func sendToIcon(packet: MIDIPacket) {
        guard let destination = iconDestination else {
            print("No IAC IconMixer endpoint available")
            return
        }

        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        MIDISend(outPort, destination, &packetList)
    }
    
    func sendToIACIconMidiCC(packet: MIDIPacket) {
        guard let ccDestination = iacIconMidiCCEndpoint else {
            print("No IAC IconMidiCC endpoint available")
            return
        }
        
        guard let mixerDestination = iacIconMixerEndpoint else {
            print("No IAC IconMidiCC endpoint available")
            return
        }
        
        guard let iconDestination = iconDestination else {
            print("No IAC IconMidiCC endpoint available")
            return
        }

        let statusByte = packet.data.0
        let messageType = statusByte & 0xF0
        let channel = statusByte & 0x0F // MIDI channel 0 = Channel 1

        // Detect Pitch Bend (0xE0) on channels 1–4 (0–3)
        if messageType == 0xE0 && (0...9).contains(channel) {
           
            if messageType == 0xE0 && (0...3).contains(channel) {
                
                let lsb = packet.data.1
                let msb = packet.data.2

                // Pitch Bend value is 14-bit: combine MSB and LSB
                let pitchBendValue = Int(msb) << 7 | Int(lsb)

                // Map pitch bend range (0–16383) to CC value (0–127)
                //let ccValue = map117To127(UInt8((pitchBendValue * 127) / 16383))
                let ccValue = UInt8((pitchBendValue * 127) / 14896)
                // Get CC number from midiCCValues array
                let ccInt = AppState.shared.midiCCValues[Int(channel)] // <-- este es Int
                
                guard ccInt >= 0 && ccInt <= 127 else {
                    print("Invalid CC number for channel \(channel + 1): \(ccInt)")
                    return
                }

                let ccNumber = UInt8(ccInt)

                print("Transforming Pitch Bend on channel \(channel + 1) into CC \(ccNumber) with value \(ccValue)")

                sendCC(destination: ccDestination, controller: ccNumber, value: ccValue, channel: UInt8(channel))
                
                var packetList = MIDIPacketList(numPackets: 1, packet: packet)
                MIDISend(outPort, iconDestination, &packetList)
                return
            }
            
        } else {
            
            // Forward other messages unchanged
            var packetList = MIDIPacketList(numPackets: 1, packet: packet)
            MIDISend(outPort, mixerDestination, &packetList)
            
        }
    }
    
    func updateFaderValuesFrom(packet: MIDIPacket) {
        
        //Extraemos los valores del paquete
        let status = packet.data.0
        let data1 = packet.data.1
        let data2 = packet.data.2

        let messageType = status & 0xF0

        // Si el mensaje es un Pitchbend
        if messageType == 0xE0 {
            let channel = status & 0x0F
            let value = Int(data2) << 7 | Int(data1)

            if channel < AppState.shared.faderValues.count {
                DispatchQueue.main.async {
                    AppState.shared.faderValues[Int(channel)] = Int(value) / 127
                }
                //print("Canal \(channel) → Valor: \(AppState.shared.faderValues[Int(channel)])")
            }
        }
    }
    
    func sendMIDIMessage(destination: MIDIEndpointRef, status: UInt8, data1: UInt8, data2: UInt8) {
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = 3
        packet.data.0 = status
        packet.data.1 = data1
        packet.data.2 = data2

        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        MIDISend(outPort, destination, &packetList)
        
    }
    
    func sendNoteOn(destination: MIDIEndpointRef, note: UInt8, velocity: UInt8, channel: UInt8 = 0) {
        
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = 3
        packet.data.0 = 0x90 + channel
        packet.data.1 = note
        packet.data.2 = velocity
        
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        MIDISend(outPort, destination, &packetList)
    }
    
    func sendCC(destination: MIDIEndpointRef, controller: UInt8, value: UInt8, channel: UInt8 = 0) {
        
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = 3
        packet.data.0 = 0xB0 + channel
        packet.data.1 = controller
        packet.data.2 = value
        
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        MIDISend(outPort, destination, &packetList)
        
    }
    
}
