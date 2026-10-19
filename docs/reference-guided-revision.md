# Reference-guided local revision

User direction: substantial outdoor improvement, 49 annotated tour comments, and original seasonal music with a warmer, lower sound. Keep the 78 tour numbers and local-only review workflow.

## Visual reference direction

- The user-provided PlayStation screenshots were downloaded and inspected: quieter grass, broad worn earth, deliberate garden boundaries, layered stone/water edges, and supported timber docks.
- [Dialogue reference](https://i.ytimg.com/vi/nT2_oXyrKKg/maxresdefault.jpg): shallow cream panel, full-width text, portrait above the left edge.
- [Woodcutter interior](https://harvestmoon.fandom.com/wiki/Woodcutter%27s_House_(BTN)?file=Gotz%27s_Shop_BTN.png) and [starter house](https://harvestmoon.fandom.com/wiki/House_(BTN)?file=Base_house.jpg): timber walls and floors, practical furniture groupings, and domestic/workshop detail. Both selected images were inspected.
- [Building collection](https://harvestmoon.fandom.com/wiki/Category:Buildings): browsed as a reference index.
- [Fishing](https://harvestmoon.fandom.com/wiki/Fishing_(BTN)) and [farm](https://harvestmoon.fandom.com/wiki/Farm_(BTN)): selected screenshots inspected for shore edges, continuous soil, and quiet grass.

Reference downloads remain outside the game under `local-draft/visual-references`; they are not shipped game assets.

The user's musical references are [winter](https://www.youtube.com/watch?v=tQpbXAmRMqA), [fall](https://www.youtube.com/watch?v=OuCEyNWT7_s), [summer](https://www.youtube.com/watch?v=lquMmQRffEA), and [spring](https://www.youtube.com/watch?v=zA-giRmSXAE). These are reference links only. No recordings were downloaded or reused.

## Original assets

- `world/angled/tea-production-v1.png`: built-in image generation, original transparent 2×2 equipment atlas. Steamer, rolling/drying table, matcha grinder, packing shelves. Generated for this revision and used in the tea interiors.
- `world/angled/wide-waterfall-v1.png`: built-in image generation, original broad waterfall with rocks restricted to the sides and an open spray edge, integrated into the shrine lake and falls scene.
- `ci/generate_seasonal_audio.py`: original written note sequences and synthesized instrumental voices; no source recordings or samples. Four stereo tracks, 71–104 seconds. Source YouTube recordings could not be auditioned through the available tools; mood choices derive from the user's seasonal brief, not a claimed transcription or listening comparison.

## Changes under review

Continuous cultivated soil and greater farmhouse clearance; calmer grass texture; clustered meadow detail; merged rounded road silhouettes; hospital/playground paving connections; clean paving boundaries; expanded tea estate; low shrine planting and larger gate; water shading, beach bands, varied pools, extended marina deck, and pier bracing; new waterfall and relocated onsen pool; tree exclusions for roads/water/town overlap.

Interiors now have differentiated floor and wall materials, functional furnishings, tea machinery, shrine mats, onsen bath, workshop wear, school boards, clinic markings, and barn straw. Dialogue uses the reference-inspired lower panel and raised portrait, including compact Moonveil narration. HUD and bottom messages are smaller. Seasonal tracks replace daytime farm/town/nature music with existing weather/night/interior handling retained.

Validation: all 68 automated checks passed across the initial run and resumptions after fixes. Updated the soil-grid expectation for its new location and fixed headless waterfall audio cleanup. `git diff --check` passed. The fresh 78-view world tour uses stable numbering and normal camera/HUD at 1311 � 603; every PNG was validated and hashes saved in its capture manifest. No physical iPhone validation or manual playthrough is implied by staged captures. Local package checks are recorded in the preview manifest.
