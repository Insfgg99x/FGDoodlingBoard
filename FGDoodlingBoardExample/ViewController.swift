//
//  ViewController.swift
//  FGDoodlingBoardExample
//
//  Created by xgf on 2019/3/15.
//  Copyright © 2019年 mrpyq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var board = FGDoodlingBoard.init(frame: .zero)
    private var  playView = FGDoodlingPathPlayView.init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        createDoodlingBoard()
        createUI()
    }
    
    private func setup() {
        view.backgroundColor = .white
        title = "Example"
        let play = UIBarButtonItem.init(barButtonSystemItem: .play,
                                        target: self,
                                        action: #selector(play(_:)))
        let snap = UIBarButtonItem.init(barButtonSystemItem: .camera,
                                        target: self,
                                        action: #selector(snap(_:)))
        play.tintColor = .white
        snap.tintColor = .white
        navigationItem.rightBarButtonItems = [snap, play]
    }
    
    private func createDoodlingBoard() {
        board.lineWidth = 4
        board.hex = 0x000000
        board.backgroundColor = hexcolor(0xf4f4f4)
        view.addSubview(board)
        board.frame = .init(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.width)
        board.center = view.center
        weak var wkself = self
        board.contentsChangeHandler = {
            (wkself?.view.viewWithTag(200) as? UIButton)?.isEnabled = $0
            (wkself?.view.viewWithTag(201) as? UIButton)?.isEnabled = wkself?.board.hasRedo ?? false
            (wkself?.view.viewWithTag(202) as? UIButton)?.isEnabled = $0
        }
    }
    
    private func createUI() {
        let sh = UIScreen.main.bounds.size.height
        let isX = (sh == 812 || sh == 896)
        let navH : CGFloat = isX ? 88 : 64
        let topH = (view.bounds.size.height - view.bounds.size.width) / 2 - navH
        let colors : [UInt] = [0x000000, 0xff4f5b, 0xffc34b, 0x00c16b, 0x00aef7]
        let marginx : CGFloat = 20
        let gapx : CGFloat = 20
        var w : CGFloat = 30
        var ypos = navH + topH / 2 - w / 2
        for i in 0 ..< colors.count {
            let xpos = marginx + (w + gapx) * CGFloat(i)
            let btn = UIButton.init()
            btn.backgroundColor = hexcolor(colors[i])
            view.addSubview(btn)
            btn.layer.cornerRadius = w / 2
            view.addSubview(btn)
            btn.frame = .init(x: xpos, y: ypos, width: w, height: w)
            btn.tag = 100 + i
            btn.addTarget(self, action: #selector(colorBtnClicked(_:)), for: .touchUpInside)
            btn.layer.borderWidth = 2
            if i == 0 {
                btn.layer.borderColor = UIColor.white.cgColor
            } else {
                btn.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
        let names = ["undo", "redo", "clear"]
        ypos = board.frame.maxY + (topH - w) / 2
        w = 50
        for i in 0 ..< names.count {
            let btn = UIButton.init()
            btn.setTitle(names[i], for: .normal)
            btn.setTitleColor(.blue, for: .normal)
            btn.setTitleColor(.lightGray, for: .disabled)
            btn.isEnabled = false
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            view.addSubview(btn)
            let xpos = marginx + (w + gapx) * CGFloat(i)
            btn.frame = .init(x: xpos, y: ypos, width: w, height: 30)
            btn.tag = 200 + i
            btn.addTarget(self, action: #selector(operateBtnClicked(_:)), for: .touchUpInside)
            btn.showsTouchWhenHighlighted = true
        }
    }
    
    @objc private func colorBtnClicked(_ sender : UIButton) {
        let index = sender.tag - 100
        for sub in view.subviews {
            if sub.tag >= 100 && sender.tag <= 105 {
                sub.layer.borderColor = UIColor.clear.cgColor
            }
        }
        if index == 0 {
            sender.layer.borderColor = UIColor.white.cgColor
        } else {
            sender.layer.borderColor = UIColor.black.cgColor
        }
        let colors : [UInt] = [0x000000, 0xff4f5b, 0xffc34b, 0x00c16b, 0x00aef7]
        board.hex = colors[index]
    }
    
    @objc private func operateBtnClicked(_ sender : UIButton) {
        let index = sender.tag - 200
        if index == 0 {
            board.undo()
        } else if index == 1 {
            board.redo()
        } else {
            board.clear()
        }
    }
}

extension ViewController {
    //MARK: - 播放绘画路径
    @objc private func play(_ sender : UIBarButtonItem) {
        let paths = board.contents
        guard paths.count > 0, let window = UIApplication.shared.keyWindow else {
            return
        }
        let back = UIControl.init(frame: window.bounds)
        back.backgroundColor = .black
        back.alpha = 0.5
        window.addSubview(back)
        window.addSubview(playView)
        playView.frame = board.frame
        playView.center = window.center
        playView.backgroundColor = hexcolor(0xf4f4f4)
        back.addTarget(self, action: #selector(hidePlayView(_:)), for: .touchUpInside)
        playView.setContents(contents: paths)
    }
    
    @objc private func hidePlayView(_ sender : UIControl) {
        sender.removeFromSuperview()
        playView.removeFromSuperview()
    }
    
    //MARK: - 绘画截图
    @objc private func snap(_ sender : UIBarButtonItem) {
        guard board.hasContents else {
            print("画板内容为空")
            return
        }
        guard let image = board.snap() else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            print("绘画截图保存成功")
            let alert = UIAlertController.init(title: "已保存至相册", message: nil, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}

