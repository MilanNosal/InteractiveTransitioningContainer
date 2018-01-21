Pod::Spec.new do |s|
  s.name             = 'InteractiveTransitioningContainer'
  s.version          = '0.1.5'
  s.summary          = 'A UIKit custom container component that supports interactive transitions for switching between its containees.'
 
  s.description      = <<-DESC
A UIKit custom container component that supports interactive transitions for switching between its contained view controllers.
                       DESC
 
  s.homepage         = 'https://github.com/MilanNosal/InteractiveTransitioningContainer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Milan Nosal' => 'milan.nosal@gmail.com' }
  s.source           = { :git => 'https://github.com/MilanNosal/InteractiveTransitioningContainer.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.source_files = 'InteractiveTransitioningContainer/*'
 
end