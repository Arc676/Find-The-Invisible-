//
//  GameView.swift
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

enum GameState {
    case GAME_NOT_STARTED
    case GAME_IN_PROGRESS
    case GAME_OVER
}

class GameView: NSView {

    var maxDistance: Float?
    var iwidth: CGFloat?
    var iheight: CGFloat?

    let ngbRect: NSRect! = NSMakeRect(10, 10, 100, 50)

    var newGameButton: NSImage?

    var targetImage: NSImage?
    var feedbackSound: NSSound?

    var state: GameState = .GAME_NOT_STARTED

    var targetLocation: NSPoint?
    var hitBox: NSRect?

	var timer: Timer?
	var gameTime: Float = 0.0

    func newGame() {
        iwidth = targetImage!.size.width
        iheight = targetImage!.size.height

        let width = UInt32(frame.width - iwidth!)
        let height = UInt32(frame.height - iheight!)
        targetLocation = NSPoint(x: Int(arc4random_uniform(width)), y: Int(arc4random_uniform(height)))
        hitBox = NSMakeRect(targetLocation!.x, targetLocation!.y, iwidth!, iheight!)
        state = .GAME_IN_PROGRESS
        needsDisplay = true
        feedbackSound?.play()

        maxDistance = sqrtf(Float(frame.width * frame.width) + Float(frame.height * frame.height))
        updateFeedbackVolume()

		timer = Timer.scheduledTimer(timeInterval: 0.1,
		                             target: self,
		                             selector: #selector(tick),
		                             userInfo: nil,
		                             repeats: true)
    }

    func updateFeedbackVolume() {
        let mouse = window!.mouseLocationOutsideOfEventStream
        let dx = Float(abs(mouse.x - targetLocation!.x - iwidth! / 2))
        let dy = Float(abs(mouse.y - targetLocation!.y - iheight! / 2))
        feedbackSound?.volume = (maxDistance! / sqrtf(dx * dx + dy + dy)) / 100;
    }

	@objc func tick() {
		gameTime += 0.1
	}

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    override func draw(_ rect: NSRect) {
        NSColor.white.set()
        NSRectFill(rect)
        if state == .GAME_NOT_STARTED || state == .GAME_OVER {
            NSColor.black.set()
            newGameButton?.draw(at: ngbRect.origin, from: NSZeroRect, operation: .sourceOver, fraction: 1)
            if state == .GAME_OVER {
                targetImage?.draw(at: targetLocation!, from: NSZeroRect, operation: .sourceOver, fraction: 1)
				let text = NSAttributedString(string: "\(gameTime) seconds")
				text.draw(at: NSMakePoint(10, 70))
            }
        } //an else clause would be added for GAME_IN_PROGRESS if anything has to be drawn
    }

    override func mouseDown(with event: NSEvent) {
        if state == .GAME_IN_PROGRESS {
            if NSPointInRect(event.locationInWindow, hitBox!) {
                state = .GAME_OVER
                needsDisplay = true
                feedbackSound?.stop()
				timer?.invalidate()
				timer = nil
            }
        } else {
            if NSPointInRect(event.locationInWindow, ngbRect) {
                newGame()
            }
        }
    }

    override func mouseMoved(with event: NSEvent) {
        if state == .GAME_IN_PROGRESS {
            updateFeedbackVolume()
        }
    }

}
