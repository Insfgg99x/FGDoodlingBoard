Pod::Spec.new do |s|
s.name         = "FGDoodlingBoard"
s.version      = "1.0"
s.summary      = "涂鸦板，支持撤销、重做、清除、播放路径动画等，类似QQ涂鸦板。"
s.homepage     = "https://github.com/Insfgg99x/FGDoodlingBoard"
s.license      = "MIT"
s.authors      = { "CGPointZero" => "newbox0512@yahoo.com" }
s.source       = { :git => "https://github.com/Insfgg99x/FGDoodlingBoard.git", :tag => "1.0"}
s.frameworks   = 'Foundation','UIKit'
s.ios.deployment_target = '8.0'
s.source_files = 'FGDoodlingBoard/*.swift'
s.requires_arc = true
s.dependency     'SnapKit'
s.dependency	 'FGHUD', '2.4'
s.dependency     'FGToolKit', '2.1.1'
end

