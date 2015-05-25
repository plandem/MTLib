Pod::Spec.new do |s|
  s.name          = 'MTLib'
  s.version       = '1.0.0'
  s.summary       = 'Some useful classes'
  s.license       = 'MIT'
  s.homepage      = 'http://bitbucket.org/plandem/mtlib'
  s.author        = { 'Andrey Gayvoronsky' => 'plandem@gmail.com' }
  #s.source        = { :git => 'https://plandem@bitbucket.org/plandem/mtlib.git', :tag => s.version.to_s }
  s.requires_arc  = true
  s.framework     = 'Foundation'
  s.ios.deployment_target = '8.0'
#    logger.source_files = 'MTLogger/**/*.{h,m}'

  s.subspec 'MTLogger' do |logger|
    logger.dependency 'CocoaLumberjack'
    logger.dependency 'CrashlyticsFramework'
    logger.dependency 'CrashlyticsLumberjack'
    logger.source_files = 'MTLogger/**/*.{h,m}'
#    logger.source_files = 'MTLogger/MTLogger.h', 'MTLogger/MTLogger.m'
  end

  s.subspec 'MTLogger+Crashlytics' do |logger|
    logger.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DMTLOGGER_CRASHLYTICS' }
    logger.dependency 'MTLib/MTLogger'
    logger.dependency 'CrashlyticsFramework'
    logger.dependency 'CrashlyticsLumberjack'
    #logger.source_files = 'MTLogger/MTLogger+Crashlytics.h', 'MTLogger/MTLogger+Crashlytics.m'
  end
end