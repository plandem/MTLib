Pod::Spec.new do |s|
  s.name          = 'MTLib'
  s.version       = '1.0.0'
  s.summary       = 'Some useful classes'
  s.license       = 'MIT'
  s.homepage      = 'http://bitbucket.org/plandem/mtlib'
  s.author        = { 'Andrey Gayvoronsky' => 'plandem@gmail.com' }
  s.requires_arc  = true
  s.framework     = 'Foundation', 'UIKit'
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'MTCore', 'MTLogger', 'MTData'

  s.subspec 'MTCore' do |ss|
    ss.source_files = 'MTCore/**/*.{h,m}'
  end

  s.subspec 'MTLogger' do |ss|
    ss.dependency 'CocoaLumberjack'
    ss.dependency 'CrashlyticsFramework'
    ss.dependency 'CrashlyticsLumberjack'
    ss.source_files = 'MTLogger/**/*.{h,m}'
  end

  s.subspec 'MTLogger+Crashlytics' do |ss|
    ss.dependency 'MTLib/MTLogger'
    ss.dependency 'CrashlyticsFramework'
    ss.dependency 'CrashlyticsLumberjack'
    ss.source_files = 'MTLogger+Crashlytics/**/*.{h,m}'
  end

  s.subspec 'MTi18n' do |ss|
    ss.dependency 'MTLib/MTCore'
    ss.source_files = 'MTi18n/**/*.{h,m}'
  end

  s.subspec 'MTSlider' do |ss|
    ss.source_files = 'MTSlider/**/*.{h,m}'
  end

  s.subspec 'MTForm' do |ss|
    ss.dependency 'FXForms'
    ss.dependency 'MTLib/MTCore'
    ss.source_files = 'MTForm/**/*.{h,m}'
  end

  s.subspec 'MTData' do |ss|
    ss.source_files = 'MTData/**/*.{h,m}'
  end

  s.subspec 'MTData+Realm' do |ss|
    ss.dependency 'Realm'
    ss.dependency 'MTLib/MTData'
    ss.source_files = 'MTData+Realm/**/*.{h,m}'
  end
end