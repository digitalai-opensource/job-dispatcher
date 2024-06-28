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

let temperatureErrorNum = -1000;

struct MapView: View {
    @Binding var view: String
    @State var job: Job
    @State var isWeatherError: Bool = false
    @State var destinationWeather: String = ""
    @State var destinationTemperature: Int = -1000
    @State var directionsArray: [String] = []
    @State var showDirections = false
    var body: some View {
        HStack {
            Button(action: {
                self.view = "Info"
            }, label: {
                BackButton()
            })
            Spacer()
            if destinationWeather == "" {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            }
            getWeatherIcon()
                .font(.title2)
            if (destinationTemperature != temperatureErrorNum) {
                Text(String(destinationTemperature) + "°F")
                    .padding(.trailing, 10)
            }
        }
        .onAppear(perform: {getWeather()})
        .alert(isPresented: $isWeatherError) {
            Alert(title: Text("Weather not found."))
        }
        Map(directions: $directionsArray)
            .ignoresSafeArea(.all)
        Button(action: {
                self.showDirections.toggle()
              }, label: {
                Text("Show directions")
              })
              .disabled(directionsArray.isEmpty)
              .padding(.top)
        .sheet(isPresented: $showDirections, content: {
              VStack(spacing: 0) {
                Text("Directions")
                  .font(.largeTitle)
                  .bold()
                  .padding()
                
                Divider().background(Color.blue)
                
                List(0..<self.directionsArray.count, id: \.self) { i in
                  Text(self.directionsArray[i]).padding()
                }
              }
            })
    }
    func getWeatherIcon() -> some View {
        let lowercasedWeather = destinationWeather.lowercased()
        if (lowercasedWeather.contains("thunder")) {
            return AnyView(Image(systemName: "cloud.bolt"))
        }
        else if (lowercasedWeather.contains("snow")) {
            return AnyView(Image(systemName: "cloud.snow"))
        }
        else if (lowercasedWeather.contains("fog") || lowercasedWeather.contains("haze")) {
            return AnyView(Image(systemName: "cloud.fog"))
        }
        else if (lowercasedWeather.contains("rain")) {
            return AnyView(Image(systemName: "cloud.rain"))
        }
        else if (lowercasedWeather.contains("cloud")) {
            return AnyView(Image(systemName: "cloud"))
        }
        else if (lowercasedWeather.contains("sun") || lowercasedWeather.contains("clear")) {
            return AnyView(Image(systemName: "sun.max"))
        }
        else {
            return AnyView(Text(destinationWeather))
        }
    }
    
    // The API being used requires two API calls, the first gets a URL and the second uses that URL to get the weather data.
    // This function performs the first API call to get the URL and calls the function that performs the second API call.
    func getWeather() {
        // Rounds latitude and longitude to 4 decimal places
        let latitude = round(destinationCoordinates.latitude * 10000) / 10000.0
        let longitude = round(destinationCoordinates.longitude * 10000) / 10000.0
        guard let url = URL(string: "https://api.weather.gov/points/\(latitude),\(longitude)") else {
            isWeatherError = true
            return
        }
        var request = URLRequest(url: url)
        request.setValue("JobDispatcher/Digital.ai", forHTTPHeaderField: "User-Agent")
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                isWeatherError = true
                return
            }
            DispatchQueue.main.async {
                do {
                    guard let JSONWeatherResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                          let weatherProps = JSONWeatherResponse["properties"] as? [String:Any],
                          let forecastURL = weatherProps["forecast"] as? String else {
                        destinationWeather = "Unable to fetch weather"
                        return
                    }
                    // Calls this function to perform the second API call.
                    getWeatherData(weatherURL: forecastURL)
                }
                catch {
                    isWeatherError = true
                    return
                }
            }
        }
        dataTask.resume()
    }
    // This function performs the second API call using the URL from the first API call to get the weather data.
    func getWeatherData(weatherURL: String) {
        guard let url = URL(string: weatherURL) else {
            isWeatherError = true
            return
        }
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                isWeatherError = true
                return
            }
            DispatchQueue.main.async {
                do {
                    guard let JSONWeatherResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                          let weatherProps = JSONWeatherResponse["properties"] as? [String:Any],
                          let weatherPeriods = weatherProps["periods"] as? [[String:Any]],
                          let currentWeather = weatherPeriods[0]["shortForecast"] as? String,
                          let currentTemperature = weatherPeriods[0]["temperature"] as? Int else {
                        destinationWeather = "Unable to fetch weather"
                        return
                    }
                    destinationWeather = currentWeather
                    destinationTemperature = currentTemperature
                }
                catch {
                    isWeatherError = true
                    return
                }
            }
        }
        dataTask.resume()
    }

}
