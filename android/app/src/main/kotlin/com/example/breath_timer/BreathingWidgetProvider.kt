package com.example.breath_timer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

class BreathingWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        // Handle widget tap
        if (intent.action == "START_BREATHING") {
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("START_FAVORITE_PRESET", true)
            }
            context.startActivity(launchIntent)
        }
    }
}

internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    // Get data from HomeWidget
    val widgetData = HomeWidgetPlugin.getData(context)

    // Extract favorite preset data
    val favoritePresetJson = widgetData.getString("favorite_preset", null)
    val currentPhase = widgetData.getString("current_phase", "Ready")
    val isAODMode = widgetData.getBoolean("aod_mode", false)

    // Choose layout based on AOD mode
    val layoutRes = if (isAODMode) R.layout.breathing_widget_aod else R.layout.breathing_widget
    val views = RemoteViews(context.packageName, layoutRes)

    if (favoritePresetJson != null) {
        try {
            // Parse the JSON data
            val presetData = JSONObject(favoritePresetJson)
            val presetName = presetData.getString("name")

            if (isAODMode) {
                // AOD mode - simplified layout
                views.setTextViewText(R.id.widget_phase, (currentPhase ?: "READY").uppercase())
                views.setTextViewText(R.id.widget_preset_name, presetName.uppercase())
            } else {
                // Regular mode - full layout
                views.setTextViewText(R.id.widget_title, "Breathing Timer")
                views.setTextViewText(R.id.widget_preset_name, presetName)
                views.setTextViewText(R.id.widget_phase, currentPhase ?: "Ready")
            }

            // Set tap intent (only for regular mode, AOD usually doesn't support interactions)
            if (!isAODMode) {
                val intent = Intent(context, BreathingWidgetProvider::class.java).apply {
                    action = "START_BREATHING"
                }
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

        } catch (e: Exception) {
            // Fallback to default
            setDefaultWidgetState(views, isAODMode)
        }
    } else {
        setDefaultWidgetState(views, isAODMode)
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun setDefaultWidgetState(views: RemoteViews, isAODMode: Boolean = false) {
    if (isAODMode) {
        views.setTextViewText(R.id.widget_phase, "READY")
        views.setTextViewText(R.id.widget_preset_name, "NO FAVORITE")
    } else {
        views.setTextViewText(R.id.widget_title, "Breathing Timer")
        views.setTextViewText(R.id.widget_preset_name, "No favorite set")
        views.setTextViewText(R.id.widget_phase, "Tap to start")
    }
}