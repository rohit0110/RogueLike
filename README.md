# RogueLike Project

This document outlines the folder structure and conventions for our collaborative Godot project. Please read this before adding or modifying files to maintain a clean and organized workflow.

## Project Structure

The project is organized into two main folders: `Assets` and `Scenes`.

- **`Assets/`**: This directory contains all the raw assets used in the game. This includes images, spritesheets, tilesets, and audio files.
- **`Scenes/`**: This directory contains all Godot scene files (`.tscn`) and their associated scripts (`.gd`).

---

## Naming Conventions

To maintain consistency, please adhere to the standard Godot naming conventions:

*   **Files & Directories:** Use `snake_case` for all filenames and directory names.
    *   *Examples:* `player_character.gd`, `main_menu.tscn`, `level_assets/`
*   **Nodes:** Use `PascalCase` for node names within your scenes. This helps differentiate them from built-in node types.
    *   *Examples:* `PlayerCharacter`, `MainMenuContainer`, `EnemySpawner`
*   **Scripts & Classes:** When creating a new class with `class_name`, use `PascalCase`.
    *   *Example:* `class_name PlayerInventory`
*   **Functions & Variables:** Use `snake_case` for all functions and variables within your GDScript files.
    *   *Examples:* `func _on_player_death():`, `var move_speed = 100`

---

## `Assets` Directory

All visual and audio assets should be placed in this directory, organized by type.

-   **`Assets/CharacterPNGs/`**: For all character-related sprites.
    -   **`Assets/CharacterPNGs/Body Parts/`**: Individual body part sprites (e.g., arms, legs, torso).
    -   **`Assets/CharacterPNGs/[Action]/`**: Sprites for specific character actions like `Idle`, `Walk`, `Jump`, `Attack`.
-   **`Assets/Animations/`**: For pre-made animation files or spritesheets that are not tied to a single character sprite.
-   **`Assets/Level Designs/`**: For tilesets, backgrounds, and other environmental assets.
-   **`Assets/Audio/`**: For all sound effects and music (folder to be created).

**Important:** When importing assets into Godot, ensure the `.import` files are committed to the repository along with the asset itself.

---

## `Scenes` Directory

All game scenes and scripts should be placed here, organized by their function.

-   **`Scenes/Player/`**: Contains the main player scene (`player_character.tscn`) and associated scripts. This scene will assemble the various body parts.
-   **`Scenes/Enemy/`**: For all enemy scenes and their AI scripts.
-   **`Scenes/Body Part Scenes/`**: Contains individual scenes for each swappable body part (e.g., `default_arm.tscn`). These are the building blocks for the player and potentially other characters.
-   **`Scenes/Levels/`**: For all game level scenes (e.g., `level_01.tscn`, `main.tscn`).
-   **`Scenes/Menu/`**: For all UI-related scenes, such as the main menu, settings menu, and HUD.

---

## Contribution Guidelines

1.  **Add new assets first:** Before creating a new scene, add the required image or audio files to the appropriate subfolder in `Assets/`.
2.  **Follow the structure:** Place your new scenes and scripts in the correct directory within `Scenes/`.
3.  **Naming:** Use clear and consistent naming for your files, following the Naming Conventions section above.

By following these guidelines, we can ensure our project remains easy to navigate and manage.
