//
//  AppDelegate.swift
//  Icon Midi Translator
//
//  Created by Aarón Rodríguez Pérez on 6/26/25.
//

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    var midiManager: MIDIManager!
    var statusItem: NSStatusItem?
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "slider.horizontal.3", accessibilityDescription: "Icon MIDI Translator")
            button.action = #selector(statusBarButtonClicked)
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Mostrar UI", action: #selector(openUI), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Salir", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
        createMainWindow()
    }

    
    @objc func statusBarButtonClicked() {
        // Abre el menú, comportamiento por defecto
    }
    
     
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil) // oculta la ventana
        return false // cancela el cierre real
    }

    @objc func openUI() {
        if let window = window {
                window.makeKeyAndOrderFront(nil)
            } else {
                createMainWindow()
            }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    func createMainWindow() {

        let contentView = ContentView()
            .environmentObject(midiManager)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false)
        
        window?.delegate = self

        window?.center()
        window?.setFrameAutosaveName("Main Window")
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
