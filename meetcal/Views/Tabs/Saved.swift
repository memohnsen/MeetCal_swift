//
//  ScheduleView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI

struct SavedView: View {
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Button {
                        
                        } label: {
                            Image(systemName: "plus")
                            Text("Create Session")
                        }
                        .frame(width: 180, height: 40)
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(5)

                        
                        Button {
                        
                        } label: {
                            Image(systemName: "calendar")
                            Text("Add to Calendar")
                        }
                        .frame(width: 180, height: 40)
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(5)
                    }
                    
                    HStack {
                        Button {
                        
                        } label: {
                            Image(systemName: "bookmark")
                            Text("Saved Warmups")
                        }
                        .frame(width: 370, height: 40)
                        .foregroundStyle(.black)
                        .background(.white)
                        .cornerRadius(5)
                        .padding(.bottom, 20)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .padding(.vertical, 20)
                .background(.gray.opacity(0.2))
                
                Divider()
                
                List {
                    Section {
                        Text("element")
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SavedView()
}
