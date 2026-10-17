# New Town Edition — v0.2.0, build 100

The approved angled town is now the production `Main.tscn` town, with original gameplay systems attached. The review scene remains a historical layout preview.

- Thirteen buildings, including the restaurant beside the inn. All use normal shop hours, automatic entry, live interiors, and safe return points.
- Original NPC conversations, relationships, daily presence rules, rain shelter, pet interactions, errands, story chapters, and village vote remain active. Hana hosts the restaurant during its opening hours.
- The festival square and story gatherings use the new plaza coordinates. Actors restore their original position and scale after scenes.
- Farm south; harbor west; shrine northwest; Highlands north. The Highlands connect to tea country through the signed southern trail, with existing mine, onsen, and waterfall routes retained.
- Imported production art lives in `world/town/`, outside the excluded concept directory. Both production export presets include its layout data.
- Save format 20 relocates older town saves to the clear farm-side arrival while preserving progression. Indoor saves restore by room name.
- Tap routes finish at their target. Routes passing other doors or regional gates do not accidentally transition. West-facing doors require an approach toward the facade, leaving the street open.

Validation uses isolated saves. The added integration and continuous-physics movement checks are included in the standard release suite. Exported-pack startup, save/relaunch, route checks, and native rendered screenshots are checked separately.

The local playable package is in `../PlayableTown/`. This is a Windows package using the installed Godot runtime. Neighboring maps retain their existing artwork/perspective. Physical iPhone testing and a manual full-story playthrough remain outstanding; no GitHub or TestFlight upload is part of this local integration.

Pre-upload audit: corrected seasonal festival friendship awards (the guest list was cleared too early), and restored guest visibility, labels, and drawing order after celebrations. Continuous-town regression checks cover reward delivery, one-time payment, and guest restoration.
