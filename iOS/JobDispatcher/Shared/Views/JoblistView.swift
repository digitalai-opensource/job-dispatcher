//  Copyright 2022 Digital.ai Software, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

struct JoblistView: View {
    @Binding var view: String
    @Binding var job: Job
    @State private var openJobs: [Job] = []
    @State private var closedJobs: [Job] = []
    @State private var showOpen: Bool = false
    @State private var showClosed: Bool = false
    @State private var isInitJobsError: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    PageHeader()
                    Spacer()
                    Menu {
                        Button(action: {self.view = "Login"}, label: {
                            Label(
                                title: {Text("Logout").font(.title)},
                                icon: {Image(systemName: "arrowshape.turn.up.backward.fill")}
                            )
                        })
                    } label: {
                        ProfilePicture()
                    }
                }
                DisclosureGroup("OPEN", isExpanded: $showOpen) {
                    ForEach(openJobs) { job in
                        Button(action: {
                            NavigateToInfoView(curJob: job)
                        }, label: {
                            Text(job.address)
                                .fontWeight(.medium)
                                .modifier(JoblistTextModifier())
                        })
                    }
                }
                .modifier(DisclosureGroupModifier())
                DisclosureGroup("CLOSED", isExpanded: $showClosed) {
                    ForEach(closedJobs) { job in
                        Button(action: {
                            NavigateToInfoView(curJob: job)
                        }, label: {
                            Text(job.address)
                                .fontWeight(.medium)
                                .modifier(JoblistTextModifier())
                        })
                    }
                }
                .modifier(DisclosureGroupModifier())
                Spacer()
            }
            .alert(isPresented: $isInitJobsError) {
                Alert(title: Text("Error in obtaining jobs, some jobs may not have loaded."))
            }
            .onAppear(perform: {
                isInitJobsError = initJobs()
                (openJobs, closedJobs) = getJobs()
            })
        }
    }
    func NavigateToInfoView(curJob: Job) {
        self.job = curJob
        self.view = "Info"
    }
}

struct JoblistView_Previews: PreviewProvider {
    @State static var job = emptyJob
    static var previews: some View {
        JoblistView(view: .constant("Joblist"), job: $job)
    }
}

struct PageHeader: View {
    var body: some View {
        return Text("Today's Work")
            .font(.title2)
    }
}

struct ProfilePicture: View {
    var body: some View {
        return Image("pfp")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 140)
            .clipShape(Circle())
            .padding(.trailing, -10)
            .padding(.leading, -15)
    }
}

struct DisclosureGroupModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .accentColor(Color(red: 102/255, green: 115/255, blue: 133/255))
            .frame(width: 350)
                .padding(10)
                .background(Color.white)
                .clipped()
                .shadow(color: Color(red: 210/255, green: 210/255, blue: 210/255), radius: 1, x: 1, y: 1)
                .border(Color.white, width: 1)
    }
}

struct JoblistTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .frame(width: 320, alignment: .leading)
            .padding(.bottom, 5)
            .padding(.top, 15)
            .foregroundColor(Color(red: 102/255, green: 115/255, blue: 133/255))
    }
}
