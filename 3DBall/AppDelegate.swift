//
//  AppDelegate.swift
//  3DBall
//
//  Created by Karen Karapetyan on 22.06.25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


}

/*
 
 Project description for the ai agent
 
 
 🎮 Game Title: Velocity Sphere

 🧭 Full Game Description

 Velocity Sphere is a next-generation 3D endless-runner where you don’t play as a character — you become momentum. You control a perfectly engineered, physics-powered rolling ball racing through an ever-evolving world of danger, motion, and beauty. Crafted with precision using Apple’s SceneKit engine and designed with a clean modular architecture, this game merges fluid mechanics with eye-catching design and rich, addictive gameplay.

 ⸻

 🚀 Core Gameplay

 At its heart, Velocity Sphere is about survival through speed and control. The ball rolls forward automatically down a three-lane track. Your goal: stay alive, dodge obstacles, collect power-ups, and go as far as you can.

 You interact with the game through simple gestures:
     •    Swipe Left / Right: Shift lanes to dodge obstacles or collect items.
     •    Swipe Up / Tap: Make the ball jump.
     •    (Optional future) Swipe Down: Duck under archways or traps.

 The challenge grows dynamically. The further you roll, the faster the game becomes. Every second tests your reflexes, focus, and lane-switching precision. It’s a beautiful blend of casual-friendly mechanics with deep skill ceilings.

 ⸻

 🏗️ Modular Architecture & Systems

 🎱 Player (Ball)
     •    Fully encapsulated in PlayerNode.swift
     •    Realistic rolling physics, configurable jump force
     •    Uses SceneKit physics body (.dynamic) with tuned mass, friction, and restitution
     •    Custom textures and skins supported
     •    Jump, moveLeft, moveRight methods exposed

 🛤️ GroundManager
     •    Procedurally generates ground tiles infinitely
     •    Recycles tiles behind the player to reduce memory overhead
     •    Clean modular structure (each tile is 10x20 units)
     •    Scene-aware, lightweight system

 🧱 ObstacleManager
     •    Procedurally spawns obstacles in random lanes
     •    Fully dynamic positioning based on player Z-distance
     •    Uses contact bitmasks for physics collision detection
     •    Removes obstacles behind the player

 ⚠️ Physics & Collisions
     •    Category bitmasks define interaction rules
     •    GameViewController conforms to SCNPhysicsContactDelegate
     •    On contact → triggers game over or effects
     •    Handles real-time interactions without performance hitches

 ⸻

 🖼️ Visual Design & Textures

 Every visual element in Velocity Sphere is crafted with clarity and flair:

 🌐 Ball Textures:
     •    Marble, Lava, Ice, Neon, Gold, Holographic, and more
     •    High-res textures (1024x1024), tileable, with gloss, specular, and metallic settings
     •    Custom ball skins change how light reflects and bounces
     •    Skins unlocked through gameplay progression

 🗺️ Environments:
     •    Temple Ruins: Mossy stone tiles, ancient broken pillars, golden light shafts
     •    Neon Highway: Tron-inspired grid, glowing cyan edges, synthwave background
     •    Frozen Valley: Snow-covered terrain, fog, icicle obstacles
     •    Volcanic Caverns (Upcoming): Glowing lava flows, molten tiles, smoke particles

 Each environment has its own lighting setup, obstacle designs, and mood.

 ⸻

 🔊 Audio Design
     •    Responsive swipe sounds, bounce effects, and collision audio
     •    Dynamic background music that escalates as speed increases
     •    SFX balance ensures feedback without distraction
     •    Music styles vary by zone: tribal drums, synthwave, ambient pads, etc.

 ⸻

 📲 User Interface & Game Screens

 🏠 Main Menu
     •    Clean 3D interface with animated camera sweep
     •    Buttons: Play, Skins, Settings, Stats
     •    Background environment loops subtly (with ambient particles)

 🎮 Gameplay Screen
     •    Full-screen SceneKit view
     •    Swipe controls (no on-screen buttons)
     •    UI overlay (score, orbs collected)
     •    Responsive pause with blur effect

 ⚰️ Game Over Screen
     •    Shows run summary: Distance, Orbs, Score
     •    Replay button, Home button, Skins shortcut
     •    Smooth fade-in with particle animation

 🎨 Skins/Customization
     •    Grid layout of locked/unlocked ball skins
     •    Preview selected texture on a spinning model
     •    Unlock with orbs or achievements
     •    Optional: Skin stats (just cosmetic or rare unlocks)

 ⚙️ Settings Screen
     •    Audio on/off
     •    Sensitivity slider for swipe distance
     •    Theme toggle (light/dark)
     •    Restore purchases

 📈 Stats / Progress
     •    High Score
     •    Longest run
     •    Obstacles dodged
     •    Skins unlocked
     •    Total orbs collected

 ⸻

 🧠 Gameplay Loops & Progression

 Short-term loop:
     •    React to threats
     •    Collect orbs
     •    Beat personal best

 Mid-term loop:
     •    Unlock new skins
     •    Reach milestone distances
     •    Discover new zones

 Long-term loop:
     •    Collect rare textures
     •    Perfect each environment
     •    Complete daily/weekly challenges (future feature)

 ⸻

 🎯 Player Experience

 Velocity Sphere is designed to be:
     •    Easy to pick up, hard to master
     •    Visually rich and mechanically satisfying
     •    Performance-optimized for smooth gameplay on all iOS devices
     •    Modular and expandable for future updates (themes, zones, challenges)

 The player doesn’t just play the game — they feel connected to the ball’s motion, immersed in the rhythm of movement and music.

 ⸻

 💡 Expansion Potential

 Planned features:
     •    Power-ups (magnet, shield, slow-motion)
     •    Daily/weekly challenges
     •    Achievements system
     •    Online leaderboards
     •    Social share
     •    Multiplayer race mode (prototype stage)

 ⸻

 🧑‍🤝‍🧑 Audience

 Perfect for:
     •    Casual gamers seeking short, satisfying runs
     •    Reflex pros chasing leaderboards
     •    Kids who love unlocking and collecting
     •    Adults who enjoy meditative focus gameplay

 ⸻

 📦 Summary

 Velocity Sphere is a stylish, challenging, endlessly replayable 3D ball-runner game built with performance, polish, and long-term player engagement in mind. With stunning visuals, reactive physics, rich texture customizations, and immersive sound, it offers a powerful blend of arcade adrenaline and thoughtful design.

 Whether you’re running for fun or fighting for perfection, the sphere never stops.
 */
