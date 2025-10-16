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

    @State private var downloadingItems: Set<String> = []
    @State private var refreshID = UUID()

    @StateObject private var meetsModel = MeetsScheduleModel()
    var meets: [MeetsRow] { meetsModel.threeWeeksMeets }

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
        var descriptor = FetchDescriptor<ScheduleEntity>(
            predicate: #Predicate { $0.meet == meetName }
        )
        descriptor.fetchLimit = 1
        let results = try? modelContext.fetch(descriptor)
        return !(results?.isEmpty ?? true)
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
        var descriptor = FetchDescriptor<AdaptiveRecordModel>()
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
    
    // MARK: - Download Functions

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
    
    var body: some View {
        NavigationStack {
            List {
                Section("Schedules") {
                    ForEach(meets, id: \.self) { meet in
                        ListButtonComponent(
                            colorScheme: colorScheme,
                            title: meet.name,
                            isDownloaded: isMeetScheduleDownloaded(meet.name),
                            isDownloading: downloadingItems.contains("Schedule-\(meet.name)"),
                            downloadAction: {
                                // TODO: Implement schedule download
                            },
                            deleteAction: {
                                // TODO: Implement schedule delete
                            }
                        )
                    }
                }

                Section("Start Lists") {
                    ForEach(meets, id: \.self) { meet in
                        ListButtonComponent(
                            colorScheme: colorScheme,
                            title: meet.name,
                            isDownloaded: isMeetStartListDownloaded(meet.name),
                            isDownloading: downloadingItems.contains("StartList-\(meet.name)"),
                            downloadAction: {
                                // TODO: Implement start list download
                            },
                            deleteAction: {
                                // TODO: Implement start list delete
                            }
                        )
                    }
                }
                
                Section("Competition Data") {
                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "A/B Standards",
                        isDownloaded: isItemDownloaded("A/B Standards"),
                        isDownloading: downloadingItems.contains("A/B Standards"),
                        downloadAction: {},
                        deleteAction: {}
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
                        deleteAction: {}
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "American Records",
                        isDownloaded: isItemDownloaded("American Records"),
                        isDownloading: downloadingItems.contains("American Records"),
                        downloadAction: {},
                        deleteAction: {}
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "International Rankings",
                        isDownloaded: isItemDownloaded("International Rankings"),
                        isDownloading: downloadingItems.contains("International Rankings"),
                        downloadAction: {},
                        deleteAction: {}
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "National Rankings",
                        isDownloaded: isItemDownloaded("National Rankings"),
                        isDownloading: downloadingItems.contains("National Rankings"),
                        downloadAction: {},
                        deleteAction: {}
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "Qualifying Totals",
                        isDownloaded: isItemDownloaded("Qualifying Totals"),
                        isDownloading: downloadingItems.contains("Qualifying Totals"),
                        downloadAction: {},
                        deleteAction: {}
                    )

                    ListButtonComponent(
                        colorScheme: colorScheme,
                        title: "WSO Records",
                        isDownloaded: isItemDownloaded("WSO Records"),
                        isDownloading: downloadingItems.contains("WSO Records"),
                        downloadAction: {},
                        deleteAction: {}
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
                    Button{
                        
                    } label: {
                        Image(systemName: "arrow.trianglehead.counterclockwise.icloud")
                    }
                }
                ToolbarSpacer()
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .task {
            await meetsModel.loadMeets3Weeks()
        }
        .id(refreshID)
    }
}

struct ListButtonComponent: View {
    let colorScheme: ColorScheme
    let title: String
    let isDownloaded: Bool
    let isDownloading: Bool
    let downloadAction: () -> Void
    let deleteAction: () -> Void
    
    var body: some View {
        if isDownloaded {
            Button {
                deleteAction()
            } label: {
                HStack {
                    Text(title)
                        .foregroundStyle(colorScheme == .light ? .black : .white)
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.green)
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
