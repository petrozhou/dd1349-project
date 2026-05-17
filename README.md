# Indamon 2.0

A Pokemon-inspired 2D RPG built in Godot 4, created as a continuation of the Indamon project from our first programming course.

## About the Game

Indamon 2.0 is a top-down 2D world where the player explores an overworld map and encounters wild Indamons in tall grass. Each step into tall grass has a 10% chance of triggering a turn-based battle. The goal is to defeat 3 Indamons to win — but if your Indamon faints, it's game over.

## Installation

### To develop or modify the project
1. Download and install [Godot 4](https://godotengine.org/download) (latest version)
2. Clone or download this repository
3. Open Godot, click **Import**, and select the project folder
4. Press **Play** to run the game

### To just play the game
The game can be exported as a standalone application — no Godot installation needed. Check the releases section for an exported build if available.

## How to Play

| Input | Action |
|-------|--------|
| Arrow keys | Move player |
| Attack | Deal damage to the enemy Indamon |
| Run | 50% chance to escape the battle |

Walk into tall grass to trigger a battle (10% chance per step). Defeat 3 Indamons to win the game.

## Project Structure

| Script | Responsibility |
|--------|---------------|
| `Player.gd` | Tile-based movement, animation, battle triggering |
| `Scene_Manager.gd` | Scene transitions, screen fades, player HP and stats |
| `Battle.gd` | Turn-based battle logic, win/lose conditions |
| `Door.gd` | Door animations, triggers scene transition via SceneManager |
| `Tall_Grass.gd` | Grass animations, step effect, triggers battle on player entry |
| `Menu.gd` | Start, how to play, and exit buttons with fade transition |
| `Exclamation.gd` | Plays exclamation animation then frees itself |
| `Grass_Step_Effect.gd` | Plays grass particle animation then frees itself |

## Technical Highlights

### Tile-Based Player Movement
Rather than using Godot's built-in movement functions, we built a custom tile-based movement system suited to a Pokemon-style grid world. Three functions work together:

- `process_player_input()` — reads arrow keys, prevents diagonal movement
- `move()` — interpolates smoothly between tiles each frame
- `_physics_process()` — runs every frame, coordinates between the two above

Since we override Godot's default movement, collisions are not handled automatically. We added two **RayCast2D nodes** on the player — one for blocking tiles like water, and one specifically for doors — so the player can detect and respond to collision bodies manually.

Animation uses an **AnimationTree StateMachine** with blend positions for directional idle and walk animations in all four directions, driven by `is_moving` and `is_idle` conditions set from code each frame.

### Scene Manager
A global **SceneManager** autoload node handles all transitions between scenes. It is responsible for:

- Smooth **fade to black / fade in** screen transitions
- **Swapping scenes** cleanly under the black screen so the player never sees a pop
- Restoring the correct **player spawn position and facing direction** after a scene change
- Persisting **player HP and enemy defeat count** across scenes

### Battle System
Battle is a `CanvasLayer` scene instantiated on top of the overworld rather than replacing it. It runs a simple state machine with the states `INIT`, `PLAYER_TURN`, `ENEMY_TURN`, `WIN`, `LOSE`, and `END`. When the battle ends it emits a `battle_finished` signal, which the player script listens to in order to fade out, remove the battle scene, and restore the overworld cleanly.

### Door System
Each door is an `Area2D` with an exported path to its destination scene and a spawn location. When the player walks into a door:
1. The player emits a signal, the door plays its open animation
2. The player's disappear animation plays
3. The door calls `SceneManager.transition_to_scene()` which fades, swaps, and spawns the player at the correct position and facing direction

### Main Menu
The main menu has three buttons — Start, How to Play, and Exit. How to Play swaps the button panel for an info panel in place. Start plays a fade animation before switching to the SceneManager scene to begin the game.

### Tall Grass System
Each tall grass tile handles several things independently:
- A **stepped animation** plays when the player enters, squishing the grass down and bouncing it back
- A **grass particle effect** spawns on entry and frees itself after playing
- A **10% random battle chance** triggers on each entry, showing an exclamation mark animation above the player before fading to the battle scene


## Authors
- Petro Zhou
- Daniel Danogw
