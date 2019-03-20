//
//  FGDoodlingPathPlayView.swift
//  FGDoodlingBoardExample
//
//  Created by xgf on 2019/3/15.
//  Copyright © 2019年 mrpyq. All rights reserved.
//

import UIKit

private struct FGDoodlingPathPoint {
    var point : CGPoint
    var head : Bool = false
    var color : UIColor?
}

public class FGDoodlingPathPlayView: UIView {
    private var points = [FGDoodlingPathPoint]()
    private var currentPlayingPoints = [FGDoodlingPathPoint]()
    private var currentPlayingPointCount = 0
    private var isPlaying = false
    private var timer : DispatchSourceTimer?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = hexcolor(0xf4f4f4)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = hexcolor(0xf4f4f4)
    }
}

public extension FGDoodlingPathPlayView {
    public func setContents(contents : [[String : Any]]) {
        if isPlaying {
            timer?.cancel()
            currentPlayingPoints = [FGDoodlingPathPoint].init(points)
            setNeedsDisplay()
            isPlaying = false
            return
        }
        var pathPoints = [FGDoodlingPathPoint]()
        for dict in contents {
            let hex = dict["color"] as? UInt ?? 0x000000
            let color = hexcolor(hex)
            let linePoints = dict["points"] as? [[String : CGFloat]] ?? []
            for i in 0 ..< linePoints.count {
                let linePoint = linePoints[i]
                let x = linePoint["x"] ?? 0
                let y = linePoint["y"] ?? 0
                let p = FGDoodlingPathPoint.init(point: .init(x: x, y: y), head: (i == 0), color: (i == 0) ? color : nil)
                pathPoints.append(p)
            }
        }
        points = [FGDoodlingPathPoint].init(pathPoints)
        currentPlayingPoints.removeAll()
        currentPlayingPointCount = 0
        timerStart()
        isPlaying = true
    }
    
    private func timerStart() {
        if timer != nil {
            timer?.cancel()
        }
        timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        weak var wkself = self
        timer?.setEventHandler {
            wkself?.playPoints()
        }
        timer?.schedule(deadline: .now(), repeating: .microseconds(10), leeway: .seconds(0))
        timer?.resume()
    }
    
    private func playPoints() {
        currentPlayingPointCount += 1
        if currentPlayingPointCount > points.count {
            timer?.cancel()
            isPlaying = false
            return
        }
        let seq = points[..<points.index(points.startIndex, offsetBy: currentPlayingPointCount)]
        currentPlayingPoints = [FGDoodlingPathPoint].init(seq)
        setNeedsDisplay()
    }
}

public extension FGDoodlingPathPlayView {
    override public func draw(_ rect: CGRect) {
        var path = UIBezierPath.init()
        path.lineWidth = 4.0
        var color : UIColor? = nil
        for pt in currentPlayingPoints {
            if pt.head {
                if color != nil {
                    color?.set()
                    path.stroke()
                    path.close()
                }
                color = pt.color
                path = UIBezierPath.init()
                path.lineWidth = 4.0
                path.move(to: pt.point)
            } else {
                path.addLine(to: pt.point)
            }
        }
        if color != nil {
            color?.set()
        }
        path.stroke()
        path.close()
    }
}
