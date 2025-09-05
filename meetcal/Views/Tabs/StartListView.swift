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
                                .foregroundStyle(Color(red: 102/255, green: 102/255, blue: 102/255))

                            Spacer()
                            NavigationLink(destination: ScheduleDetailsView()) {
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Text("Session 24 • Red Platform")
                                    .foregroundStyle(.blue)
                            }
                        }
                        HStack {
                            Text("Date & Time:")
                                .secondaryText()
                            
                            Spacer()
                            Text("Sep 10 • 8:30 PM PDT")
                        }
                        HStack {
                            Text("Club:")
                                .secondaryText()
                            
                            Spacer()
                            Text("POWER & GRACE PERFORMANCE.")
                        }
                        HStack {
                            Text("Weight Class:")
                                .secondaryText()
                            
                            Spacer()
                            Text("88kg")
                        }
                        HStack {
                            Text("Age:")
                                .secondaryText()
                            
                            Spacer()
                            Text("40")
                        }
                        HStack {
                            Text("Entry Total:")
                                .secondaryText()
                            
                            Spacer()
                            Text("230kg")
                        }
                                                
                        HStack {
                            VStack {
                                Divider()
                                    .padding(.vertical, 6)
                                
                                Text("Best Lifts From The Last Year")
                                    .padding(.bottom, 10)
                                
                                HStack {
                                    VStack {
                                        Text("Snatch")
                                            .secondaryText()
                                        Text("120")
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text("CJ")
                                            .secondaryText()
                                        Text("160")
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        Text("Total")
                                            .secondaryText()
                                        Text("280")
                                            .bold()
                                    }
                                }
                                .frame(width: 220)
                                
                                HStack {
                                    Text("See All Meet Results")
                                    Image(systemName: "chevron.right")
                                }
                                .padding(.top, 10)
                                .foregroundStyle(.blue)
                            }
                        }
                    }
                    .padding(.leading, -20)
                }
            }
        }
    }
}

#Preview {
    StartListView()
}
