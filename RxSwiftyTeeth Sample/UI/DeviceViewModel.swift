//
//  DeviceViewModel.swift
//  RxSwiftyTeeth Sample
//
//  Created by Suresh Joshi on 2018-03-23.
//  Copyright © 2018 Robot Pajamas. All rights reserved.
//

import CoreBluetooth
import RxCocoa
import RxSwift
import RxSwiftyTeeth
import SwiftyTeeth

protocol DeviceViewNavigator {
    func navigateBack()
}

// TODO: Go back and re-think this part a bit - just hacking this in for the moment
protocol DeviceViewScreenLogger {
    func printUi(_ text: String?)
}

final class DeviceViewModel: ViewModelType {
    typealias Navigator = DeviceViewNavigator
    typealias ScreenLogger = DeviceViewScreenLogger

    private let navigator: Navigator
    private let screenLogger: ScreenLogger

    struct Input {
        let peripheral: Device
        let readTapped: Driver<Void>
        let writeTapped: Driver<Void>
        let subscribeTapped: Driver<Void>
    }

    struct Output {
        let connection: Observable<DiscoveredCharacteristic>
        let readRequest: Driver<Data>
        let writeRequest: Driver<Void>
        let subscribeRequest: Driver<Data>
    }

    init(navigator: Navigator, screenLogger: ScreenLogger) {
        self.navigator = navigator
        self.screenLogger = screenLogger
    }

    func transform(input: Input) -> Output {
        let peripheral = input.peripheral

        let connection = peripheral.rx.connect()
            .distinctUntilChanged()
            .do(onNext: { (isConnected) in
                self.screenLogger.printUi("App: Device is connected? \(isConnected)")
            })
            .filter { $0 == .connected }  // On each reconnection, re-discover services/characteristics
            .flatMap { (_) -> Observable<[Service]> in
                self.screenLogger.printUi("App: Starting service discovery...")
                return peripheral.rx.discoverServices()
            }
            .flatMap({ (services) -> Observable<Service> in
                Observable.from(services)
            })
            .flatMap({ (service) -> Observable<DiscoveredCharacteristic> in
                self.screenLogger.printUi(
                    "App: Discovering characteristics for service: \(service.uuid.uuidString)")
                return peripheral.rx.discoverCharacteristics(for: service)
            })

        let readRequest = input.readTapped
            .flatMapFirst({ (_) -> Driver<Data> in
                return peripheral.rx.read(
                    from: UUID(uuidString: "2a24")!, in: UUID(uuidString: "180a")!
                )
                .asDriver(onErrorJustReturn: Data())
            })

        let writeRequest = input.writeTapped
            .flatMapFirst({ (_) -> Driver<Void> in
                return peripheral.rx.write(
                    data: Data(), to: UUID(uuidString: "")!, in: UUID(uuidString: "")!
                )
                .asDriver(onErrorJustReturn: ())
            })

        let subscribeRequest = input.subscribeTapped
            .flatMapFirst({ (_) -> Driver<Data> in
                return peripheral.rx.subscribe(
                    to: UUID(uuidString: "2a24")!, in: UUID(uuidString: "180a")!
                )
                .asDriver(onErrorJustReturn: Data())
            })

        return Output(
            connection: connection,
            readRequest: readRequest,
            writeRequest: writeRequest,
            subscribeRequest: subscribeRequest)
    }
}
