# Town activities and polish

## Player-facing additions
- Café: three rotating named meals using the existing ¥30 / 30 Health meal service; optional lunch delivery to Haruka, Taro or Sachiko for ¥35.
- Inn: three visiting travelers with short stories; explicitly accept a packed-tea request for ¥60. Yumi receives unfinished requests after travelers leave.
- Library: three records about village history, family farmland restoration, and community participation.
- Town Hall: direct access to the seasonal festival calendar, requests/volunteering, and community progress.
- Forge: short hammer-and-anvil animation for purchased upgrades and the daily tool-care workshop.
- Requests: scrollable journal includes accepted story quests, lunch delivery, traveler tea, community meal, volunteering and daily errands. Declining/closing an offer does not accept it.

New requests persist in interior_progress, with no save version migration required. Existing saves default to no accepted new jobs. Active lunch/traveler requests remain across days and cannot be overwritten by rotating offers. Rewards are guarded against repeated callbacks and saved before confirmation.

## Bug and performance work
- Replacing a modal hides and frees the previous panel while preserving conversation state, avoiding stacked dimming and orphan controls.
- The seasonal calendar and long journal scroll within the phone viewport.
- Completed story requests no longer leave an empty HUD label.
- Movement queries reuse their physics shape/query rather than allocating them per collision probe.
- The tap marker redraws only while fading, including a final clearing frame.
- Forge animation stops processing after 2.4 seconds.

## Verification
29 headless regression suites; phone-size rendered menu checks; isolated exported-pack startup and save/relaunch checks. Device performance and iOS distribution are separate from these local checks.
