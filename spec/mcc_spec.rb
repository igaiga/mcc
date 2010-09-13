require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "Mcc" do
  it "should run" do
    MCC.should_receive(:include_magick_comment?).with('foo.rb')
    MCC.should_receive(:include_magick_comment?).with('bar.rb')
    MCC.should_receive(:insert_magick_comment).with('foo.rb', '# encoding: utf-8')
    MCC.should_receive(:insert_magick_comment).with('bar.rb', '# encoding: utf-8')

    MCC.run(['foo.rb', 'bar.rb'], '# encoding: utf-8')
  end

  it 'should check to include a magick comment' do
    {
      'with_magick_comment.rb'             => true,
      'without_magick_comment.rb'          => false,
      'with_shebang_and_magick_comment.rb' => true,
      'empty.rb'                           => false
    }.each do |k, v|
      MCC.include_magick_comment?(fixture_file(k)).should be v
    end
  end

  it 'should insert a magick comment' do
    {
      'without_magick_comment.rb'             => true,
      'without_shebung_and_magick_comment.rb' => false,
      'empty.rb'                              => false
    }.each do |file, include_shebang|
      begin
        tmp = Tempfile.open(file)
        FileUtils.cp(fixture_file(file), tmp.path)
        MCC.insert_magick_comment(tmp.path, '# encoding: utf-8')

        MCC.include_magick_comment?(tmp.path).should be true
        MCC.include_shebang?(tmp.path).should be include_shebang
      ensure
        tmp.close
      end
    end
  end

  it 'should check include a shebang' do
    MCC.include_shebang?(fixture_file('with_shebang_and_magick_comment.rb')).should be true
    MCC.include_shebang?(fixture_file('with_magick_comment.rb')).should be false
    MCC.include_shebang?(fixture_file('empty.rb')).should be false
  end

  def fixture_file(filename)
    File.join(File.dirname(__FILE__), 'fixtures', filename)
  end
end
