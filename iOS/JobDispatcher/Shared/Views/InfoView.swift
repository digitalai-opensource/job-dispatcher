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
import MapKit

struct InfoView: View {
    @Binding var view: String
    @State var job: Job
    @State var isLocationError: Bool = false
    @State var isToggleJobError: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                Group {
                    HStack {
                        Button(action: {
                            self.view = "Joblist"
                        }, label: {
                            BackButton()
                        })
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(self.job.address)
                            .foregroundColor(Color(red: 116/255, green: 129/255, blue: 147/255))
                            .font(.title3)
                        Spacer()
                        Button(action: {
                            isToggleJobError = !toggleJob(curJob: self.job)
                            self.view = "Joblist"
                        }) {
                            Text(self.job.isOpen ? "Close" : "Open")
                                .fontWeight(.medium)
                                .modifier(ToggleStatusButtonModifier())
                            DownArrowIcon()
                        }
                    }
                }
                Text(self.job.client)
                    .modifier(ClientNameModifier())
                Text("Complaint")
                    .fontWeight(.semibold)
                    .modifier(InfoHeaderModifier())
                Text(self.job.complaint)
                    .modifier(InfoTextModifier())
                Text("Details")
                    .fontWeight(.semibold)
                    .modifier(InfoHeaderModifier())
                Text(self.job.details)
                    .modifier(InfoTextModifier())
                Text("Notes")
                    .fontWeight(.semibold)
                    .modifier(InfoHeaderModifier())
                Text(self.job.notes)
                    .modifier(InfoTextModifier())
                Button(action: {
                    geocode()
                }) {
                    Image(systemName: "map")
                        .modifier(DirectionsIconModifier())
                    DirectionsButton()
                    Image(systemName: "arrowtriangle.right.fill")
                        .modifier(DirectionsIconModifier())
                }
                Spacer()
            }
            .alert(isPresented: $isLocationError) {
                Alert(title: Text("Job address not found."))
            }
            .alert(isPresented: $isToggleJobError) {
                Alert(title: Text("Error in changing job status."))
            }
        }
    }
    // This function uses geocoding to get the coordinates of the job's address.
    func geocode() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(job.address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else {
                isLocationError = true
                return
            }
            destinationCoordinates = location.coordinate
            self.view = "Map"
        }
    }
}

struct ToggleStatusButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .frame(width: 150, height: 60)
                .foregroundColor(Color(red: 56/255, green: 72/255, blue: 94/255))
                .cornerRadius(4)
                .background(Color.white)
                .border(Color.white, width: 1)
                .clipped()
                .shadow(color: Color(red: 200/255, green: 200/255, blue: 200/255), radius: 2, x: 0, y: 1)
                .padding(.trailing, -32)
    }
}

struct ClientNameModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundColor(Color(red: 56/255, green: 72/255, blue: 94/255))
            .padding(.top, 35)
            .padding(.bottom, 35)
    }
}

struct InfoTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundColor(Color(red: 56/255, green: 72/255, blue: 94/255))
            .padding(.top, 15)
            .padding(.bottom, 15)
            .frame(width: 300, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct InfoHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .padding(.leading, 20)
            .frame(width: 340, height: 70, alignment: .leading)
            .foregroundColor(Color(red: 56/255, green: 72/255, blue: 94/255))
            .background(Color(red: 223/255, green: 224/255, blue: 226/255))
    }
}

struct BackButton: View {
    var body: some View {
        return Text("Back")
            .font(.title2)
            .padding(.leading, 10)
    }
}

struct DownArrowIcon: View {
    var body: some View {
        return Image(systemName: "arrowtriangle.down.fill")
            .foregroundColor(Color(red: 56/255, green: 72/255, blue: 94/255))
            .padding(.trailing, 30)
            .padding(.top, 2)
    }
}

struct DirectionsButton: View {
    var body: some View {
        return Text("Directions")
            .font(.title)
            .foregroundColor(Color(red: 56/255, green: 72/255, blue: 94/255))
            .frame(width: 230, height: 70)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(red: 192/255, green: 198/255, blue: 206/255), lineWidth: 1.5))
            .padding(.top, 20)
            .padding(.leading, -53)
            .padding(.trailing, -50)
    }
}

struct DirectionsIconModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(red: 56/255, green: 72/255, blue: 94/255))
            .font(.system(size: 27))
            .padding(.top, 20)
    }
}
