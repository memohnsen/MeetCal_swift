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
    
    var genders: [String]
    var ageGroups: [String]
    var meets: [String]
    var title: String
    
    var body: some View {
        Group {
            if isModalShowing {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isModalShowing = false
                    }
                
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(title)
                                .secondaryText()
                                .padding(.bottom, 0.5)
                            Text(selectedMeet)
                        }
                        Spacer()
                        Image(systemName: isModal1DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(Color.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal1DropdownShowing.toggle()
                    }
                    
                    if isModal1DropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(meets, id: \.self) { meet in
                                HStack {
                                    Button(action: {
                                        selectedMeet = meet
                                        isModal1DropdownShowing = false
                                    }) {
                                        Text(meet)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(meet == selectedMeet ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if meet == selectedMeet {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(meet == selectedMeet ? .gray.opacity(0.2) : .white)

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
                            Text(selectedGender.isEmpty ? "Men" : selectedGender)
                        }
                        Spacer()
                        Image(systemName: isModal2DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(Color.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal2DropdownShowing.toggle()
                    }
                    
                    if isModal2DropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(genders, id: \.self) { gender in
                                HStack {
                                    Button(action: {
                                        selectedGender = gender
                                            isModal2DropdownShowing = false
                                    }) {
                                        Text(gender)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(gender == selectedGender ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if gender == selectedGender {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(gender == selectedGender ? .gray.opacity(0.2) : .white)

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
                            Text(selectedAge)
                        }
                        Spacer()
                        Image(systemName: isModal3DropdownShowing ? "chevron.down" : "chevron.right")
                    }
                    .padding()
                    .background(Color.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isModal3DropdownShowing.toggle()
                    }
                    
                    if isModal3DropdownShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider()
                            
                            ForEach(ageGroups, id: \.self) { age in
                                HStack {
                                    Button(action: {
                                        selectedAge = age
                                        isModal3DropdownShowing = false
                                    }) {
                                        Text(age)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading, 0)
                                            .padding()
                                            .foregroundStyle(age == selectedAge ? Color.blue : Color(red: 102/255, green: 102/255, blue: 102/255))
                                    }


                                    Spacer()
                                    if age == selectedAge {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                                .background(age == selectedAge ? .gray.opacity(0.2) : .white)

                                Divider()
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
                        isModalShowing = false
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

