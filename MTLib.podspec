Pod::Spec.new do |s|
  s.name          = 'MTLib'
  s.version       = '1.0.0'
  s.summary       = 'Some useful mini helpers for iOS / OSX'
  s.license       = { :type => 'MIT' }
  s.homepage      = 'https://github.com/plandem/MTLib'
  s.author        = { 'Andrey Gayvoronsky' => 'plandem@gmail.com' }
  s.requires_arc  = true
  s.framework     = 'Foundation'
  s.ios.deployment_target = '8.0'
  s.default_subspec = 'MTCore', 'MTLogger', 'MTData'
  s.source   = { :git => 'https://github.com/plandem/MTLib.git', :tag => "#{s.version}", :submodules => true }

  s.subspec 'MTCore' do |ss|
    ss.dependency 'libextobjc'
    ss.source_files = 'MTCore/**/*.{h,m}'
  end

  s.subspec 'MTLogger' do |ss|
    ss.dependency 'CocoaLumberjack', '2.0.0'
    ss.source_files = 'MTLogger/**/*.{h,m}'
  end

  s.subspec 'MTLogger+Crashlytics' do |ss|
    ss.dependency 'MTLib/MTLogger'
    ss.dependency 'Fabric'
    ss.dependency 'Crashlytics'
    ss.dependency 'CrashlyticsLumberjack'
    ss.source_files = 'MTLogger+Crashlytics/**/*.{h,m}'
  end

  s.subspec 'MTUIKit' do |ss|
    ss.framework = 'UIKit'
    ss.dependency 'MTLib/MTCore'
    ss.source_files = 'MTUIKit/**/*.{h,m}'
  end

  s.subspec 'MTUIKit' do |ss|
    ss.framework = 'UIKit'
    ss.dependency 'MTLib/MTCore'
    ss.source_files = 'MTUIKit/**/*.{h,m}'
  end

  s.subspec 'MTRouter' do |ss|
    ss.framework = 'UIKit'
    ss.dependency 'MTLib/MTCore'
    ss.source_files = 'MTRouter/**/*.{h,m}'
  end

  s.subspec 'MTForm' do |ss|
    ss.framework = 'UIKit'
    ss.dependency 'FXForms'
    ss.dependency 'MTLib/MTUIKit'
    ss.source_files = 'MTForm/**/*.{h,m}'
  end

  s.subspec 'MTi18n' do |ss|
    ss.framework = 'UIKit'
    ss.dependency 'MTLib/MTCore'
    ss.source_files = 'MTi18n/**/*.{h,m}'
  end

  s.subspec 'MTData' do |ss|
    ss.source_files = 'MTData/**/*.{h,m}'
  end

  s.subspec 'MTData+Realm' do |ss|
    ss.dependency 'Realm'
    ss.dependency 'MTLib/MTData'
    ss.source_files = 'MTData+Realm/**/*.{h,m}'
  end

  s.subspec 'MTData+CoreData' do |ss|
    ss.dependency 'MTLib/MTLogger'
    ss.dependency 'MTLib/MTData'
    ss.dependency 'NLCoreData'
    ss.source_files = 'MTData+CoreData/**/*.{h,m}'
  end

  s.subspec 'MTData+SQLite' do |ss|
    ss.dependency 'MTLib/MTLogger'
    ss.dependency 'MTLib/MTData'
    ss.dependency 'FMDB'
    ss.source_files = 'MTData+SQLite/**/*.{h,m}'
  end

  s.subspec 'MTViewModel' do |ss|
    ss.dependency 'ReactiveCocoa', '2.5'
    ss.dependency 'ReactiveViewModel', '0.3'
    ss.dependency 'MTLib/MTLogger'
    ss.dependency 'MTLib/MTRouter'
    ss.dependency 'MTLib/MTData'
    ss.dependency 'MTLib/MTForm'
    ss.source_files = 'MTViewModel/**/*.{h,m}'
  end
end