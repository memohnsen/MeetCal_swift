//
//  OfflineModeView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 10/14/25.
//

import SwiftUI
import SwiftData
import RevenueCat
import RevenueCatUI

struct OfflineModeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext

    @Query private var allScheduleEntities: [ScheduleEntity]
    @Query private var allMeetDetailsEntities: [MeetDetailsEntity]
    @Query private var allStartListEntities: [StartListEntity]

    @State private var downloadingItems: Set<String> = []
    @State private var refreshID = UUID()

    @StateObject private var meetsModel = MeetsScheduleModel()
    var meets: [MeetsRow] { meetsModel.threeWeeksMeets }

    private var downloadedMeetNames: Set<String> {
        var meetNames = Set<String>()

        meetNames.formUnion(allScheduleEntities.compactMap { $0.meet })

        meetNames.formUnion(allMeetDetailsEntities.map { $0.name })

        meetNames.formUnion(allStartListEntities.compactMap { $0.meet })

        return meetNames
    }

    @StateObject private var adaptiveModel = AdaptiveRecordsModel()
    @StateObject private var recordsModel = RecordsViewModel()
    @StateObject private var natRankingsModel = NationalRankingsModel()
    @StateObject private var qtModel = QualifyingTotalModel()
    @StateObject private var intlRankingsModel = IntlRankingsViewModel()
    @StateObject private var savedModel = SavedViewModel()
    @StateObject private var schedDetailsModel = ScheduleDetailsModel()
    @StateObject private var standardsModel = StandardsViewModel()
    @StateObject private var startModel = StartListModel()
    @StateObject private var wsoModel = WSOViewModel()

    @State private var alertShowing: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var isRefreshing: Bool = false

    // MARK: - SwiftData Helpers (Single Source of Truth)

    func isItemDownloaded(_ title: String) -> Bool {
        switch title {
        case "Adaptive American Records":
            return hasAdaptiveData()
        case "American Records":
            return hasAmericanRecordsData()
        case "WSO Records":
            return hasWSOData()
        case "A/B Standards":
            return hasStandardsData()
        case "International Rankings":
            return hasIntlRankingsData()
        case "National Rankings":
            return hasNatRankingsData()
        case "Qualifying Totals":
            return hasQTData()
        default:
            return false
        }
    }

    func isMeetScheduleDownloaded(_ meetName: String) -> Bool {
        return downloadedMeetNames.contains(meetName)
    }

    func isMeetStartListDownloaded(_ meetName: String) -> Bool {
        var descriptor = FetchDescriptor<StartListEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    func hasAdaptiveData() -> Bool {
        var descriptor = FetchDescriptor<AdaptiveRecordEntity>()
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    func hasAmericanRecordsData() -> Bool {
        var descriptor = FetchDescriptor<AmericanRecordEntity>()
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    func hasWSOData() -> Bool {
        var descriptor = FetchDescriptor<WSOEntity>()
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    func hasStandardsData() -> Bool {
        var descriptor = FetchDescriptor<StandardsEntity>()
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    func hasIntlRankingsData() -> Bool {
        var descriptor = FetchDescriptor<RankingsEntity>()
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    func hasNatRankingsData() -> Bool {
        var descriptor = FetchDescriptor<NatRankingsEntity>()
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    func hasQTData() -> Bool {
        var descriptor = FetchDescriptor<QTEntity>()
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }

    // MARK: - Last Synced Date Functions

    func getLastSyncedDate(for title: String, meetName: String? = nil) -> Date? {
        if let meetName = meetName {
            let descriptor = FetchDescriptor<MeetDetailsEntity>(
                predicate: #Predicate { $0.name == meetName }
            )
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
            return nil
        }

        switch title {
        case "Adaptive American Records":
            let descriptor = FetchDescriptor<AdaptiveRecordEntity>()
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
        case "American Records":
            let descriptor = FetchDescriptor<AmericanRecordEntity>()
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
        case "WSO Records":
            let descriptor = FetchDescriptor<WSOEntity>()
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
        case "A/B Standards":
            let descriptor = FetchDescriptor<StandardsEntity>()
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
        case "International Rankings":
            let descriptor = FetchDescriptor<RankingsEntity>()
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
        case "National Rankings":
            let descriptor = FetchDescriptor<NatRankingsEntity>()
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
        case "Qualifying Totals":
            let descriptor = FetchDescriptor<QTEntity>()
            if let entities = try? modelContext.fetch(descriptor),
               let firstEntity = entities.first {
                return firstEntity.lastSynced
            }
        default:
            break
        }
        return nil
    }

    // MARK: - Download Functions
    
    func downloadMeets() async {
        let itemName = "Meets"
        downloadingItems.insert(itemName)
        meetsModel.setModelContext(modelContext)

        meetsModel.meets.removeAll()

        await meetsModel.loadMeets()

        do {
            try meetsModel.saveMeetsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "Meets have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteMeetData(meetName: String) {
        let detailsDescriptor = FetchDescriptor<MeetDetailsEntity>(
            predicate: #Predicate { $0.name == meetName }
        )
        let detailsRecords = try? modelContext.fetch(detailsDescriptor)
        detailsRecords?.forEach { modelContext.delete($0) }

        let schedDescriptor = FetchDescriptor<ScheduleEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        let schedRecords = try? modelContext.fetch(schedDescriptor)
        schedRecords?.forEach { modelContext.delete($0) }

        let startListDescriptor = FetchDescriptor<StartListEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        let startListRecords = try? modelContext.fetch(startListDescriptor)
        startListRecords?.forEach { modelContext.delete($0) }

        let schedDetailsDescriptor = FetchDescriptor<SchedDetailsEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        let schedDetailsRecords = try? modelContext.fetch(schedDetailsDescriptor)
        schedDetailsRecords?.forEach { modelContext.delete($0) }

        let resultsDescriptor = FetchDescriptor<ResultsEntity>()
        let allResults = try? modelContext.fetch(resultsDescriptor)
        let schedDetailsAthletes = schedDetailsRecords?.map { $0.name } ?? []
        allResults?.filter { schedDetailsAthletes.contains($0.name) }.forEach { modelContext.delete($0) }

        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "\(meetName) has been deleted from your device."
        alertShowing = true
    }

    func deleteMeets() {
        let descriptor = FetchDescriptor<MeetsEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()
    }
    
    func downloadMeetData(meetName: String) async {
        let itemName = "Schedule-\(meetName)"
        downloadingItems.insert(itemName)

        meetsModel.setModelContext(modelContext)
        startModel.setModelContext(modelContext)
        schedDetailsModel.setModelContext(modelContext)

        meetsModel.meetDetails.removeAll()
        meetsModel.schedule.removeAll()
        startModel.athletes.removeAll()
        schedDetailsModel.athletes.removeAll()
        schedDetailsModel.athleteResults.removeAll()

        do {
            await meetsModel.loadMeetDetails(meetName: meetName)
            try meetsModel.saveMeetDetailsToSwiftData()

            await meetsModel.loadMeetSchedule(meet: meetName)
            try meetsModel.saveScheduleToSwiftData()

            await startModel.loadStartList(meet: meetName)
            try startModel.saveStartListToSwiftData()

            let sessions = Set(meetsModel.schedule.map { $0.session_id })
            for sessionID in sessions {
                await schedDetailsModel.loadAthletes(meet: meetName, sessionID: sessionID, platform: "ALL")
            }
            try schedDetailsModel.saveSchedDetailsToSwiftData()

            let uniqueAthletes = Set(schedDetailsModel.athletes.map { $0.name })
            for athleteName in uniqueAthletes {
                await schedDetailsModel.loadResults(name: athleteName)
            }
            try schedDetailsModel.saveResultsToSwiftData()

            alertTitle = "Saved Successfully"
            alertMessage = "\(meetName) has been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }

    func downloadMeetDetails(meetName: String) async {
        let itemName = "Meet Details"
        downloadingItems.insert(itemName)
        meetsModel.setModelContext(modelContext)

        meetsModel.meetDetails.removeAll()

        await meetsModel.loadMeetDetails(meetName: meetName)

        do {
            try meetsModel.saveMeetDetailsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "Meet Details have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteMeetDetails() {
        let descriptor = FetchDescriptor<MeetDetailsEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "Meet Details have been deleted from your device."
        alertShowing = true
    }

    func downloadSched(meetName: String) async {
        let itemName = "Schedule"
        downloadingItems.insert(itemName)
        meetsModel.setModelContext(modelContext)

        meetsModel.schedule.removeAll()

        await meetsModel.loadMeetSchedule(meet: meetName)

        do {
            try meetsModel.saveScheduleToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "Meet Schedule has been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteSched() {
        let descriptor = FetchDescriptor<ScheduleEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "Schedule has been deleted from your device."
        alertShowing = true
    }

    func downloadStartList(meetName: String) async {
        let itemName = "Start List"
        downloadingItems.insert(itemName)
        startModel.setModelContext(modelContext)

        startModel.athletes.removeAll()

        await startModel.loadStartList(meet: meetName)

        do {
            try startModel.saveStartListToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "Start List has been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteStartList() {
        let descriptor = FetchDescriptor<StartListEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "Start List has been deleted from your device."
        alertShowing = true
    }

    func downloadSchedDetails(meetName: String) async {
        let itemName = "Schedule Details"
        downloadingItems.insert(itemName)
        schedDetailsModel.setModelContext(modelContext)

        schedDetailsModel.athletes.removeAll()

        await meetsModel.loadMeetSchedule(meet: meetName)
        let sessions = Set(meetsModel.schedule.map { $0.session_id })

        for sessionID in sessions {
            await schedDetailsModel.loadAthletes(meet: meetName, sessionID: sessionID, platform: "ALL")
        }

        do {
            try schedDetailsModel.saveSchedDetailsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "Schedule Details have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteSchedDetails() {
        let descriptor = FetchDescriptor<SchedDetailsEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "Schedule Details have been deleted from your device."
        alertShowing = true
    }

    func downloadAdapRecords() async {
        let itemName = "Adaptive American Records"
        downloadingItems.insert(itemName)
        adaptiveModel.setModelContext(modelContext)

        adaptiveModel.groupedRecords.removeAll()

        await adaptiveModel.loadAdaptiveRecords(gender: "Men")
        await adaptiveModel.loadAdaptiveRecords(gender: "Women")

        do {
            try adaptiveModel.saveAdapRecordsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "Adaptive American Records have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteAdaptiveRecords() {
        let descriptor = FetchDescriptor<AdaptiveRecordEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "Adaptive American Records have been deleted from your device."
        alertShowing = true
    }

    func downloadStandards() async {
        let itemName = "A/B Standards"
        downloadingItems.insert(itemName)
        standardsModel.setModelContext(modelContext)
        
        standardsModel.standards.removeAll()
        
        let ages = ["u15", "youth", "junior", "senior"]
        
        for age in ages {
            await standardsModel.loadStandards(gender: "men", ageCategory: age)
            await standardsModel.loadStandards(gender: "women", ageCategory: age)
        }
        
        do {
            try standardsModel.saveStandardsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "A/B Standards have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }
        downloadingItems.remove(itemName)
    }
    
    func deleteStandards() {
        let descriptor = FetchDescriptor<StandardsEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "A/B Standards have been deleted from your device."
        alertShowing = true
    }

    func downloadAmRecords() async {
        let itemName = "American Records"
        downloadingItems.insert(itemName)
        recordsModel.setModelContext(modelContext)
        
        recordsModel.records.removeAll()
        
        let ages = ["u13", "u15", "u17", "junior", "university", "senior",
                    "masters 30", "masters 35", "masters 40", "masters 45", "masters 50",
                    "masters 55", "masters 60", "masters 65", "masters 70", "masters 75",
                    "masters 80", "masters 85",
                    "masters 35-39", "masters 40-44", "masters 45-49", "masters 50-54",
                    "masters 55-59", "masters 60-64", "masters 65-69", "masters 70-74",
                    "masters 75-79", "masters 80-84", "masters 85-89", "masters +90"]
        
        for age in ages {
            await recordsModel.loadRecords(gender: "men", ageCategory: age, record_type: "USAW")
            await recordsModel.loadRecords(gender: "women", ageCategory: age, record_type: "USAW")
            await recordsModel.loadRecords(gender: "men", ageCategory: age, record_type: "USAMW")
            await recordsModel.loadRecords(gender: "women", ageCategory: age, record_type: "USAMW")
        }
        
        do {
            try recordsModel.saveAmRecordsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "American Records have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }
        downloadingItems.remove(itemName)
    }
    
    func deleteAmRecords() {
        let descriptor = FetchDescriptor<AmericanRecordEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "American Records have been deleted from your device."
        alertShowing = true
    }

    func downloadIntlRankings() async {
        let itemName = "International Rankings"
        downloadingItems.insert(itemName)
        intlRankingsModel.setModelContext(modelContext)

        intlRankingsModel.rankings.removeAll()

        let ages = ["U15", "U17", "Junior", "Senior"]

        for age in ages {
            await intlRankingsModel.loadMeet(gender: "Men", ageCategory: age)
            await intlRankingsModel.loadMeet(gender: "Women", ageCategory: age)
            let meets = intlRankingsModel.meets

            for meet in meets {
                await intlRankingsModel.loadRankings(gender: "Men", ageCategory: age, meet: meet)
                await intlRankingsModel.loadRankings(gender: "Women", ageCategory: age, meet: meet)
            }
        }

        do {
            try intlRankingsModel.saveIntlRankingsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "International Rankings have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteIntlRankings() {
        let descriptor = FetchDescriptor<RankingsEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "International Rankings have been deleted from your device."
        alertShowing = true
    }

    func downloadNatRankings() async {
        let itemName = "National Rankings"
        downloadingItems.insert(itemName)
        natRankingsModel.setModelContext(modelContext)
        
        natRankingsModel.rankings.removeAll()
        
        let ages = [
            "U11", "U13", "U15", "U17", "Junior", "Senior",
            "Masters 35", "Masters 40", "Masters 45", "Masters 50", "Masters 55",
            "Masters 60", "Masters 65", "Masters 70", "Masters 75", "Masters 80",
            "Masters 85", "Masters 90+"
        ]
        
        func getWeightClasses(for gender: String, ageGroup: String) -> [String] {
            let prefix: String

            switch ageGroup {
            case "U11":
                 prefix = "\(gender)'s 11 Under Age Group"
            case "U13":
                prefix = "\(gender)'s 13 Under Age Group"
            case "U15":
                prefix = "\(gender)'s 14-15 Age Group"
            case "U17":
                prefix = "\(gender)'s 16-17 Age Group"
            case "Junior":
                prefix = "Junior \(gender)"
            case "Senior":
                prefix = "Open \(gender)"
            case "Masters 35":
                prefix = "\(gender)'s Masters (35-39)"
            case "Masters 40":
                prefix = "\(gender)'s Masters (40-44)"
            case "Masters 45":
                prefix = "\(gender)'s Masters (45-49)"
            case "Masters 50":
                prefix = "\(gender)'s Masters (50-54)"
            case "Masters 55":
                prefix = "\(gender)'s Masters (55-59)"
            case "Masters 60":
                prefix = "\(gender)'s Masters (60-64)"
            case "Masters 65":
                prefix = "\(gender)'s Masters (65-69)"
            case "Masters 70":
                prefix = "\(gender)'s Masters (70-74)"
            case "Masters 75":
                prefix = "\(gender)'s Masters (75-79)"
            case "Masters 80":
                prefix = "\(gender)'s Masters (80-84)"
            case "Masters 85":
                prefix = "\(gender)'s Masters (85-89)"
            case "Masters 90+":
                prefix = "\(gender)'s Masters (90+)"

            default:
                prefix = "Open \(gender)"
            }

            switch (gender, ageGroup) {
            case ("Men", "Masters 35"), ("Men", "Masters 40"), ("Men", "Masters 45"), ("Men", "Masters 50"), ("Men", "Masters 55"), ("Men", "Masters 60"), ("Men", "Masters 65"), ("Men", "Masters 70"), ("Men", "Masters 75"), ("Men", "Masters 80"), ("Men", "Masters 85"), ("Men", "Masters 90+"):
                return ["60kg", "65kg", "71kg", "79kg", "88kg", "94kg", "110kg", "110+kg"].map { "\(prefix) \($0)" }
            case ("Women", "Masters 35"), ("Women", "Masters 40"), ("Women", "Masters 45"), ("Women", "Masters 50"), ("Women", "Masters 55"), ("Women", "Masters 60"), ("Women", "Masters 65"), ("Women", "Masters 70"), ("Women", "Masters 75"), ("Women", "Masters 80"), ("Women", "Masters 85"), ("Women", "Masters 90+"):
                return ["48kg", "53kg", "58kg", "63kg", "69kg", "77kg", "86kg", "86+kg"].map { "\(prefix) \($0)" }
            case ("Men", "Junior"), ("Men", "Senior"):
                return ["60kg", "65kg", "71kg", "79kg", "88kg", "94kg", "110kg", "110+kg"].map { "\(prefix)'s \($0)" }
            case ("Women", "Junior"), ("Women", "Senior"):
                return ["48kg", "53kg", "58kg", "63kg", "69kg", "77kg", "86kg", "86+kg"].map { "\(prefix)'s \($0)" }
            case ("Men", "U17"):
                return ["56kg", "60kg", "65kg", "71kg", "79kg", "88kg", "94kg", "94+kg"].map { "\(prefix) \($0)" }
            case ("Women", "U17"):
                return ["44kg", "48kg", "53kg", "58kg", "63kg", "69kg", "77kg", "77+kg"].map { "\(prefix) \($0)" }
            case ("Men", "U15"):
                return ["48kg", "52kg", "56kg", "60kg", "65kg", "71kg", "79kg", "79+kg"].map { "\(prefix) \($0)" }
            case ("Women", "U15"):
                return ["40kg", "44kg", "48kg", "53kg", "58kg", "63kg", "69kg", "69+kg"].map { "\(prefix) \($0)" }
            case ("Men", "U13"), ("Men", "U11"):
                return ["40kg", "44kg", "48kg", "52kg", "56kg", "60kg", "65kg", "65+kg"].map { "\(prefix) \($0)" }
            case ("Women", "U13"), ("Women", "U11"):
                return ["36kg", "40kg", "44kg", "48kg", "53kg", "58kg", "63kg", "63+kg"].map { "\(prefix) \($0)" }
            default:
                return []
            }
        }
        
        for age in ages {
            let menWeightClasses = getWeightClasses(for: "Men", ageGroup: age)
            for weightClass in menWeightClasses {
                await natRankingsModel.loadWeightClasses(age: weightClass)
            }

            let womenWeightClasses = getWeightClasses(for: "Women", ageGroup: age)
            for weightClass in womenWeightClasses {
                await natRankingsModel.loadWeightClasses(age: weightClass)
            }
        }
        
        do {
            try natRankingsModel.saveNatRankingsToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "National Rankings have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }

    func deleteNatRankings() {
        let descriptor = FetchDescriptor<NatRankingsEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "National Rankings have been deleted from your device."
        alertShowing = true
    }

    func downloadQT() async {
        let itemName = "Qualifying Totals"
        downloadingItems.insert(itemName)
        qtModel.setModelContext(modelContext)

        qtModel.totals.removeAll()

        let meets: [String] = ["Nationals", "Virus Series", "Virus Finals", "Master's Pan Ams", "IMWA Worlds"]
        
        for meet in meets {
            await qtModel.loadAgeGroup(for: "Men", event_name: meet)
            await qtModel.loadAgeGroup(for: "Women", event_name: meet)
            let ages = qtModel.ageGroups
            
            for age in ages {
                await qtModel.loadTotals(gender: "Men", age_category: age, event_name: meet)
                await qtModel.loadTotals(gender: "Women", age_category: age, event_name: meet)
            }
        }

        do {
            try qtModel.saveQTToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "Qualifying Totals have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteQT() {
        let descriptor = FetchDescriptor<QTEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "Qualifying Totals have been deleted from your device."
        alertShowing = true
    }

    func downloadWSO() async {
        let itemName = "WSO Records"
        downloadingItems.insert(itemName)
        wsoModel.setModelContext(modelContext)

        wsoModel.wsoRecords.removeAll()

        await wsoModel.loadWSO()
        let wso = wsoModel.wso

        for WSO in wso {
            await wsoModel.loadAgeGroups(gender: "Men", wso: WSO)
            await wsoModel.loadAgeGroups(gender: "Women", wso: WSO)
            let ages = wsoModel.ageGroups

            for age in ages {
                await wsoModel.loadRecords(gender: "Men", ageCategory: age, wso: WSO)
                await wsoModel.loadRecords(gender: "Women", ageCategory: age, wso: WSO)
            }
        }

        do {
            try wsoModel.saveWSOToSwiftData()
            alertTitle = "Saved Successfully"
            alertMessage = "WSO Records have been saved to your device."
            alertShowing = true
            refreshID = UUID()
        } catch {
            alertTitle = "Error"
            alertMessage = "There was an error saving your data. Make sure you are connected to internet and a Pro user."
            alertShowing = true
        }

        downloadingItems.remove(itemName)
    }
    
    func deleteWSO() {
        let descriptor = FetchDescriptor<WSOEntity>()
        let records = try? modelContext.fetch(descriptor)
        records?.forEach { modelContext.delete($0) }
        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "WSO Records have been deleted from your device."
        alertShowing = true
    }

    func deleteAllOfflineData() {
        let qtDescriptor = FetchDescriptor<QTEntity>()
        let qtRecords = try? modelContext.fetch(qtDescriptor)
        qtRecords?.forEach { modelContext.delete($0) }

        let wsoDescriptor = FetchDescriptor<WSOEntity>()
        let wsoRecords = try? modelContext.fetch(wsoDescriptor)
        wsoRecords?.forEach { modelContext.delete($0) }

        let schedDescriptor = FetchDescriptor<ScheduleEntity>()
        let schedRecords = try? modelContext.fetch(schedDescriptor)
        schedRecords?.forEach { modelContext.delete($0) }

        let standardsDescriptor = FetchDescriptor<StandardsEntity>()
        let standardsRecords = try? modelContext.fetch(standardsDescriptor)
        standardsRecords?.forEach { modelContext.delete($0) }

        let amRecordsDescriptor = FetchDescriptor<AmericanRecordEntity>()
        let amRecordsRecords = try? modelContext.fetch(amRecordsDescriptor)
        amRecordsRecords?.forEach { modelContext.delete($0) }

        let startListDescriptor = FetchDescriptor<StartListEntity>()
        let startListRecords = try? modelContext.fetch(startListDescriptor)
        startListRecords?.forEach { modelContext.delete($0) }

        let meetDetailsDescriptor = FetchDescriptor<MeetDetailsEntity>()
        let meetDetailsRecords = try? modelContext.fetch(meetDetailsDescriptor)
        meetDetailsRecords?.forEach { modelContext.delete($0) }

        let natRankingsDescriptor = FetchDescriptor<NatRankingsEntity>()
        let natRankingsRecords = try? modelContext.fetch(natRankingsDescriptor)
        natRankingsRecords?.forEach { modelContext.delete($0) }

        let intlRankingsDescriptor = FetchDescriptor<RankingsEntity>()
        let intlRankingsRecords = try? modelContext.fetch(intlRankingsDescriptor)
        intlRankingsRecords?.forEach { modelContext.delete($0) }

        let schedDetailsDescriptor = FetchDescriptor<SchedDetailsEntity>()
        let schedDetailsRecords = try? modelContext.fetch(schedDetailsDescriptor)
        schedDetailsRecords?.forEach { modelContext.delete($0) }

        let adaptiveDescriptor = FetchDescriptor<AdaptiveRecordEntity>()
        let adaptiveRecords = try? modelContext.fetch(adaptiveDescriptor)
        adaptiveRecords?.forEach { modelContext.delete($0) }

        let resultsDescriptor = FetchDescriptor<ResultsEntity>()
        let resultsRecords = try? modelContext.fetch(resultsDescriptor)
        resultsRecords?.forEach { modelContext.delete($0) }

        try? modelContext.save()
        refreshID = UUID()

        alertTitle = "Deleted Successfully"
        alertMessage = "All offline data has been deleted from your device."
        alertShowing = true
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Schedule & Start List") {
                    ForEach(meets, id: \.self) { meet in
                        ListButtonComponent(
                            colorScheme: colorScheme,
                            title: meet.name,
                            isDownloaded: isMeetScheduleDownloaded(meet.name),
                            isDownloading: downloadingItems.contains("Schedule-\(meet.name)"),
                            downloadAction: {
                                Task {
                                    await downloadMeetData(meetName: meet.name)
                                }
                            },
                            deleteAction: {
                                deleteMeetData(meetName: meet.name)
                            },
                            lastSyncedDate: getLastSyncedDate(for: meet.name, meetName: meet.name)
                        )
                    }
                }
                
                Section("Competition Data") {
                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "A/B Standards",
                        isDownloaded: isItemDownloaded("A/B Standards"),
                        isDownloading: downloadingItems.contains("A/B Standards"),
                        downloadAction: {
                            Task {
                                await downloadStandards()
                            }
                        },
                        deleteAction: {
                            deleteStandards()
                        },
                        lastSyncedDate: getLastSyncedDate(for: "A/B Standards")
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "Adaptive American Records",
                        isDownloaded: isItemDownloaded("Adaptive American Records"),
                        isDownloading: downloadingItems.contains("Adaptive American Records"),
                        downloadAction: {
                            Task {
                                await downloadAdapRecords()
                            }
                        },
                        deleteAction: {
                            deleteAdaptiveRecords()
                        },
                        lastSyncedDate: getLastSyncedDate(for: "Adaptive American Records")
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "American Records",
                        isDownloaded: isItemDownloaded("American Records"),
                        isDownloading: downloadingItems.contains("American Records"),
                        downloadAction: {
                            Task {
                                await downloadAmRecords()
                            }
                        },
                        deleteAction: {
                            deleteAmRecords()
                        },
                        lastSyncedDate: getLastSyncedDate(for: "American Records")
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "International Rankings",
                        isDownloaded: isItemDownloaded("International Rankings"),
                        isDownloading: downloadingItems.contains("International Rankings"),
                        downloadAction: {
                            Task {
                                await downloadIntlRankings()
                            }
                        },
                        deleteAction: {
                            deleteIntlRankings()
                        },
                        lastSyncedDate: getLastSyncedDate(for: "International Rankings")
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "National Rankings",
                        isDownloaded: isItemDownloaded("National Rankings"),
                        isDownloading: downloadingItems.contains("National Rankings"),
                        downloadAction: {
                            Task {
                                await downloadNatRankings()
                            }
                        },
                        deleteAction: {
                            deleteNatRankings()
                        },
                        lastSyncedDate: getLastSyncedDate(for: "National Rankings")
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "Qualifying Totals",
                        isDownloaded: isItemDownloaded("Qualifying Totals"),
                        isDownloading: downloadingItems.contains("Qualifying Totals"),
                        downloadAction: {
                            Task {
                                await downloadQT()
                            }
                        },
                        deleteAction: {
                            deleteQT()
                        },
                        lastSyncedDate: getLastSyncedDate(for: "Qualifying Totals")
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "WSO Records",
                        isDownloaded: isItemDownloaded("WSO Records"),
                        isDownloading: downloadingItems.contains("WSO Records"),
                        downloadAction: {
                            Task {
                                await downloadWSO()
                            }
                        },
                        deleteAction: {
                            deleteWSO()
                        },
                        lastSyncedDate: getLastSyncedDate(for: "WSO Records")
                    )
                }
            }
            .navigationTitle("Offline Data")
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertTitle, isPresented: $alertShowing) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .toolbar{
                ToolbarItem {
                    Button {
                        deleteAllOfflineData()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .toolbarVisibility(.hidden, for: .tabBar)
        }
        .task {
            await meetsModel.loadMeets3Weeks()
        }
        .id(refreshID)
    }
}

struct ListButtonComponent: View {
    @Environment(\.modelContext) private var modelContext

    let colorScheme: ColorScheme
    let title: String
    let isDownloaded: Bool
    let isDownloading: Bool
    let downloadAction: () -> Void
    let deleteAction: () -> Void
    let lastSyncedDate: Date?

    var body: some View {
        if isDownloaded {
            Button {
                deleteAction()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .foregroundStyle(colorScheme == .light ? .black : .white)
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    if let lastSynced = lastSyncedDate {
                        Text("Last synced: \(lastSynced, style: .relative) ago")
                            .font(.caption)
                            .secondaryText()
                    }
                }
            }
        } else if isDownloading {
            HStack {
                Text(title)
                    .foregroundStyle(colorScheme == .light ? .black : .white)
                Spacer()
                ProgressView()
            }
        } else {
            Button {
                downloadAction()
            } label: {
                HStack {
                    Text(title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Spacer()
                    Image(systemName: "arrow.down.circle")
                }
            }
        }
    }
}

#Preview {
    OfflineModeView()
}
