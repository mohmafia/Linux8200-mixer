# Linux8200-mixer

# 🎛️ OpenMixer UI

**A scalable, skinnable, open-source digital mixer interface built with Godot 4.4 and Bash.**
**Contributors make sure you use the godot 4.4 version only!!!.**

OpenMixer UI is a modular interface for digital audio control — built to be extended, themed, and integrated into real-world audio workflows or embedded systems. While the overall project focuses on mixer logic and device routing, the **settings scene** is uniquely styled to resemble the internal PCB of a hardware mixer, complete with labeled components and a retro LCD-style system status display.

---

## 🚀 Features

- **Godot 4 UI** with GDScript for responsive, interactive control
- **Bash integration** for system-level tasks like device detection, routing, and installation
- **Scalable interface** with plans for full **SVG-based skinning**
- **Hover-based tooltips** in the settings scene for intuitive feedback
- **PCB-style layout** in the settings scene for a hardware-inspired visual experience
- **Modular design** — easy to extend with new devices, masters, or routing logic
- **Open source** and community-driven

---


## 🛠️ Tech Stack

| Layer         | Tech Used         |
|---------------|-------------------|
| UI & Logic    | Godot 4 (GDScript)|
| System Access | Bash scripting    |
| Assets        | PNG (JPG for now), SVG (planned) |
| Versioning    | Git + GitHub      |

---

## 🎨 Skins & Scalability

The current UI uses bitmap backgrounds (JPG), which limits scalability. We're actively working on **SVG-based skin support** to enable:

- Resolution-independent UI
- Custom themes and skins
- Dynamic layout scaling

If you're a designer or vector artist, your contributions are more than welcome!

---

## 🤝 Contributing

We’re looking for contributors who are passionate about:

- UI/UX design (especially SVG and scalable layouts)
- Godot development (GDScript, Control nodes, Theme system)
- Bash scripting and system integration
- Audio routing, DSP, or embedded systems

Every small contribution can have a big impact. Whether it's a new skin, a tooltip improvement, or a routing script — you're welcome here.

---

## 📦 Getting Started

1. Clone the repo
2. Open the project in Godot 4
3. Run the main scene (`install.tscn`) or `settings_lcd_panel.tscn`
4. Explore, test, and contribute!

> Bash scripts are located in `/scripts` and handle system-level logic.

---

## 📜 License

This project is licensed under the MIT License — free to use, modify, and distribute.

---

## 🌍 Roadmap

- [x] PCB-style layout in settings scene
- [x] Tooltip system for all interactive elements
- [x] Bash integration for system-level control
- [ ] SVG-based scalable UI
- [ ] Skin/theme support
- [ ] Routing logic and audio simulation
- [ ] Community-contributed skins and layouts
- [ ] Integration with real audio devices (optional)

---

## 📣 Shoutouts

This project is made possible by the open source community and the creative minds who believe in building tools that are both functional and beautiful.

> Want to be listed here? Contribute and make your mark.

---
## 🖼️ Screenshots

**Main skin**

<img width="1738" height="918" alt="screenshot" src="https://github.com/user-attachments/assets/6399c0b4-afaf-49cf-bebe-97e2c7de2425" />

![mixersim](https://github.com/user-attachments/assets/4ed1f72c-c6f0-4b0b-bae8-84393f50183c)


**Settings skin**

<img width="1736" height="885" alt="settings-panel" src="https://github.com/user-attachments/assets/f267e8f1-273a-44e8-aef5-3bc4ec03ff39" />

**PCB Tooltips**

<img width="527" height="422" alt="tooltips" src="https://github.com/user-attachments/assets/aedc0468-4968-4966-b8e3-06017d5f9b7e" /> 
<img width="752" height="469" alt="tooltips on settings scene" src="https://github.com/user-attachments/assets/e8bc5a4b-b554-4b5a-bf6f-44e4b1a02910" />




---
