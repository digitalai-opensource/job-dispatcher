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

import Foundation
import CryptoKit

let ENCODED_STRING_FORMAT = "%02hhx"
let KEY_LENGTH = 32

struct Job: Identifiable, Codable {
    let id: Int
    var isOpen: Bool
    let address: String
    let client: String
    let complaint: String
    let details: String
    let notes: String
}

let emptyJob: Job = Job(id: -1, isOpen: false, address: "", client: "", complaint: "", details: "", notes: "")

private let Password = "Secret Password"
private let key = generateKey(password: Password)

var JobsList: [Job] = [
    Job(id: 1, isOpen: true, address: "323 Columbia Street Lafayette IN", client: "Jane Doe", complaint: "My router stopped working.", details: "Everything was working fine until I had a firmware update which made my router stop functioning.", notes: "My apartment is at the end of the hall on the third floor."),
    Job(id: 2, isOpen: true, address: "285 Summer Street Boston MA", client: "Alex Mo", complaint: "I cannot figure out how to set up my new printer.", details: "My old printer broke down so I purchased a new one but I cannot figure out how to get it to work properly.", notes: "I don't have any parking space in front of my house, you will have to park at the roundabout down the street."),
    Job(id: 3, isOpen: true, address: "77 Massachusetts Ave Cambridge MA", client: "Harry Joe", complaint: "I need help activating Windows on my PC.", details: "I recently got a new laptop but am having difficulty activating Windows on it.", notes: "I need this done before my new job starts on Monday."),
    Job(id: 4, isOpen: true, address: "5717 Legacy Drive Plano TX", client: "Smith Ko", complaint: "I can't connect to my router anymore.", details: "My son tried resetting the router but accidentally broke something while doing so.", notes: "We may not be home when you arrive so we will leave the key to the house under the doormat."),
    Job(id: 5, isOpen: true, address: "555 Fayetteville Street Raleigh NC", client: "John Ro", complaint: "My PC randomly shuts down.", details: "I recently replaced the graphics card of my gaming PC which somehow caused it to shut down at random times.", notes: "Please arrive between 1 pm and 5 pm because I usually do not have any meetings at those times."),
    Job(id: 6, isOpen: true, address: "650 California Street San Francisco CA", client: "James Jo", complaint: "My internet is extremely slow.", details: "My internet provider guaranteed fast internet speeds but it is very slow.", notes: "Please wear a mask."),
    Job(id: 7, isOpen: true, address: "1054 South De Anza Boulevard San Jose CA", client: "Jack Vo", complaint: "My laptop frequently overheats.", details: "My laptop gets extremely hot when I use it to the point where I can't even touch it without burning my hand.", notes: "Please bring heat proof gloves if you have them."),
    Job(id: 8, isOpen: true, address: "52 Third Avenue Burlington MA", client: "Kate Zo", complaint: "I can't access anything on my hard drive.", details: "I have an old hard drive that I would like to access but my computer does not even recognize that it is connected.", notes: "Please knock when you arrive, the doorbell doesn't work."),
    Job(id: 9, isOpen: false, address: "2800 E Observatory Rd Los Angeles CA", client: "Hannah Sto", complaint: "My company's servers lost all their data.", details: "Production went down at our company and all the data we gathered over the past year seems to have been lost.", notes: "We have the necessary tools for maintenance prepared for you."),
    Job(id: 10, isOpen: false, address: "225 Park Ave S New York NY", client: "Kevin Roy", complaint: "I can no longer log into my network.", details: "One day I suddenly wasn't able to log into my network, I need help changing the password back to what it was.", notes: "Let me know when you arrive, my apartment requires a keycard to get into the building."),
    Job(id: 11, isOpen: false, address: "400 Broad St Seattle WA", client: "Ben Hee", complaint: "I have a virus on my computer.", details: "I somehow got a virus on my computer and I need help getting rid of it as soon as possible.", notes: "I paid for the immediate help option to get this issue fixed immediately."),
]

var currentJobsList: [Int: Job] = [:]

func initJobs() -> Bool {
    var showError = !addJobs()
    showError = !getJobsFromStorage() || showError
    return showError
}

// This function gets the jobs from storage.
func getJobsFromStorage() -> Bool {
    if !currentJobsList.isEmpty {
        return true
    }
    do {
        for job in JobsList {
            guard let data = UserDefaults.standard.string(forKey: String(job.id)) else {
                return false
            }
            let curJob = try encryptedStringToData(encryptedString: data)
            currentJobsList[curJob.id] = curJob
        }
    }
    catch {
        return false
    }
    return true
}

// This function separates the jobs into an open and closed array for use in the JoblistView page.
func getJobs() -> ([Job], [Job]) {
    var openJobs: [Job] = []
    var closedJobs: [Job] = []
    for JobID in currentJobsList.keys {
        if currentJobsList[JobID]!.isOpen {
            openJobs.append(currentJobsList[JobID]!)
        }
        else {
            closedJobs.append(currentJobsList[JobID]!)
        }
    }
    return (openJobs, closedJobs)
}

// This function toggles the isOpen property of a job.
func toggleJob(curJob: Job) -> Bool {
    // currentJobsList at this id is guaranteed to exist because that job must have existed to get to the Info page where this function is called.
    currentJobsList[curJob.id]!.isOpen = !currentJobsList[curJob.id]!.isOpen
    do {
        let newData = try dataToEncryptedString(object: currentJobsList[curJob.id]!)
        UserDefaults.standard.set(newData, forKey: String(curJob.id))
    }
    catch {
        return false
    }
    return true
}

// This function adds the jobs to UserDefaults if they have not already been properly added.
func addJobs() -> Bool {
    let areJobsInDatabase = UserDefaults.standard.bool(forKey: "areJobsAdded")
    if areJobsInDatabase {
        return true
    }
    do {
        for job in JobsList {
            let data = try dataToEncryptedString(object: job)
            UserDefaults.standard.set(data, forKey: String(job.id))
        }
    }
    catch {
        return false
    }
    UserDefaults.standard.set(true, forKey: "areJobsAdded")
    return true
}

func dataToEncryptedString(object: Job) throws -> String {
    // Converts object to JSON.
    let data = try JSONEncoder().encode(object)
    
    // Encrypts object using AES encryption.
    let encryptedData = try AES.GCM.seal(data, using: key)
    return encryptedData.combined!.base64EncodedString()
}

func encryptedStringToData(encryptedString: String) throws -> Job {
    // Converts string to data object.
    let data = Data(base64Encoded: encryptedString)!
    
    // Puts data in sealed box so that the data can be extracted using the key.
    let box = try AES.GCM.SealedBox(combined: data)
    let decryptedData = try AES.GCM.open(box, using: key)
    
    // Decodes from JSON to a Job object.
    let job = try JSONDecoder().decode(Job.self, from: decryptedData)
    return job
}

func generateKey(password: String) -> SymmetricKey {
    let hash = SHA256.hash(data: password.data(using: String.Encoding.utf8)!)
    
    // Converts the SHA256 hash into a 64 byte string.
    let hashString64Bytes = hash.map{String(format: ENCODED_STRING_FORMAT, $0)}.joined()
    
    // Converts the 64 byte string into a 32 byte string.
    let hashString32Bytes = String(hashString64Bytes.prefix(KEY_LENGTH))
    
    // Converts the string to data so that it can be returned as a SymmetricKey.
    let keyData = hashString32Bytes.data(using: String.Encoding.utf8)
    return SymmetricKey(data: keyData!)
}
