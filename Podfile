source 'https://github.com/CocoaPods/Specs.git'
platform:ios, '7.0'

target 'Fakaixin' do

#Framworks
#环信2.x版本
pod 'EaseMobSDK', :git => 'https://github.com/easemob/sdk-ios-cocoapods.git'
pod 'UMengAnalytics', '~> 4.0.4'
pod 'BeeCloud/Alipay', '~> 3.4.3'
pod 'BeeCloud/Wx', '~> 3.4.3'
#统计
pod 'GrowingIO'

#Networking
pod 'AFNetworking', '~> 3.1.0'
pod 'SDWebImage-ProgressView', '~> 0.4.0'
pod 'JSONModel', '~> 1.1.0'
pod "Qiniu", :git => 'https://github.com/qiniu/objc-sdk.git', :branch => 'AFNetworking-3.x'

#shareSDK --start-－

# 主模块(必须)
pod 'ShareSDK3'
# Mob 公共库(必须) 如果同时集成SMSSDK iOS2.0:可看此注意事项：http://bbs.mob.com/thread-20051-1-1.html
pod 'MOBFoundation'

# UI模块(非必须，需要用到ShareSDK提供的分享菜单栏和分享编辑页面需要以下1行)
#pod 'ShareSDK3/ShareSDKUI'

# 平台SDK模块(对照一下平台，需要的加上。如果只需要QQ、微信、新浪微博，只需要以下3行)
pod 'ShareSDK3/ShareSDKPlatforms/QQ'
pod 'ShareSDK3/ShareSDKPlatforms/SinaWeibo'
pod 'ShareSDK3/ShareSDKPlatforms/WeChat'

#shareSDK --end--

end

inhibit_all_warnings!
