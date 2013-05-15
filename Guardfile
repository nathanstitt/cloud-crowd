notification :growl

def run( file )
  if File.exists?(file)
    success = system( "ruby -r test/unit -I ./test/  #{file}")
    if success
      Growl.notify_ok file
    else
      Growl.notify_error file
    end
  end
end

guard 'shell' do
  watch(%r|^lib/*/(.*)\.rb|)      { |m| run "test/unit/test_#{File.basename(m[1])}.rb" }
  watch(%r|^test/(.*)\/?test_(.*)\.rb|) { |m| run m[0] }
end
