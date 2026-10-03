# UI Source Layout

The files under `src` are ordered Luau source fragments. They share local scope when combined, so do not execute or `require` them individually.

Edit the relevant fragment, then build the runnable bundle with:

```powershell
python tools/build.py
```

The builder concatenates the fragments in dependency order and writes the result to `dist/build.lua`. Check whether the bundle is up to date with:

```powershell
python tools/build.py --check
```

The fragments share local scope when combined, so the built bundle is the runnable file.

- `core`: shared services, primitives, tweening, instance helpers, fonts, and library methods
- `themes.lua`: themes and theme setup
- `components`: window, navigation, sections, notifications, global chat, and keybind list
- `elements`: colorpicker and controls
- `modules`: settings and configuration UI
- `example.lua`: sample UI construction
