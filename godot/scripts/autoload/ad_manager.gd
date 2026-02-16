## AdManager — Handles AdMob rewarded/interstitial + web fallback
extends Node

signal rewarded_ad_completed(placement: String)
signal rewarded_ad_failed(placement: String)
signal interstitial_closed

var _admob_plugin = null
var _rewarded_loaded: bool = false
var _interstitial_loaded: bool = false
var _pending_placement: String = ""

# AdMob IDs (replace with real ones before release)
const REWARDED_AD_ID_ANDROID := "ca-app-pub-XXXX/YYYY"
const INTERSTITIAL_AD_ID_ANDROID := "ca-app-pub-XXXX/ZZZZ"

func _ready() -> void:
	if GameManager.is_web:
		return  # No AdMob on web
	_init_admob()

func _init_admob() -> void:
	if Engine.has_singleton("AdMob"):
		_admob_plugin = Engine.get_singleton("AdMob")
		_admob_plugin.init(false)  # false = non-personalized
		_load_rewarded()
		_load_interstitial()
	else:
		push_warning("AdManager: AdMob plugin not found — ads disabled")

func _load_rewarded() -> void:
	if _admob_plugin:
		_admob_plugin.load_rewarded(REWARDED_AD_ID_ANDROID)

func _load_interstitial() -> void:
	if _admob_plugin and not GameManager.ads_removed:
		_admob_plugin.load_interstitial(INTERSTITIAL_AD_ID_ANDROID)

func show_rewarded(placement: String) -> void:
	_pending_placement = placement
	if GameManager.is_web:
		_handle_web_rewarded(placement)
		return
	if _admob_plugin and _rewarded_loaded:
		_admob_plugin.show_rewarded()
	else:
		rewarded_ad_failed.emit(placement)
		EventBus.ad_failed.emit(placement)

func show_interstitial() -> void:
	if GameManager.ads_removed or GameManager.is_web:
		interstitial_closed.emit()
		return
	if not GameManager.should_show_interstitial():
		interstitial_closed.emit()
		return
	if _admob_plugin and _interstitial_loaded:
		_admob_plugin.show_interstitial()
		GameManager.runs_since_interstitial = 0
	else:
		interstitial_closed.emit()

func _handle_web_rewarded(placement: String) -> void:
	# Web: allow one free revive per day, or spend gems
	match placement:
		"revive":
			if not GameManager.free_revive_used_today:
				GameManager.free_revive_used_today = true
				rewarded_ad_completed.emit(placement)
				EventBus.ad_rewarded.emit(placement)
			elif GameManager.gems >= 5:
				GameManager.gems -= 5
				rewarded_ad_completed.emit(placement)
				EventBus.ad_rewarded.emit(placement)
			else:
				rewarded_ad_failed.emit(placement)
				EventBus.ad_failed.emit(placement)
		"double_reward":
			if GameManager.gems >= 3:
				GameManager.gems -= 3
				rewarded_ad_completed.emit(placement)
				EventBus.ad_rewarded.emit(placement)
			else:
				rewarded_ad_failed.emit(placement)
				EventBus.ad_failed.emit(placement)
		_:
			rewarded_ad_failed.emit(placement)

# AdMob callbacks (connected when plugin is available)
func _on_rewarded_ad_loaded() -> void:
	_rewarded_loaded = true

func _on_rewarded_ad_earned_reward(_currency, _amount) -> void:
	_rewarded_loaded = false
	rewarded_ad_completed.emit(_pending_placement)
	EventBus.ad_rewarded.emit(_pending_placement)
	_load_rewarded()

func _on_rewarded_ad_failed_to_load(_error) -> void:
	_rewarded_loaded = false

func _on_interstitial_loaded() -> void:
	_interstitial_loaded = true

func _on_interstitial_closed() -> void:
	_interstitial_loaded = false
	interstitial_closed.emit()
	_load_interstitial()

func remove_ads() -> void:
	GameManager.ads_removed = true
	EventBus.ads_removed.emit()
	GameManager.save_game()
