## EventBus — Global signal hub for decoupled communication
extends Node

# Runner signals
signal run_started
signal run_ended(score: int, distance: float, seeds: int)
signal player_crashed
signal player_revived
signal lane_changed(new_lane: int)
signal score_changed(new_score: int)
signal distance_changed(new_distance: float)
signal seeds_changed(new_seeds: int)
signal powerup_collected(type: String)
signal powerup_expired(type: String)
signal portal_entered(portal_type: String)
signal difficulty_changed(level: int)

# Grove signals
signal grove_entered
signal grove_exited
signal building_placed(building_id: String, grid_pos: Vector2i)
signal building_upgraded(building_id: String, new_level: int)
signal building_removed(building_id: String)

# Economy signals
signal seeds_updated(total: int)
signal gems_updated(total: int)
signal currency_spent(type: String, amount: int)

# Quest signals
signal quest_progress(quest_id: String, current: int, target: int)
signal quest_completed(quest_id: String)
signal daily_reward_claimed(day: int)

# Monetization signals
signal ad_rewarded(placement: String)
signal ad_failed(placement: String)
signal iap_purchased(product_id: String)
signal ads_removed

# UI signals  
signal screen_changed(screen_name: String)
signal popup_opened(popup_name: String)
signal popup_closed(popup_name: String)

# Analytics
signal analytics_event(event_name: String, params: Dictionary)
