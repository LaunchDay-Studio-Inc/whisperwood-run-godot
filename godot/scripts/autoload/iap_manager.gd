## IAPManager — In-app purchase handling
extends Node

signal purchase_completed(product_id: String)
signal purchase_failed(product_id: String, error: String)

const PRODUCT_REMOVE_ADS := "com.launchdaystudio.whisperwoodrun.remove_ads"

var _billing_plugin = null
var _products_loaded: bool = false

func _ready() -> void:
	if GameManager.is_web:
		return
	_init_billing()

func _init_billing() -> void:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		_billing_plugin = Engine.get_singleton("GodotGooglePlayBilling")
		_billing_plugin.connected.connect(_on_connected)
		_billing_plugin.disconnected.connect(_on_disconnected)
		_billing_plugin.sku_details_query_completed.connect(_on_sku_details)
		_billing_plugin.purchases_updated.connect(_on_purchases_updated)
		_billing_plugin.purchase_error.connect(_on_purchase_error)
		_billing_plugin.startConnection()
	else:
		push_warning("IAPManager: Google Play Billing not available")

func _on_connected() -> void:
	_billing_plugin.querySkuDetails([PRODUCT_REMOVE_ADS], "inapp")

func _on_disconnected() -> void:
	push_warning("IAPManager: Billing disconnected")

func _on_sku_details(details) -> void:
	_products_loaded = true

func purchase_remove_ads() -> void:
	if GameManager.is_web:
		push_warning("IAPManager: IAP not available on web")
		return
	if _billing_plugin and _products_loaded:
		_billing_plugin.purchase(PRODUCT_REMOVE_ADS)
	else:
		purchase_failed.emit(PRODUCT_REMOVE_ADS, "Billing not ready")

func _on_purchases_updated(purchases) -> void:
	for purchase in purchases:
		if purchase.sku == PRODUCT_REMOVE_ADS:
			_billing_plugin.acknowledgePurchase(purchase.purchase_token)
			AdManager.remove_ads()
			purchase_completed.emit(PRODUCT_REMOVE_ADS)

func _on_purchase_error(response_code, debug_message) -> void:
	purchase_failed.emit(PRODUCT_REMOVE_ADS, "Error %d: %s" % [response_code, debug_message])

func restore_purchases() -> void:
	if _billing_plugin:
		_billing_plugin.queryPurchases("inapp")
