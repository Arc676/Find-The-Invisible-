//
//  AppDelegate.swift
//  Find The Invisible *
//
//  Created by Alessandro Vinciguerra on 16/02/2017.
//      <alesvinciguerra@gmail.com>
//Copyright (C) 2017 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var view: GameView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        window.acceptsMouseMovedEvents = true
        window.makeFirstResponder(view)

		view.targetImage = NSImage(named: "defaultTarget.png")
        view.newGameButton = NSImage(named: "newGame.png")
        view.feedbackSound = NSSound(named: "beep.m4a")
        view.feedbackSound?.loops = true

        view.needsDisplay = true
    }

    func getFile(_ fileTypes: [String]) -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedFileTypes = fileTypes
        if panel.runModal() == NSFileHandlingPanelOKButton {
            return panel.url
        }
        return nil
    }

    func noChangeAlert() {
        let alert = NSAlert()
        alert.messageText = "Not permitted"
        alert.informativeText = "Can't change image or sound file while game is in progress"
        alert.runModal()
    }

    @IBAction func loadImage(_ sender: NSMenuItem) {
        if view.state == .GAME_IN_PROGRESS {
            noChangeAlert()
            return
        }
        if let url = getFile(["png"]) {
            view.targetImage = NSImage(byReferencing: url)
        }
    }

    @IBAction func loadSoundFile(_ sender: NSMenuItem) {
        if view.state == .GAME_IN_PROGRESS {
            noChangeAlert()
            return
        }
        if let url = getFile(["mp3"]) {
            view.feedbackSound = NSSound(contentsOf: url, byReference: true)
            view.feedbackSound?.loops = true
        }
    }

    @IBAction func loadExistingImage(_ sender: NSMenuItem) {
        view.targetImage = NSImage(named: sender.toolTip!)
    }

    @IBAction func loadExistingSound(_ sender: NSMenuItem) {
        view.feedbackSound = NSSound(named: sender.toolTip!)
        view.feedbackSound?.loops = true
    }

}
