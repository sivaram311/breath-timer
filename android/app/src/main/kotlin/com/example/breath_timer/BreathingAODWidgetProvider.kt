package com.example.breath_timer

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject

class BreathingAODWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAODAppWidget(context, appWidgetManager, appWidgetId)
        }
    }
}

internal fun updateAODAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    // Get data from HomeWidget
    val widgetData = HomeWidgetPlugin.getData(context)

    // Extract favorite preset data
    val favoritePresetJson = widgetData.getString("favorite_preset", null)
    val currentPhase = widgetData.getString("current_phase", "Ready")

    val views = RemoteViews(context.packageName, R.layout.breathing_widget_aod)

    if (favoritePresetJson != null) {
        try {
            // Parse the JSON data
            val presetData = JSONObject(favoritePresetJson)
            val presetName = presetData.getString("name")

            // AOD mode - simplified layout
            views.setTextViewText(R.id.widget_phase, (currentPhase ?: "READY").uppercase())
            views.setTextViewText(R.id.widget_preset_name, presetName.uppercase())

            // AOD widgets typically don't support interactions for battery saving

        } catch (e: Exception) {
            // Fallback to default
            setAODDefaultWidgetState(views)
        }
    } else {
        setAODDefaultWidgetState(views)
    }

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun setAODDefaultWidgetState(views: RemoteViews) {
    views.setTextViewText(R.id.widget_phase, "READY")
    views.setTextViewText(R.id.widget_preset_name, "NO FAVORITE")
}