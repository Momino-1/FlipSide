
## Controls
- **A/D or Left/Right** — move
- **Space** — jump
- **F** — flip between 2D and 3D

(These are plain key polls in `player.gd` so the project runs with zero
Input Map setup. For rebindable controls/controller support, define
`move_left`, `move_right`, `jump`, and `flip` actions in Project
Settings → Input Map, then swap the polling code for
`Input.get_axis(...)` / `Input.is_action_just_pressed(...)`.)

## What to try
Walk right from the start. You'll hit a wall. Press **F** — the camera
swings 90°, your movement axis switches from X to Z, and a corridor that
was hidden behind the wall becomes walkable. That reveal is the whole
trick: it's real 3D geometry that was simply out of view.

Walk left onto the platform near the start and you'll enter a
`NoFlipZone` — flipping is temporarily disabled there.
dark rooms.

## Project structure
```
project.godot
scenes/
  Main.tscn      — test level: ground, walls, hidden corridor, no-flip zone
  Player.tscn    — CharacterBody3D + collision + billboarded Sprite3D
scripts/
  player.gd      — movement, jump, gravity, mode switching
  camera_rig.gd  — camera pivot that orbits 90° on flip
  no_flip_zone.gd — Area3D helper to lock/unlock flipping in a region
```

## How the mechanic actually works
- **One 3D scene, orthographic camera.** `Camera3D.projection` is set to
  Orthogonal, which removes perspective distortion — that's most of
  what makes it *read* as 2D even though it's real 3D geometry.
- **Billboarded sprite.** `Sprite3D.billboard` keeps the player looking
  like a flat paper cutout from any camera angle.
- **Axis lock, not a different game.** `player.gd` just zeroes out
  whichever horizontal axis isn't "active" for the current mode. Y
  (gravity/jumping) is untouched by mode — this is the whole trick.
- **Camera orbits, doesn't just cut.** `camera_rig.gd`'s `Camera3D` is a
  child offset from the rig's origin. Rotating the *rig* 90° around Y
  makes the camera orbit around the player while still facing them,
  which is why the reveal feels like the world turning rather than a
  camera cut.
- **Level design does the storytelling.** The hidden corridor in
  `Main.tscn` is just geometry placed behind the wall on the Z axis —
  nothing fancy, but it's the actual source of the "whoa" moment.
