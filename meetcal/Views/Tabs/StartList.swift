//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct StartListView: View {
    @State private var searchText: String = ""
    
    let athletes: [String] = ["Alex", "Amber", "Ashlie"]
    
    var filteredAthletes: [String] {
        if searchText.isEmpty { return athletes }
        return athletes.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Button {
                        
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                            Text("Filter")
                        }
                        .frame(width: 180, height: 40)
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(5)

                        
                        Button {
                        
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .frame(width: 180, height: 40)
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(5)
                    }
                    .padding(.bottom, 5)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 20)
                .padding(.vertical, 20)
                .background(.gray.opacity(0.2))
                
                Divider()
                
                List(filteredAthletes, id: \.self) { athlete in
                    Text(athlete)
                }
                .searchable(text: $searchText, prompt: "Search for an athlete")
            }
            .navigationTitle("Start List")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    StartListView()
}
