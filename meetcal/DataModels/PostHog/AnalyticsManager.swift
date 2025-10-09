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
        var eventProperties = properties ?? [:]
        eventProperties["screen_name"] = screenName
        PostHogSDK.shared.capture("screen_viewed", properties: eventProperties)
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
    func trackMeetViewed(meetId: String, meetName: String, meetDate: String) {
        PostHogSDK.shared.capture("meet_viewed", properties: [
            "meet_id": meetId,
            "meet_name": meetName,
            "meet_date": meetDate
        ])
    }

    func trackMeetSaved(meetId: String, meetName: String) {
        PostHogSDK.shared.capture("meet_saved", properties: [
            "meet_id": meetId,
            "meet_name": meetName
        ])
    }

    func trackMeetUnsaved(meetId: String, meetName: String) {
        PostHogSDK.shared.capture("meet_unsaved", properties: [
            "meet_id": meetId,
            "meet_name": meetName
        ])
    }

    func trackMeetAddedToCalendar(meetId: String, meetName: String, sessionType: String) {
        PostHogSDK.shared.capture("meet_added_to_calendar", properties: [
            "meet_id": meetId,
            "meet_name": meetName,
            "session_type": sessionType
        ])
    }

    func trackMeetDetailsViewed(meetId: String, meetName: String) {
        PostHogSDK.shared.capture("meet_details_viewed", properties: [
            "meet_id": meetId,
            "meet_name": meetName
        ])
    }

    func trackMeetResultsViewed(meetId: String, meetName: String) {
        PostHogSDK.shared.capture("meet_results_viewed", properties: [
            "meet_id": meetId,
            "meet_name": meetName
        ])
    }

    func trackMeetSelected(meetName: String) {
        PostHogSDK.shared.capture("meet_selected", properties: [
            "meet_name": meetName
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
