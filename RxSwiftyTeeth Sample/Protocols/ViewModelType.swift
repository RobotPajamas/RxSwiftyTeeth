//
//  ViewModelType.swift
//  RxSwiftyTeeth Sample
//
//  Created by Suresh Joshi on 2018-03-23.
//  Copyright © 2018 Robot Pajamas. All rights reserved.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}
