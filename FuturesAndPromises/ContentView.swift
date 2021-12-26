//
//  ContentView.swift
//  FuturesAndPromises
//
//  Created by Frederick Javalera on 12/26/21.
//

import Combine
import SwiftUI

class ContentViewModel: ObservableObject {
  @Published var title: String = "Starting title"
  let url = URL(string: "https://www.google.com")!
  var cancellables = Set<AnyCancellable>()
  init() {
    download()
  }
  
  func download() {
    
    //    Scenario 1 - download using combine publisher.
    //    getCombinePublisher()
    //      .sink { _ in
    //      // Completion
    //      } receiveValue: { [weak self] returnedValue in
    //        self?.title = returnedValue
    //      }
    //      .store(in: &cancellables)
    
    //    Scenario 2 - download using escaping closure.
    //    getEscapingClosure { [weak self] returnedValue, error in
    //      self?.title = returnedValue
    
    //  Scenario 3 - download using promise (promising a future combine publisher).
    getFuturePublisher()
      .sink { _ in
        // Completion
      } receiveValue: { [weak self] returnedValue in
        if !Thread.isMainThread {
          DispatchQueue.main.async {
            self?.title = returnedValue            
          }
        }
      }
      .store(in: &cancellables)
  }
  
  func getCombinePublisher() -> AnyPublisher<String, URLError> {
    URLSession.shared.dataTaskPublisher(for: url)
      .timeout(1, scheduler: DispatchQueue.main)
      .map({ _ in
        return "New Value"
      })
      .eraseToAnyPublisher()
  }
  
  func getEscapingClosure(completionHandler: @escaping (_ value: String, _ error: Error?) -> ()) {
    URLSession.shared.dataTask(with: url) { data, response, error in
      completionHandler("New Value 2", nil)
    }
    .resume()
  }
  
  func getFuturePublisher() -> Future<String, Error> {
    return Future { promise in
      self.getEscapingClosure { returnedValue, error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(returnedValue))
        }
      }
    }
  }
}

struct ContentView: View {
  @StateObject private var vm = ContentViewModel()
  var body: some View {
    Text(vm.title)
      .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
