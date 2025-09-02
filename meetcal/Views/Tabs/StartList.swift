//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct StartListView: View {
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        ButtonComponent(image: "line.3.horizontal.decrease", action: {}, title: "Filter")
                        ButtonComponent(image: "square.and.arrow.down", action: {}, title: "Save")
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, -10)
                
                Divider()
                
                DropdownView(searchText: $searchText)
                    .searchable(text: $searchText, prompt: "Search for an athlete")
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Start List")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DropdownView: View {
    @Binding var searchText: String
    
    let athletes: [String] = ["Alexander Nordstrom", "Amber Hapken", "Ashlie Pankonin"]
    
    var filteredAthletes: [String] {
        if searchText.isEmpty { return athletes }
        return athletes.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            ForEach(filteredAthletes, id: \.self) {
                DisclosureGroup($0) {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Session:")
                            Spacer()
                            Text("Session 24 | Red Platform")
                                .bold()
                        }
                        HStack {
                            Text("Date & Time:")
                            Spacer()
                            Text("Sep 10 | 8:30 PM PDT")
                                .bold()
                        }
                        HStack {
                            Text("Club:")
                            Spacer()
                            Text("POWER & GRACE PERFORMANCE.")
                                .bold()
                        }
                        HStack {
                            Text("Weight Class:")
                            Spacer()
                            Text("88kg")
                                .bold()
                        }
                        HStack {
                            Text("Age:")
                            Spacer()
                            Text("40")
                                .bold()
                        }
                        HStack {
                            Text("Entry Total:")
                            Spacer()
                            Text("230kg")
                                .bold()
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack {
                                Text("Bests From The Last Year")
                                    .padding(.bottom, 10)
                                
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text("Snatch")
                                        Text("120")
                                            .bold()
                                    }
                                    Spacer()
                                    VStack {
                                        Text("CJ")
                                        Text("160")
                                            .bold()
                                    }
                                    Spacer()
                                    VStack {
                                        Text("Total")
                                        Text("280")
                                            .bold()
                                    }
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("See All Meet Results")
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.top, 10)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StartListView()
}
