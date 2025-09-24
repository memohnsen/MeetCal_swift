//
//  MeetResults.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/4/25.
//

import SwiftUI

struct MeetResultsView: View {
    @StateObject private var viewModel = ScheduleDetailsModel()

    let name: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    MakeRate(viewModel: viewModel, name: name)
                        .padding(.bottom, 12)
                        .padding(.horizontal)

                    
                    MeetInfo(viewModel: viewModel)
                        .padding(.horizontal)
                }
                .navigationTitle(name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .tabBar)
            }
        }
        .task {
            await viewModel.loadResults(name: name)
        }
    }
}

struct MakeRate: View {
    @ObservedObject var viewModel: ScheduleDetailsModel
    
    var results: [AthleteResults] { viewModel.athleteResults }
    let name: String
    
    func makeRate() -> (snatch1Rate: Double, snatch2Rate: Double, snatch3Rate: Double, cj1Rate: Double, cj2Rate: Double, cj3Rate: Double, countSnatch1: Int, countSnatch2: Int, countSnatch3: Int, countCJ1: Int, countCJ2: Int, countCJ3: Int, snatch1Makes: Int, snatch2Makes: Int, snatch3Makes: Int, cj1Makes: Int, cj2Makes: Int, cj3Makes: Int, snatchAverage: Double, cjAverage: Double) {
        let athleteResults = results.filter { $0.name == name }
        
        let countSnatch1 = athleteResults.count
        let countSnatch2 = athleteResults.count
        let countSnatch3 = athleteResults.count
        let countCJ1 = athleteResults.count
        let countCJ2 = athleteResults.count
        let countCJ3 = athleteResults.count
        
        let snatch1Makes = athleteResults.filter { $0.snatch1 > 0 }.count
        let snatch2Makes = athleteResults.filter { $0.snatch2 > 0 }.count
        let snatch3Makes = athleteResults.filter { $0.snatch3 > 0 }.count
        let cj1Makes = athleteResults.filter { $0.cj1 > 0 }.count
        let cj2Makes = athleteResults.filter { $0.cj2 > 0 }.count
        let cj3Makes = athleteResults.filter { $0.cj3 > 0 }.count
        
        let snatch1Rate = countSnatch1 > 0 ? (Double(snatch1Makes) / Double(countSnatch1)) * 100 : 0.0
        let snatch2Rate = countSnatch2 > 0 ? (Double(snatch2Makes) / Double(countSnatch2)) * 100 : 0.0
        let snatch3Rate = countSnatch3 > 0 ? (Double(snatch3Makes) / Double(countSnatch3)) * 100 : 0.0
        let cj1Rate = countCJ1 > 0 ? (Double(cj1Makes) / Double(countCJ1)) * 100 : 0.0
        let cj2Rate = countCJ2 > 0 ? (Double(cj2Makes) / Double(countCJ2)) * 100 : 0.0
        let cj3Rate = countCJ3 > 0 ? (Double(cj3Makes) / Double(countCJ3)) * 100 : 0.0
        
        let snatchAverage = (snatch1Rate + snatch2Rate + snatch3Rate) / 3
        let cjAverage = (cj1Rate + cj2Rate + cj3Rate) / 3

        return (snatch1Rate, snatch2Rate, snatch3Rate, cj1Rate, cj2Rate, cj3Rate, countSnatch1, countSnatch2, countSnatch3, countCJ1, countCJ2, countCJ3, snatch1Makes, snatch2Makes, snatch3Makes, cj1Makes, cj2Makes, cj3Makes, snatchAverage, cjAverage)
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Success Rates")
                .bold()
                .font(.title3)
            
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                VStack {
                    HStack {
                        Text("Snatch")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().snatchAverage)))%")
                            .bold()
                            .foregroundStyle(
                                makeRate().snatchAverage < 70.0 ? .red
                                : makeRate().snatchAverage > 70.00 && makeRate().snatchAverage < 70.0 ? .yellow
                                : .green)
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        Text("1")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().snatch1Rate)))%")
                            .foregroundStyle(
                                makeRate().snatch1Rate < 70.0 ? .red
                                : makeRate().snatch1Rate > 70.00 && makeRate().snatch1Rate < 70.0 ? .yellow
                                : .green)
                        Spacer()
                        Text("\(String(makeRate().snatch1Makes))/\(String(makeRate().countSnatch1))")
                            .secondaryText()
                    }
                    
                    HStack {
                        Text("2")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().snatch2Rate)))%")
                            .foregroundStyle(
                                makeRate().snatch2Rate < 70.0 ? .red
                                : makeRate().snatch2Rate > 70.00 && makeRate().snatch2Rate < 70.0 ? .yellow
                                : .green)
                        Spacer()
                        Text("\(String(makeRate().snatch2Makes))/\(String(makeRate().countSnatch2))")
                            .secondaryText()
                    }
                    .padding(.vertical, 6)
                    
                    HStack {
                        Text("3")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().snatch3Rate)))%")
                            .foregroundStyle(
                                makeRate().snatch3Rate < 70.0 ? .red
                                : makeRate().snatch3Rate > 70.00 && makeRate().snatch3Rate < 70.0 ? .yellow
                                : .green)
                        Spacer()
                        Text("\(String(makeRate().snatch3Makes))/\(String(makeRate().countSnatch3))")
                            .secondaryText()
                    }
                }
                
                Rectangle()
                    .frame(width: 0.35)
                    .frame(height: 120)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                
                VStack {
                    HStack {
                        Text("C&J")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().cjAverage)))%")
                            .bold()
                            .foregroundStyle(makeRate().cjAverage < 70.0 ? .red : makeRate().cjAverage > 70.0 && makeRate().cjAverage < 80.0 ? .yellow : .green)
                    }
                    .padding(.bottom, 8)

                    HStack {
                        Text("1")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().cj1Rate)))%")
                            .foregroundStyle(
                                makeRate().cj1Rate < 70.0 ? .red
                                : makeRate().cj1Rate > 70.00 && makeRate().cj1Rate < 70.0 ? .yellow
                                : .green)
                        Spacer()
                        Text("\(String(makeRate().cj1Makes))/\(String(makeRate().countCJ1))")
                            .secondaryText()
                    }
                    
                    HStack {
                        Text("2")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().cj2Rate)))%")
                            .foregroundStyle(
                                makeRate().cj2Rate < 70.0 ? .red
                                : makeRate().cj2Rate > 70.00 && makeRate().cj2Rate < 70.0 ? .yellow
                                : .green)
                        Spacer()
                        Text("\(String(makeRate().cj2Makes))/\(String(makeRate().countCJ2))")
                            .secondaryText()
                    }
                    .padding(.vertical, 6)

                    HStack {
                        Text("3")
                            .secondaryText()
                        Spacer()
                        Text("\(String(Int(makeRate().cj3Rate)))%")
                            .foregroundStyle(
                                makeRate().cj3Rate < 70.0 ? .red
                                : makeRate().cj3Rate > 70.00 && makeRate().cj3Rate < 70.0 ? .yellow
                                : .green)
                        Spacer()
                        Text("\(String(makeRate().cj3Makes))/\(String(makeRate().countCJ3))")
                            .secondaryText()
                    }
                }
            }
            
            HStack {
                
            }
        }
        .cardStyling()
        .cornerRadius(32)
    }
}

