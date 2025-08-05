# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Focus Driving** - A pixel-art driving focus timer game where users create "journeys" between real cities, with driving animations playing during focus sessions.

- **Engine**: Godot 4.5 (GL Compatibility)
- **Language**: GDScript 2.0
- **Style**: Pixel art with retro aesthetics
- **Architecture**: Scene-based with Resource-driven data models

## Project Structure

```
├── src/
│   ├── car/                    # Vehicle system
│   │   ├── car.gd             # Main vehicle controller
│   │   ├── car_generator.gd   # NPC traffic spawning
│   │   ├── car_resource.gd    # Vehicle data model
│   │   └── scenes/            # Vehicle prefabs
├── driving/                   # Core driving gameplay
│   ├── driving.gd             # Main driving scene controller
│   ├── driving.tscn           # Main scene file
│   └── ui/                    # Driving UI elements
├── resource/                  # Game assets
│   ├── cars/                  # Vehicle sprites
│   ├── plants/                # Environment assets
│   ├── sky/                   # Sky and weather
│   └── fonts/                 # Pixel fonts
└── addons/                    # Engine extensions
    └── godot-sqlite/          # SQLite database support
```

## Core Systems Architecture

### 1. Vehicle System (`src/car/`)
- **Car.gd**: Node2D-based vehicle with physics simulation
  - States: LEFT, RIGHT, CENTER, STOP
  - Wheel rotation animation
  - Position-based scaling effects
- **CarGenerator.gd**: NPC traffic management
  - Random spawning with configurable intervals
  - Speed variation and lane positioning
  - Automatic cleanup for off-screen vehicles

### 2. Driving Scene (`src/driving/`)
- **Driving.gd**: Main gameplay controller
  - City/stage configuration via enums
  - Parallax background speed scaling
  - Distance tracking for journey progress

### 3. Data Models
- **CarResource.gd**: Resource-based vehicle data (currently minimal)
- **Journey/Route/Session**: JSON-based data structures (as per README)

## Development Commands

### Running the Game
```bash
# Launch Godot editor
godot -e project.godot

# Run directly
godot project.godot

# Export builds
godot --headless --export-release "Windows Desktop" build/
godot --headless --export-release "macOS" build/
```

### Asset Pipeline
```bash
# Import assets (automatic in editor)
godot --headless --import

# Generate UID files for new assets
godot --headless --verify-signatures
```

### Testing
- Use Godot's built-in debugger (F6)
- Monitor output panel for GDScript errors
- Check remote scene tree during runtime

## Key Configuration

### Scene Setup
- **Main Scene**: `driving.tscn` (uid://dpbs3bhrxvuoj)
- **Display**: 1280x720 viewport with GL Compatibility
- **Filtering**: Nearest-neighbor (pixel art)

### Asset Specifications
- **Vehicles**: 32×32px sprites, 8 frames per direction
- **Backgrounds**: 720×320px, 4 stages × 3 time periods
- **Weather**: 128×32px animated overlays
- **Fonts**: Pixel fonts at 10pt

## Scene Structure Patterns

### Vehicle Instantiation
```gdscript
# Car scenes are loaded as PackedScene resources
var car_scene = preload("res://src/car/scenes/muscle_01.tscn")
var car = car_scene.instantiate()
```

### Parallax Background Setup
```gdscript
# Background speed controlled via Parallax2D nodes
var parallax: Parallax2D = $Background/ParallaxLayer
parallax.autoscroll *= speed_scale
```

## Animation System

### Wheel Rotation
- Continuous rotation based on `roll_speed`
- Direction changes flip vehicle sprite
- Speed interpolation for smooth transitions

### State Transitions
- Scale animations between states (CENTER ↔ STOP)
- 300ms transition duration
- Linear interpolation for smooth visual changes

## Data Flow

### Journey Progress
1. **Route Selection**: User chooses city-to-city route
2. **Focus Session**: Driving scene runs with timer
3. **Progress Tracking**: Distance accumulates based on focus time
4. **Completion**: Route finished when timer ≥ configured duration

### Asset References
- All assets use Godot's UID system for robust referencing
- PNG imports configured for pixel art (no filtering)
- Scene files use `.tscn` format for version control

## Common Development Tasks

### Adding New Vehicles
1. Create vehicle sprite (32×32px, 8 directions)
2. Import to `resource/cars/`
3. Create scene in `src/car/scenes/`
4. Add to `CarGenerator.car_scenes` array

### Configuring Routes
1. Define new cities in `City` enum
2. Add route data to journey system
3. Configure stage backgrounds
4. Set duration and completion criteria

### UI Development
- Use `driving/ui/` for driving-specific UI
- Implement responsive design for mobile (375×812)
- Support both portrait and landscape orientations

## Performance Considerations

### Optimization Targets
- NPC vehicle count limited to `max_npc` (default: 2)
- Automatic cleanup for off-screen objects
- Efficient parallax scrolling with minimal overdraw

### Mobile Considerations
- GL Compatibility renderer for broad support
- Conservative particle/animation counts
- Optimized texture sizes for mobile GPUs