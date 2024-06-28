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

var destinationCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

struct ContentView: View {
    @State var currentView = "Login"
    @State var currentJob: Job
    var body: some View {
        if currentView == "Login" {
            LoginView(view: $currentView)
        }
        else if currentView == "Joblist" {
            JoblistView(view: $currentView, job: $currentJob)
        }
        else if currentView == "Info" {
            InfoView(view: $currentView, job: currentJob)
        }
        else if currentView == "Map" {
            MapView(view: $currentView, job: currentJob)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(currentJob: emptyJob)
    }
}
