//
//  AnalyticsManager.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/4/25.
//

import Foundation
import PostHog

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    // MARK: - Screen Views
    func trackScreenView(_ screenName: String, properties: [String: Any]? = nil) {
        PostHogSDK.shared.screen(screenName, properties: properties)
    }

    // MARK: - User Authentication
    func trackUserSignedUp(method: String) {
        PostHogSDK.shared.capture("user_signed_up", properties: ["method": method])
    }

    func trackUserSignedIn(method: String) {
        PostHogSDK.shared.capture("user_signed_in", properties: ["method": method])
    }

    func trackUserSignedOut() {
        PostHogSDK.shared.capture("user_signed_out")
    }

    // MARK: - Onboarding
    func trackOnboardingStarted() {
        PostHogSDK.shared.capture("onboarding_started")
    }

    func trackOnboardingCompleted() {
        PostHogSDK.shared.capture("onboarding_completed")
    }

    func trackOnboardingSkipped() {
        PostHogSDK.shared.capture("onboarding_skipped")
    }

    // MARK: - Meet Engagement
    func trackMeetViewed(meetName: String, meetDate: String) {
        PostHogSDK.shared.capture("meet_viewed", properties: [
            "meet_name": meetName,
            "meet_date": meetDate
        ])
    }

    func trackMeetSaved(meetName: String) {
        PostHogSDK.shared.capture("meet_saved", properties: [
            "meet_name": meetName
        ])
    }

    func trackMeetUnsaved(meetName: String) {
        PostHogSDK.shared.capture("meet_unsaved", properties: [
            "meet_name": meetName
        ])
    }

    func trackMeetAddedToCalendar(meetName: String, sessionType: String) {
        PostHogSDK.shared.capture("meet_added_to_calendar", properties: [
            "meet_name": meetName,
            "session_type": sessionType
        ])
    }

    func trackMeetDetailsViewed(meetName: String) {
        PostHogSDK.shared.capture("meet_details_viewed", properties: [
            "meet_name": meetName
        ])
    }

    func trackMeetResultsViewed(meetName: String) {
        PostHogSDK.shared.capture("meet_results_viewed", properties: [
            "meet_name": meetName
        ])
    }

    func trackMeetSelected(meetName: String) {
        PostHogSDK.shared.capture("meet_selected", properties: [
            "meet_name": meetName
        ])
    }

    func trackScheduleImageGenerated(meetName: String, club: String) {
        PostHogSDK.shared.capture("schedule_image_generated", properties: [
            "meet_name": meetName,
            "club": club
        ])
    }

    func trackSessionViewed(meetName: String, sessionNumber: Int, platform: String, weightClass: String) {
        PostHogSDK.shared.capture("session_viewed", properties: [
            "meet_name": meetName,
            "session_number": sessionNumber,
            "platform": platform,
            "weight_class": weightClass
        ])
    }

    func trackSessionSaved(meetName: String, sessionNumber: Int, platform: String, athleteCount: Int) {
        PostHogSDK.shared.capture("session_saved", properties: [
            "meet_name": meetName,
            "session_number": sessionNumber,
            "platform": platform,
            "athlete_count": athleteCount
        ])
    }

    func trackSessionUnsaved(meetName: String, sessionNumber: Int, platform: String) {
        PostHogSDK.shared.capture("session_unsaved", properties: [
            "meet_name": meetName,
            "session_number": sessionNumber,
            "platform": platform
        ])
    }

    func trackBulkSessionsDeleted(meetName: String, sessionCount: Int) {
        PostHogSDK.shared.capture("bulk_sessions_deleted", properties: [
            "meet_name": meetName,
            "session_count": sessionCount
        ])
    }

    func trackBulkCalendarAdded(meetName: String, sessionCount: Int, successCount: Int, failCount: Int) {
        PostHogSDK.shared.capture("bulk_calendar_added", properties: [
            "meet_name": meetName,
            "session_count": sessionCount,
            "success_count": successCount,
            "fail_count": failCount
        ])
    }

    // MARK: - Search & Browse
    func trackSearchPerformed(query: String, resultsCount: Int) {
        PostHogSDK.shared.capture("search_performed", properties: [
            "query": query,
            "results_count": resultsCount
        ])
    }

    func trackAthleteSearched(athleteName: String, found: Bool) {
        PostHogSDK.shared.capture("athlete_searched", properties: [
            "athlete_name": athleteName,
            "found": found
        ])
    }

    func trackStartListViewed(meetId: String) {
        PostHogSDK.shared.capture("start_list_viewed", properties: [
            "meet_id": meetId
        ])
    }

    func trackTabSwitched(fromTab: String, toTab: String) {
        PostHogSDK.shared.capture("tab_switched", properties: [
            "from_tab": fromTab,
            "to_tab": toTab
        ])
    }

    // MARK: - Competition Data
    func trackRecordsViewed(type: String) {
        PostHogSDK.shared.capture("records_viewed", properties: [
            "type": type
        ])
    }

    func trackRankingsViewed(filters: [String: Any]? = nil) {
        var properties: [String: Any] = [:]
        if let filters = filters {
            properties["filters"] = filters
        }
        PostHogSDK.shared.capture("rankings_viewed", properties: properties)
    }

    func trackQualifyingTotalsViewed() {
        PostHogSDK.shared.capture("qualifying_totals_viewed")
    }

    func trackStandardsViewed() {
        PostHogSDK.shared.capture("standards_viewed")
    }

    func trackFiltersApplied(type: String, values: [String: Any]) {
        PostHogSDK.shared.capture("filters_applied", properties: [
            "filter_type": type,
            "filter_values": values
        ])
    }

    func trackAttemptsGuesserViewed(meetName: String, sessionNumber: Int, athleteCount: Int) {
        PostHogSDK.shared.capture("attempts_guesser_viewed", properties: [
            "meet_name": meetName,
            "session_number": sessionNumber,
            "athlete_count": athleteCount
        ])
    }

    func trackAthleteHistorySearched(query: String, resultsCount: Int) {
        PostHogSDK.shared.capture("athlete_history_searched", properties: [
            "query": query,
            "results_count": resultsCount
        ])
    }

    func trackAthleteHistoryViewed(athleteName: String) {
        PostHogSDK.shared.capture("athlete_history_viewed", properties: [
            "athlete_name": athleteName
        ])
    }

    // MARK: - Feature Navigation
    func trackFeatureAccessed(featureName: String, source: String) {
        PostHogSDK.shared.capture("feature_accessed", properties: [
            "feature_name": featureName,
            "source": source
        ])
    }

    func trackScheduleDayChanged(meetName: String, dayIndex: Int, totalDays: Int) {
        PostHogSDK.shared.capture("schedule_day_changed", properties: [
            "meet_name": meetName,
            "day_index": dayIndex,
            "total_days": totalDays
        ])
    }

    func trackContentRefreshed(screenName: String) {
        PostHogSDK.shared.capture("content_refreshed", properties: [
            "screen_name": screenName
        ])
    }

    func trackMeetOverlayOpened() {
        PostHogSDK.shared.capture("meet_overlay_opened")
    }

    // MARK: - Monetization
    func trackPaywallViewed(triggerLocation: String) {
        PostHogSDK.shared.capture("paywall_viewed", properties: [
            "trigger_location": triggerLocation
        ])
    }

    func trackSubscriptionStarted(tier: String) {
        PostHogSDK.shared.capture("subscription_started", properties: [
            "tier": tier
        ])
    }

    func trackSubscriptionCancelled() {
        PostHogSDK.shared.capture("subscription_cancelled")
    }

    func trackSubscriptionRestored() {
        PostHogSDK.shared.capture("subscription_restored")
    }

    func trackProFeatureAttemptedWithoutAccess(featureName: String) {
        PostHogSDK.shared.capture("pro_feature_attempted_without_access", properties: [
            "feature_name": featureName
        ])
    }

    // MARK: - Notifications
    func trackNotificationPermissionRequested() {
        PostHogSDK.shared.capture("notification_permission_requested")
    }

    func trackNotificationPermissionGranted() {
        PostHogSDK.shared.capture("notification_permission_granted")
    }

    func trackNotificationPermissionDenied() {
        PostHogSDK.shared.capture("notification_permission_denied")
    }

    func trackNotificationReceived(type: String) {
        PostHogSDK.shared.capture("notification_received", properties: [
            "type": type
        ])
    }

    func trackNotificationOpened(type: String) {
        PostHogSDK.shared.capture("notification_opened", properties: [
            "type": type
        ])
    }

    // MARK: - App Lifecycle
    func trackAppOpened(fromNotification: Bool = false) {
        PostHogSDK.shared.capture("app_opened", properties: [
            "from_notification": fromNotification
        ])
    }

    func trackAppBackgrounded() {
        PostHogSDK.shared.capture("app_backgrounded")
    }

    // MARK: - Sponsors
    func trackSponsorTabViewed() {
        PostHogSDK.shared.capture("sponsor_tab_viewed")
    }

    func trackSponsorClicked(sponsorName: String) {
        PostHogSDK.shared.capture("sponsor_clicked", properties: [
            "sponsor_name": sponsorName
        ])
    }

    // MARK: - User Properties
    func identifyUser(userId: String) {
        PostHogSDK.shared.identify(userId)
    }

    func setUserProperties(_ properties: [String: Any]) {
        PostHogSDK.shared.capture("$set", properties: properties)
    }

    func setSubscriptionStatus(_ status: String) {
        setUserProperties(["subscription_status": status])
    }

    func setMeetsSavedCount(_ count: Int) {
        setUserProperties(["meets_saved_count": count])
    }

    func setOnboardingCompleted(_ completed: Bool) {
        setUserProperties(["onboarding_completed": completed])
    }

    func setNotificationEnabled(_ enabled: Bool) {
        setUserProperties(["notification_enabled": enabled])
    }
}
