//
//  RxSwiftyTeeth.swift
//  RxSwiftyTeeth
//
//  Created by Suresh Joshi on 2018-03-16.
//

import RxSwift
import SwiftyTeeth

public extension Reactive where Base: SwiftyTeeth {
    func scan() -> Observable<Device> {
        return Observable.create({ (observer) -> Disposable in
            self.base.scan(changes: { (device) in
                observer.onNext(device)
            })
            
            return Disposables.create {
                self.base.stopScan()
            }
        })
    }
}
