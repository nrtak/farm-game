# New Town Edition — v0.2.0, build 100

The approved angled town is now the production `Main.tscn` town, with original gameplay systems attached. The review scene remains a historical layout preview.

- Thirteen buildings, including the restaurant beside the inn. All use normal shop hours, automatic entry, live interiors, and safe return points.
- Original NPC conversations, relationships, daily presence rules, rain shelter, pet interactions, errands, story chapters, and village vote remain active. Hana hosts the restaurant during its opening hours.
- The festival square and story gatherings use the new plaza coordinates. Actors restore their original position and scale after scenes.
- Farm south; harbor west; shrine northwest; Highlands north. The Highlands connect to tea country through the signed southern trail, with existing mine, onsen, and waterfall routes retained.
- Imported production art lives in `world/town/`, outside the excluded concept directory. Both production export presets include its layout data.
- Save format 22 relocates older town saves to the clear farm-side arrival while preserving progression. Indoor saves restore by room name.
- Tap routes finish at their target. Routes passing other doors or regional gates do not accidentally transition. West-facing doors require an approach toward the facade, leaving the street open.

Validation uses isolated saves. The added integration and continuous-physics movement checks are included in the standard release suite. Exported-pack startup, save/relaunch, route checks, and native rendered screenshots are checked separately.

The local playable package is in `../PlayableTown/`. This is a Windows package using the installed Godot runtime. Neighboring maps retain their existing artwork/perspective. Physical iPhone testing and a manual full-story playthrough remain outstanding; no GitHub or TestFlight upload is part of this local integration.

Pre-upload audit: corrected seasonal festival friendship awards (the guest list was cleared too early), and restored guest visibility, labels, and drawing order after celebrations. Continuous-town regression checks cover reward delivery, one-time payment, and guest restoration.

Interface and street refinement: icon-only top controls with tooltips, compact health beside money, centered two-line hint bar, and no duplicate town interaction bubble. The store faces an open market court opposite the cafe; street widths increase from 80/100 to 120/140 logical units and building artwork is less crowded. Save version 21 safely relocates previous town positions after the store move.


Perimeter layout stage: thirteen buildings occupy the outer north/east/south/west edges, leaving the central court clear. All entrances face inward. North/east-facing buildings plus police/carpenter currently use explicitly provisional code-drawn cutaway fronts; finished directional artwork is outstanding. Existing interiors, services and exits remain connected. Save format 22 relocates older town saves. Door proximity selects the closest shop, not the first shop within range. Visitors and pets receive correct town scale before their first schedule update.

The overview screenshot uses a review-only zoom to show the layout; normal gameplay retains the closer following camera. This stage is local only and should receive visual review before any upload.


### Compact aligned blocks (October 17)

Replaced the oversized perimeter court with aligned civic, hospitality, shopping and trade rows. Related services remain together. Straight streets remain body-clear and all 13 doorways are connected. The festival plaza remains northwest, separate from everyday shopping streets. Normal 1.45 camera zoom and player-follow panning are retained. Save version 23 relocates older town saves to the safe farm-side arrival, preserving progress. Desktop screenshots show adjacent rows at gameplay zoom; no physical iPhone check has been performed.
