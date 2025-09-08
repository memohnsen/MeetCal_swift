//
//  QualifyingRankingsRecordsFilter.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/6/25.
//

import SwiftUI

struct QualifyingRankingsRecordsFilter: View {
    @Binding var isModalShowing: Bool
    @Binding var isModal1DropdownShowing: Bool
    @Binding var isModal2DropdownShowing: Bool
    @Binding var isModal3DropdownShowing: Bool
    
    @Binding var selectedGender: String
    @Binding var selectedAge: String
    @Binding var selectedMeet: String
    
    @Binding var draftGender: String
    @Binding var draftAge: String
    @Binding var draftMeet: String
    
    let genders: [String] = ["Men", "Women"]
    var ageGroups: [String]
    var meets: [String]
    var title: String
    var onApply: () -> Void
    
    var body: some View {
        Group {
            if isModalShowing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isModalShowing = false
                        isModal1DropdownShowing = false
                        isModal2DropdownShowing = false
                        isModal3DropdownShowing = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(title)
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftMeet.isEmpty ? selectedMeet : draftMeet)
                        }
                        Spacer()
                        Image(systemName: isModal1DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(Color.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal1DropdownShowing.toggle()
                        isModal2DropdownShowing = false
                        isModal3DropdownShowing = false
                    }
                    
                    if isModal1DropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(meets, id: \.self) { meet in
                                HStack {
                                    Button(action: {
                                        draftMeet = meet
                                        isModal1DropdownShowing = false
                                    }) {
                                        Text(meet)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(meet == draftMeet ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if meet == draftMeet {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(meet == draftMeet ? .gray.opacity(0.2) : .white)

                                Divider()
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gender")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftGender.isEmpty ? selectedGender : draftGender)
                        }
                        Spacer()
                        Image(systemName: isModal2DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(Color.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal2DropdownShowing.toggle()
                        isModal1DropdownShowing = false
                        isModal3DropdownShowing = false
                    }
                    
                    if isModal2DropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(genders, id: \.self) { gender in
                                HStack {
                                    Button(action: {
                                        draftGender = gender
                                            isModal2DropdownShowing = false
                                    }) {
                                        Text(gender)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(gender == draftGender ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if gender == draftGender {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(gender == draftGender ? .gray.opacity(0.2) : .white)

                                Divider()
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Age Group")
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(draftAge.isEmpty ? selectedAge : draftAge)
                        }
                        Spacer()
                        Image(systemName: isModal3DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(Color.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal3DropdownShowing.toggle()
                        isModal1DropdownShowing = false
                        isModal2DropdownShowing = false
                    }
                    
                    if isModal3DropdownShowing {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                
                                ForEach(ageGroups, id: \.self) { age in
                                    HStack {
                                        Button(action: {
                                            draftAge = age
                                            isModal3DropdownShowing = false
                                        }) {
                                            Text(age)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.leading, 0)
                                                .padding()
                                                .foregroundStyle(age == draftAge ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                        }
                                        
                                        
                                        Spacer()
                                        if age == draftAge {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                        Spacer()
                                    }
                                    .background(age == draftAge ? .gray.opacity(0.2) : .white)
                                    
                                    Divider()
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Apply")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .cornerRadius(12)
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onApply()
                    }
                }
                .frame(maxWidth: 350)
                .background(.white)
                .cornerRadius(16)
                .shadow(radius: 20)
                .padding(.horizontal, 30)
            }
        }
    }
}

