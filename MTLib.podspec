Pod::Spec.new do |spec|
  spec.name = 'MTLib'
  #spec.source_files = 'Classes/ShareKit/{Configuration,Core,Customize UI,UI}/**/*.{h,m,c}'
  # ...

  spec.subspec 'MTLogger' do |logger|
    logger.source_files = 'MTLogger/**/*.{h,m}'
    logger.dependency = 'CocoaLumberjack,CrashlyticsFramework,CrashlyticsLumberjack'
  end

  #spec.subspec 'Facebook' do |facebook|
  #  facebook.source_files = 'Classes/ShareKit/Sharers/Services/Facebook/**/*.{h,m}'
  #  facebook.compiler_flags = '-Wno-incomplete-implementation -Wno-missing-prototypes'
  #  facebook.dependency = 'Facebook-iOS-SDK'
  #end
  # ...
end