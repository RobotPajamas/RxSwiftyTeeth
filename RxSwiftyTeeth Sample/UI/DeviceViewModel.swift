//
//  DeviceViewModel.swift
//  RxSwiftyTeeth Sample
//
//  Created by Suresh Joshi on 2018-03-23.
//  Copyright © 2018 Robot Pajamas. All rights reserved.
//

import RxCocoa
import RxSwift
import RxSwiftyTeeth
import SwiftyTeeth

protocol DeviceViewNavigator {
    func navigateBack()
}

final class DeviceViewModel: ViewModelType {
    typealias Navigator = DeviceViewNavigator

    private let navigator: Navigator

    struct Input {
        let peripheral: Device
        let readTapped: Driver<Void>
        let writeTapped: Driver<Void>
        let subscribeTapped: Driver<Void>
    }

    struct Output {
        let readRequest: Driver<Data>
        let writeRequest: Driver<Void>
        let subscribeRequest: Driver<Data>
    }

    init(navigator: Navigator) {
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let readRequest = input.readTapped
            .flatMapFirst({ (_) -> Driver<Data> in
                return input.peripheral.rx.read(from: "", in: "")
                    .asDriver(onErrorJustReturn: Data())
            })
        
        let writeRequest = input.writeTapped
            .flatMapFirst({ (_) -> Driver<Void> in
                return input.peripheral.rx.write(data: Data(), to: "", in: "")
                    .asDriver(onErrorJustReturn: ())
            })
        
        let subscribeRequest = input.subscribeTapped
            .flatMapFirst({ (_) -> Driver<Data> in
                return input.peripheral.rx.subscribe(to: "", in: "")
                    .asDriver(onErrorJustReturn: Data())
            })
        
        return Output(readRequest: readRequest,
                      writeRequest: writeRequest,
                      subscribeRequest: subscribeRequest)
    }
}
