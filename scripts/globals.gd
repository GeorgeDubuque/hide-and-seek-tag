extends Node

enum PlayerType {NONE, TAGGER, HIDER}
enum PlayerStatus {NONE, FROZEN, UNFROZEN}
enum GameStatus {LOBBY, IN_GAME}
enum HiderColor {RED, GREEN, BLUE}

const LAYER_INTERACT = 1 << 5
const LAYER_FREEZE = 1 << 31
const LAYER_UNFREEZE = 1 << 30
