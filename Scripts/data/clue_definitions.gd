class_name ClueDefinitions
extends RefCounted
# I did not write this, I automated the process iwth ai cuz Im a lazy bum
#someone will probably need to rewrite this tho

const BEHAVIOR_CLUE_NAMES: Array[String] = [
	"Pale", 
	"Monotone", 
	"Twitchy", 
	"Dark Clothing",
	"Scorched", 
	"Foot Tapping", 
	"Stained Hands",
	"Unblinking",
]

const BEHAVIOR_CLUE_DESCRIPTIONS: Array[String] = [
	"Their skin has an unnatural, bloodless pallor.",
	"They speak without any rise or fall in pitch.",
	"Their hands won't stop moving, quick and jittery.",
	"Layered in dark fabric despite the warmth.",
	"Fabric edges show scorch marks and burn holes.",
	"A foot taps constantly, restless and unconscious.",
	"Fingers stained dark, like old ink won't wash off.",
	"Eyes fixed on you, unnervingly still.",
]





const BIRTH_CLUE_NAMES: Array[String] = [
	"Darkness", 
	"Sky Flash", 
	"Sky Haze",
	"Twin Lights", 
	"Fireball",
	"Freezing Sky",
]

const BIRTH_CLUE_DESCRIPTIONS: Array[String] = [
	"Born beneath a sky with no visible stars at all.",
	"Born the moment a blinding flash split the night sky.",
	"Born under a strange violet haze across the stars.",
	"Born beneath two bright points hanging side by side.",
	"Born as a fireball streaked low across the horizon.",
	"Born under a sky that turned bitterly, unnaturally cold.",
]





const SKY_CLUE_NAMES: Array[String] = [
	"In the East", 
	"In the West", 
	"In the North", 
	"In the South",
	"Blindingly Bright", 
	"Dimming Light", 
	"Rapid Pulse",
	"Ring / Halo", 
	"Trailing Tail", 
	"Surface Arc", 
	"Gas Ribbon",
	"Red Glow", 
	"Violet Light",
]

const SKY_CLUE_DESCRIPTIONS: Array[String] = [
	"Event in the eastern sky.",
	"Event in the western sky.",
	"Event in the northern sky.",
	"Event in the southern sky.",
	"A point of light too bright to look at directly.",
	"A light that seems to dim and flicker unnaturally.",
	"Pulsing rapidly, on and off like a heartbeat.",
	"A faint ring expanding slowly outward.",
	"A long, thin tail trailing behind it.",
	"A bright arc curling along its surface.",
	"A thin ribbon of gas stretched taut across the sky.",
	"Glowing a deep, fiery gold-red.",
	"Glowing a cold, pale blue-violet.",
]









#### IDS DO NOT FUCKING TOUCH ISTG I WILL SKIN YOU ALIVE
const BEHAVIOR_CLUE_IDS: Array[String] = [
	"pale_skin", 
	"monotone_voice", 
	"twitchy_fast_hands", 
	"heavy_dark_clothing",
	"singed_scorched_clothes", 
	"restless_foot_tapping", 
	"ink_stained_hands",
	"piercing_unblinking_gaze",
]


const BIRTH_CLUE_IDS: Array[String] = [
	"born_under_pitch_darkness", 
	"born_under_sudden_sky_flash", 
	"born_under_violet_sky_haze",
	"born_under_twin_celestial_lights", 
	"born_under_streaking_fireball", 
	"born_under_freezing_sky_frost",
]


const SKY_CLUE_IDS: Array[String] = [
	"in_the_east", 
	"in_the_west", 
	"in_the_north", 
	"in_the_south",
	"blindingly_bright_star", 
	"dimming_shadow_light", 
	"rapid_flickering_pulse",
	"expanding_ring_halo", 
	"long_trailing_tail", 
	"surface_filament_arc", 
	"stretched_gas_ribbon",
	"fiery_golden_red_glow", 
	"cold_blue_violet_light",
]
