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

struct LoginView: View {
    @Binding var view: String
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoginFailure: Bool = false
    var body: some View {
            VStack {
                Logo()
                Security().scaledToFill()
                Icon()
                TextField("", text: $username).modifier(TextBoxModifier())
                Text("Username").modifier(TextModifier())
                SecureField("", text: $password).modifier(TextBoxModifier())
                Text("Password").modifier(TextModifier())
                Button(action: {login()}) {
                    LoginButton()
                }
            }
            .alert(isPresented: $isLoginFailure) {
                Alert(title: Text("Invalid Username or Password"))
            }
    }
    func login() {
        if authenticate(username, password) {
            self.view = "Joblist"
        }
        else {
            isLoginFailure = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(view: .constant("Login"))
        }
    }
}

struct Logo: View {
    var body: some View {
        return Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 300)
            .padding(.bottom, -25)
    }
}

struct Security: View {
    var body: some View {
        return Text("Security")
            .font(.title)
            .fontWeight(.heavy)
    }
}

struct Icon: View {
    var body: some View {
        return Image("icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 90)
            .padding(.top, 3)
            .padding(.bottom, 15)
    }
}

struct TextBoxModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .autocapitalization(.none)
            .frame(width: 230, height: 70)
            .textFieldStyle(PlainTextFieldStyle())
            .cornerRadius(3)
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.gray))
            .padding(.bottom, -8)
            .font(.title2)
    }
}

struct TextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 210, alignment: .leading)
            .font(.body)
            .foregroundColor(Color.gray)
            .padding(.bottom, 5)
    }
}

struct LoginButton: View {
    var body: some View {
        return Text("Login")
            .frame(width: 170, height: 55)
            .font(.title2)
            .foregroundColor(.white)
            .background(Color(red: 23/255, green: 102/255, blue: 196/255))
            .cornerRadius(3)
            .padding(.top, 15)
    }
}
