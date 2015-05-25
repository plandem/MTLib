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

    s.source_files = 'MTLogger/**/*.{h,m}'
    s.dependency = 'CocoaLumberjack'
    s.dependency = 'CrashlyticsFramework'
    s.dependency = 'CrashlyticsLumberjack'

  #s.subspec 'MTLogger' do |logger|
  #  logger.source_files = 'MTLogger/**/*.{h,m}'
  #  logger.dependency = 'CocoaLumberjack'
  #  logger.dependency = 'CrashlyticsFramework'
  #  logger.dependency = 'CrashlyticsLumberjack'
  #end
end