# Player Character Structure

## Required Scene Structure

Each body part scene **MUST** follow this exact hierarchy:

```
Node2D (Body Part Root)
├── Sprite2D (aggregated spritesheet)
├── CollisionShape2D
├── AnimationPlayer
└── AnimationTree
```
Tool for aggregating spritesheet: https://codeshack.io/images-sprite-sheet-generator

Generally, add idle, walk, and attack [if needed] animations in that order.

#### Arms
**Required animations:**
- `idle`
- `walk` 
- `attack`

#### Legs & Trunk
**Required animations:**
- `idle`
- `walk`

  
### Important Notes
- Animation names are **case-sensitive**
- All animations must be present for the character system to function properly
- Missing animations will cause runtime errors

**CRITICAL**: Always follow this structure exactly. Deviations will break the character system and potentially crash the game.
