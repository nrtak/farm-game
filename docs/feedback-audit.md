# Feedback audit

Local review checklist: `../PhoneFeedbackPreview/feedback-audit.html`. Revision evidence, not acceptance.

| Comment | Tour | Request | Revision |
|---|---|---|---|
| 1 | 1 | More space around farmhouse | Field moved south; broad house-side road removed in this pass. |
| 2 | 2 | Clean farm-to-town transition | Removed boundary tree row; timber fence, open gateway and stone landing. |
| 3 | 3 | Continuous brown cultivated soil | Joined soil cells with continuous furrows. |
| 4 | 5 | Narrower bottom message | Reduced toast width. |
| 5 | 5 | Smaller right HUD | Compact bag/avatar/money/HP panel. |
| 6 | 11 | Hospital paving gap | Paved missing connection. |
| 7 | 14 | Trees blocking streets | Excluded farm boundary trees; road clearance filter. |
| 8 | 17 | Abrupt vet road | Clipped paving tiles and merged curbs; grass verge retained. |
| 9 | 23 | Square transition | Merged paving boundaries and clipped tile edges. |
| 10 | 23 | Square planting | Low planting and furnished building yards. |
| 11 | 24 | Playground path cutoff | Added connecting paved apron. |
| 12 | 25 | Harbor transition | Continuous coastal ground and town paving; review join in linked view. |
| 13 | 26 | Beach/sand layers | Wet-sand bands, ripples, shell fragments and driftwood. |
| 14 | 28 | Longer marina dock | Extended supported deck and connected walkable route. |
| 15 | 29 | Secure fishing pier | Timber fascia, piles, rails and cross braces. |
| 16 | 30 | Varied tide pools | Different pool silhouettes/sizes, stones and highlights. |
| 17 | 32 | Highlands transition | Narrower approach matched to town; stone landing added. |
| 18 | 33 | Onsen in lake | Moved outdoor pool into the lake area. |
| 19 | 37 | Round tea entrance road | Merged and rounded road polygons; surface wear added. |
| 20 | 38 | Round tea paths | Rounded polygons and worn surface detail. |
| 21 | 39 | Tea processing yard path | Rounded yard approach and surface wear. |
| 22 | 40 | Larger tea estate | Expanded rows beyond boundary fence. |
| 23 | 41 | Larger torii | Enlarged shrine gate. |
| 24 | 41 | Fill empty shrine grounds | Low shrubs and meadow details. |
| 25 | 42 | Round shrine corners | Smoothed road corners. |
| 26 | 43 | Wide falls/open pool | Original wide curtain waterfall with open front basin. |
| 27 | 44 | Compact Moonveil dialogue | Uses shallow narrative panel; separate dialogue capture linked below. |
| 28 | 45 | Nature garden detail | Shrubs, flowers, grass tufts and scattered sticks/stones. |
| 29 | 46 | Too many boundary trees | Removed northern farm tree row; fence replaces it. |
| 30 | 50 | Tree in river | Expanded tree exclusion around Highlands–tea crossing. |
| 31 | 52 | Livelier school | Wood floor, chalkboards, desks and residents. |
| 32 | 53 | Restaurant walls | Tiled wall treatment and menu boards. |
| 33 | 55 | Blacksmith floor | Stone floor with wear. |
| 34 | 56 | Cafe floor | Tiled floor. |
| 35 | 56 | Cafe walls | Wall tile and menu treatment. |
| 36 | 58 | Clinic walls | Tile, service stripe and medical crosses. |
| 37 | 61 | Firehouse interior | Equipment, tiled floor and marked equipment lanes; current tour number is 61. |
| 38 | 63 | Shrine distinct from library | Altars, mats, temple walls and tea furniture. |
| 39 | 64 | Lodge interior | Domestic furniture, rug and timber walls. |
| 40 | 65 | Tea tasting/shop interior | Tea table, packing shelf and traditional mat. |
| 41 | 66 | Tea factory interior | Original steamer, roller, grinder and packing machinery. |
| 42 | 67 | Harbor home interior | Bed, domestic table, coastal rug. |
| 43 | 68 | Fishing shop interior | Removed produce displays; tackle rods, nets and fish trays added. |
| 44 | 69 | Hiro cabin interior | Bed, stove, workbench and rug. |
| 45 | 70 | Mine interior | Stone walls/floor, rails and ore. |
| 46 | 71 | Carpentry interior | Workbenches, timber boards and shavings. |
| 47 | 72 | Mountain carpentry interior | Workshop benches, timber finish and shavings. |
| 48 | 73 | Onsen interior | Stone-edged bath, mats; removed overlapping bath furniture. |
| 49 | 74 | Barn interior | Stalls and straw floor detail. |
| New | 1 | Remove farmhouse road | Replaced broad house-side paths with grass. |
| New | 2 | Fence instead of tree row | Removed northern farm trees and added timber fence with opening. |
| New | 27 | Wider harbor walkway | Boardwalk depth increased from 62 to 125 map units. |
| New | 30 | More sand details | Wind ripples, shells, pebbles and driftwood. |
| New | 32 | Cleaner Highlands/town join | Matched path width and short stone landing. |
| New | All | More dirt path patterns | Shared clipped wear strokes, small stones and highlights on all dirt paths. |

References and music provenance: see reference-guided-revision.md. Audio listening approval is still a user review item.

## Verification

Five focused regressions passed after this audit: angled_world_regressions, phone_feedback, world_connections, outdoor_finish, layout_feedback. All 78 numbered views were recaptured, followed by targeted final sand/fishing updates and a separate Moonveil dialogue capture. The previous revision's 68-check suite is not represented as a newly rerun full suite.

## Fishing display asset provenance

Built-in image generation; saved as `world/angled/fishing-display-v1.png`, used by `FishingDisplay.gd`. No reference-game artwork is shipped.

Final prompt:

Create one original game sprite: a cozy Japanese village fishing shop display, isolated on transparent background, full object visible with generous transparent margin. Three-quarter isometric view, front and right face visible, rich hand-painted storybook 2.5D farming RPG style, warm honey brown wood, convincing bevels, shadows and detailed wood grain. A low sturdy wooden counter with two shallow trays of silver-blue fish on crushed ice, a wicker bait basket, a coiled rope, and a modest upright side rack holding three bamboo fishing rods and a folded fishing net. No people, no room, no floor tile, no backdrop, no text, no logo, no produce or vegetables. Single cohesive prop, detailed but readable at 150 pixels wide. Lighting from upper left; short soft contact shadow only; transparent everywhere outside the prop.
