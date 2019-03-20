//
//  FGDoodlingBoard.swift
//  FGDoodlingBoardExample
//
//  Created by xgf on 2019/3/15.
//  Copyright © 2019年 mrpyq. All rights reserved.
//

import UIKit

public extension UIColor {
    public convenience init(_ hex : UInt) {
        let b = CGFloat(hex & 0xff) / 255.0
        let g = CGFloat((hex >> 8) & 0xff) / 255.0
        let r = CGFloat((hex >> 16) & 0xff) / 255.0
        let a = hex > 0xffffff ? CGFloat((hex >> 24) & 0xff) / 255.0 : 1.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

public func hexcolor(_ hex : UInt) -> UIColor {
    return UIColor.init(hex)
}

fileprivate class FGDoodlingBoardPath : UIBezierPath {
    var hex : UInt = 0x000000
    
    var points = [[String : CGFloat]]()
    
    var info : [String : Any] {
        get {
            var dict = [String : Any]()
            dict["color"] = hex
            dict["points"] = points
            return dict
        }
    }
    
    var strokeColor : UIColor {
        get {
            return hexcolor(hex)
        }
    }
}

//MARK: - 涂鸦板
public class FGDoodlingBoard: UIView {
    //MARK: - 绘制颜色
    public var hex : UInt = 0x000000
    
    public var strokeColor : UIColor {
        get {
            return hexcolor(hex)
        }
    }
    
    public var lineWidth : CGFloat = 4.0
    
    public var hasContents : Bool {
        get {
            return (paths.count > 0)
        }
    }
    
    public var hasRedo : Bool {
        return(undoPath != nil)
    }
    
    public var contents : [[String : Any]] {
        get {
            guard hasContents else {
                return []
            }
            let pathInfos = paths.map { $0.info }
            return pathInfos
        }
    }
    
    public var contentsChangeHandler : ((_ hasContents : Bool) -> ())?
    
    private var paths = [FGDoodlingBoardPath]()
    
    private var path = FGDoodlingBoardPath.init()
    
    private var undoPath : FGDoodlingBoardPath?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(pan(_:)))
        gesture.maximumNumberOfTouches = 1
        addGestureRecognizer(gesture)
    }
}

extension FGDoodlingBoard {
    @objc private func pan(_ sender : UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        if sender.state == .began {//开始画一根新的线
            path = FGDoodlingBoardPath.init()
            path.lineWidth = lineWidth
            path.hex = hex
            path.move(to: point)
            path.points.append(["x" : point.x, "y" : point.y])
            paths.append(path)
            contentsChangeHandler?(hasContents)
        }
        path.addLine(to: point)
        path.points.append(["x" : point.x, "y" : point.y])
        setNeedsDisplay()
    }
}

//MARK: - draw
extension FGDoodlingBoard {
    override public func draw(_ rect: CGRect) {
        paths.forEach {
            $0.strokeColor.set()
            $0.stroke()
        }
    }
}

//MARK: - public
public extension FGDoodlingBoard {
    public func undo() {
        guard paths.count > 0 else {
            return
        }
        undoPath = paths.removeLast()
        setNeedsDisplay()
        contentsChangeHandler?(hasContents)
    }
    
    public func redo() {
        guard let p = undoPath else {
            return
        }
        paths.append(p)
        setNeedsDisplay()
        undoPath = nil
        contentsChangeHandler?(hasContents)
    }
    
    public func clear() {
        paths.removeAll()
        undoPath = nil
        setNeedsDisplay()
        contentsChangeHandler?(hasContents)
    }
    
    public func snap() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: ctx)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

