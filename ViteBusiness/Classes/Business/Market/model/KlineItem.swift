//
//  KlineItem.swift
//  ViteBusiness
//
//  Created by Stone on 2020/3/17.
//

import Foundation
import ObjectMapper

struct KlineItem {
    
    let t: Int64
    let c: Double
    let o: Double
    let h: Double
    let l: Double
    let v: Double

    init(t: Int64, c: Double, o: Double, h: Double, l: Double, v: Double) {
        self.t = t
        self.c = c
        self.o = o
        self.h = h
        self.l = l
        self.v = v
    }

    init(klineProto: KlineProto) {
        self.t = klineProto.t
        self.c = klineProto.c
        self.o = klineProto.o
        self.h = klineProto.h
        self.l = klineProto.l
        self.v = klineProto.v
    }
}