struct MeetInfo: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: ScheduleDetailsModel
    
    var results: [AthleteResults] { viewModel.athleteResults }

    var body: some View {
        VStack {
            ForEach(results, id: \.self) {result in
                VStack(alignment: .leading) {
                    Text(result.meet)
                        .bold()
                        .font(.headline)
                    
                    Text(result.date, style: .date)
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                        .font(.system(size: 16))
                        .padding(.vertical, 0.5)
                    
                    Text("\(String(result.body_weight))kg")
                        .foregroundStyle(colorScheme == .light ? Color(red: 102/255, green: 102/255, blue: 102/255) : .white)
                        .font(.system(size: 16))
                    
                    Divider()
                        .padding(.vertical, 12)
                    
                    HStack(alignment: .center) {
                        Text("Snatch")
                            .secondaryText()
                            .frame(width: 160, alignment: .leading)
                        HStack {
                            Text(String(Int(result.snatch1)))
                                .foregroundStyle(result.snatch1 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(Int(result.snatch2)))
                                .foregroundStyle(result.snatch2 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(Int(result.snatch3)))
                                .foregroundStyle(result.snatch3 > 0 ? .green : .red)
                                .bold()
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 12)
                    
                    HStack(alignment: .center) {
                        Text("Clean & Jerk")
                            .secondaryText()
                            .frame(width: 160, alignment: .leading)
                        HStack {
                            Text(String(Int(result.cj1)))
                                .foregroundStyle(result.cj1 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(Int(result.cj2)))
                                .foregroundStyle(result.cj2 > 0 ? .green : .red)
                                .bold()
                            Spacer()
                            Text(String(Int(result.cj3)))
                                .foregroundStyle(result.cj3 > 0 ? .green : .red)
                                .bold()
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 12)
                    
                    Text("\(String(Int(result.snatch_best)))/\(String(Int(result.cj_best)))/\(String(Int(result.total)))")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .cardStyling()
                .cornerRadius(32)
                .padding(.bottom, 8)
            }
        }
      
    }
}

#Preview {
    MeetResultsView(name: "Maddisen Mohnsen")
}
