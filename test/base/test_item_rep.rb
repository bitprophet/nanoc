require 'test/helper'

class Nanoc::ItemRepTest < MiniTest::Unit::TestCase

  def setup    ; global_setup    ; end
  def teardown ; global_teardown ; end

  def test_created_modified_compiled
    # TODO implement
  end

  def test_to_proxy
    # Create item rep
    rep = Nanoc::ItemRep.new(nil, 'blah')

    # Create proxy
    rep_proxy = rep.to_proxy

    # Test
    assert_equal(rep, rep_proxy.instance_eval { @obj })
  end

  def test_raw_path
    # Create site
    site = MiniTest::Mock.new

    # Create item and rep
    item = MiniTest::Mock.new
    item.expect(:site, site)
    rep = Nanoc::ItemRep.new(item, 'blah')

    # Create site and router
    router = MiniTest::Mock.new
    site.expect(:router, router)
    router.expect(:raw_path_for, 'output/blah/test.html', [ rep ])

    # Test
    assert_equal('output/blah/test.html', rep.raw_path)
    item.verify
    site.verify
    router.verify
  end

  def test_path
    # Create site
    compiler = MiniTest::Mock.new
    site = MiniTest::Mock.new
    site.expect(:compiler, compiler)

    # Create item and rep
    item = MiniTest::Mock.new
    item.expect(:site, site)
    rep = Nanoc::ItemRep.new(item, 'blah')
    compiler.expect(:compile_rep, true, [ rep, false ])

    # Create site and router
    router = MiniTest::Mock.new
    site.expect(:router, router)
    router.expect(:path_for, '/foo/bar/baz/', [ rep ])

    # Test
    assert_equal('/foo/bar/baz/', rep.path)
    item.verify
    site.verify
    router.verify
  end

  def test_not_outdated
    # Mock item
    item = MiniTest::Mock.new
    item.expect(:mtime, Time.now-500)
    item.expect(:attribute_named, false, [ :skip_output ])

    # Mock layouts
    layouts = [ mock ]
    layouts[0].stubs(:mtime).returns(Time.now-800)

    # Mock code
    code = mock
    code.stubs(:mtime).returns(Time.now-900)

    # Mock site
    site = mock
    site.stubs(:layouts).returns(layouts)
    site.stubs(:code).returns(code)
    item.stubs(:site).returns(site)

    # Create output file
    File.open('output.html', 'w') { |io| io.write('Testing testing 123...') }
    File.utime(Time.now-100, Time.now-200, 'output.html')

    # Create rep
    rep = Nanoc::ItemRep.new(item, 'blah')
    rep.instance_eval { @raw_path = 'output.html' }

    # Test
    refute(rep.outdated?)
  ensure
    FileUtils.rm_f('output.html')
  end

  def test_outdated_if_mtime_nil
    # Mock item
    item = MiniTest::Mock.new
    item.expect(:mtime, nil)
    item.expect(:attribute_named, false, [ :skip_output ])

    # Mock layouts
    layouts = [ mock ]
    layouts[0].stubs(:mtime).returns(Time.now-800)

    # Mock code
    code = mock
    code.stubs(:mtime).returns(Time.now-900)

    # Mock site
    site = mock
    site.stubs(:layouts).returns(layouts)
    site.stubs(:code).returns(code)
    item.stubs(:site).returns(site)

    # Create output file
    File.open('output.html', 'w') { |io| io.write('Testing testing 123...') }
    File.utime(Time.now-100, Time.now-200, 'output.html')

    # Create rep
    rep = Nanoc::ItemRep.new(item, 'blah')
    rep.instance_eval { @raw_path = 'output.html' }

    # Test
    assert(rep.outdated?)
  ensure
    FileUtils.rm_f('output.html')
  end

  def test_outdated_if_force_outdated
    # Mock item
    item = MiniTest::Mock.new
    item.expect(:mtime, Time.now-500)
    item.expect(:attribute_named, false, [ :skip_output ])

    # Mock layouts
    layouts = [ mock ]
    layouts[0].stubs(:mtime).returns(Time.now-800)

    # Mock code
    code = mock
    code.stubs(:mtime).returns(Time.now-900)

    # Mock site
    site = mock
    site.stubs(:layouts).returns(layouts)
    site.stubs(:code).returns(code)
    item.stubs(:site).returns(site)

    # Create output file
    File.open('output.html', 'w') { |io| io.write('Testing testing 123...') }
    File.utime(Time.now-100, Time.now-200, 'output.html')

    # Create rep
    rep = Nanoc::ItemRep.new(item, 'blah')
    rep.instance_eval { @raw_path = 'output.html' }
    rep.instance_eval { @force_outdated = true }

    # Test
    assert(rep.outdated?)
  ensure
    FileUtils.rm_f('output.html')
  end

  def test_outdated_if_compiled_file_doesnt_exist
    # Mock item
    item = MiniTest::Mock.new
    item.expect(:mtime, Time.now-500)
    item.expect(:attribute_named, false, [ :skip_output ])

    # Mock layouts
    layouts = [ mock ]
    layouts[0].stubs(:mtime).returns(Time.now-800)

    # Mock code
    code = mock
    code.stubs(:mtime).returns(Time.now-900)

    # Mock site
    site = mock
    site.stubs(:layouts).returns(layouts)
    site.stubs(:code).returns(code)
    item.stubs(:site).returns(site)

    # Create rep
    rep = Nanoc::ItemRep.new(item, 'blah')
    rep.instance_eval { @raw_path = 'output.html' }

    # Test
    assert(rep.outdated?)
  ensure
    FileUtils.rm_f('output.html')
  end

  def test_outdated_if_source_file_too_old
    # Mock item
    item = MiniTest::Mock.new
    item.expect(:mtime, Time.now-100)
    item.expect(:attribute_named, false, [ :skip_output ])

    # Mock layouts
    layouts = [ mock ]
    layouts[0].stubs(:mtime).returns(Time.now-800)

    # Mock code
    code = mock
    code.stubs(:mtime).returns(Time.now-900)

    # Mock site
    site = mock
    site.stubs(:layouts).returns(layouts)
    site.stubs(:code).returns(code)
    item.stubs(:site).returns(site)

    # Create output file
    File.open('output.html', 'w') { |io| io.write('Testing testing 123...') }
    File.utime(Time.now-500, Time.now-600, 'output.html')

    # Create rep
    rep = Nanoc::ItemRep.new(item, 'blah')
    rep.instance_eval { @raw_path = 'output.html' }

    # Test
    assert(rep.outdated?)
  ensure
    FileUtils.rm_f('output.html')
  end

  def test_outdated_if_layouts_outdated
    # Mock item
    item = MiniTest::Mock.new
    item.expect(:mtime, Time.now-500)
    item.expect(:attribute_named, false, [ :skip_output ])

    # Mock layouts
    layouts = [ mock ]
    layouts[0].stubs(:mtime).returns(Time.now-100)

    # Mock code
    code = mock
    code.stubs(:mtime).returns(Time.now-900)

    # Mock site
    site = mock
    site.stubs(:layouts).returns(layouts)
    site.stubs(:code).returns(code)
    item.stubs(:site).returns(site)

    # Create output file
    File.open('output.html', 'w') { |io| io.write('Testing testing 123...') }
    File.utime(Time.now-200, Time.now-300, 'output.html')

    # Create rep
    rep = Nanoc::ItemRep.new(item, 'blah')
    rep.instance_eval { @raw_path = 'output.html' }

    # Test
    assert(rep.outdated?)
  ensure
    FileUtils.rm_f('output.html')
  end

  def test_outdated_if_code_outdated
    # Mock item
    item = MiniTest::Mock.new
    item.expect(:mtime, Time.now-500)
    item.expect(:attribute_named, false, [ :skip_output ])

    # Mock layouts
    layouts = [ mock ]
    layouts[0].stubs(:mtime).returns(Time.now-800)

    # Mock code
    code = mock
    code.stubs(:mtime).returns(Time.now-100)

    # Mock site
    site = mock
    site.stubs(:layouts).returns(layouts)
    site.stubs(:code).returns(code)
    item.stubs(:site).returns(site)

    # Create output file
    File.open('output.html', 'w') { |io| io.write('Testing testing 123...') }
    File.utime(Time.now-200, Time.now-300, 'output.html')

    # Create rep
    rep = Nanoc::ItemRep.new(item, 'blah')
    rep.instance_eval { @raw_path = 'output.html' }

    # Test
    assert(rep.outdated?)
  ensure
    FileUtils.rm_f('output.html')
  end

  def test_filter
    # Mock site
    site = MiniTest::Mock.new
    site.expect(:pages, [])
    site.expect(:assets, [])
    site.expect(:config, [])
    site.expect(:layouts, [])

    # Mock item
    item = MiniTest::Mock.new
    item.expect(:content, %[<%= '<%= "blah" %' + '>' %>])
    item.expect(:site, site)

    # Create item rep
    item_rep = Nanoc::ItemRep.new(item, '/foo/')
    item_rep.instance_eval do
      @content[:raw]  = item.content
      @content[:last] = @content[:raw]
    end

    # Filter once
    item_rep.filter(:erb)
    assert_equal(%[<%= "blah" %>], item_rep.instance_eval { @content[:last] })

    # Filter twice
    item_rep.filter(:erb)
    assert_equal(%[blah], item_rep.instance_eval { @content[:last] })
  end

  def test_layout
    # Mock layout
    layout = mock
    layout.stubs(:identifier).returns('/somelayout/')
    layout.stubs(:filter_class).returns(Nanoc::Filters::ERB)
    layout.stubs(:to_proxy).returns(nil)
    layout.stubs(:content).returns(%[<%= "blah" %>])

    # Mock site
    site = mock
    site.stubs(:pages).returns([])
    site.stubs(:assets).returns([])
    site.stubs(:config).returns([])
    site.stubs(:layouts).returns([ layout ])

    # Mock item
    item = mock
    item.stubs(:content).returns(%[Hello.])
    item.stubs(:site).returns(site)

    # Create item rep
    item_rep = Nanoc::ItemRep.new(item, '/foo/')
    item_rep.instance_eval do
      @content[:raw]  = item.content
      @content[:last] = @content[:raw]
    end

    # Layout
    item_rep.layout('/somelayout/')
    assert_equal(%[blah], item_rep.instance_eval { @content[:last] })
  end

  def test_snapshot
    # Mock site
    site = MiniTest::Mock.new
    site.expect(:pages, [])
    site.expect(:assets, [])
    site.expect(:config, [])
    site.expect(:layouts, [])

    # Mock item
    item = MiniTest::Mock.new
    item.expect(:content, %[<%= '<%= "blah" %' + '>' %>])
    item.expect(:site, site)

    # Create item rep
    item_rep = Nanoc::ItemRep.new(item, '/foo/')
    item_rep.instance_eval do
      @content[:raw]  = item.content
      @content[:last] = @content[:raw]
    end

    # Filter while taking snapshots
    item_rep.snapshot(:foo)
    item_rep.filter(:erb)
    item_rep.snapshot(:bar)
    item_rep.filter(:erb)
    item_rep.snapshot(:qux)

    # Check snapshots
    assert_equal(%[<%= '<%= "blah" %' + '>' %>], item_rep.instance_eval { @content[:foo] })
    assert_equal(%[<%= "blah" %>],               item_rep.instance_eval { @content[:bar] })
    assert_equal(%[blah],                        item_rep.instance_eval { @content[:qux] })
  end

  def test_write
    # Mock site, router and item
    router = MiniTest::Mock.new
    router.expect(:raw_path_for, 'tmp/foo/bar/baz/quux.txt', [ nil ])
    site = MiniTest::Mock.new
    site.expect(:router, router)
    item = MiniTest::Mock.new
    item.expect(:site, site)

    # Create rep
    item_rep = Nanoc::ItemRep.new(item, '/foo/')
    item_rep.instance_eval { @content[:last] = 'Lorem ipsum, etc.' }

    # Write
    item_rep.write

    # Check
    assert(File.file?('tmp/foo/bar/baz/quux.txt'))
    assert_equal('Lorem ipsum, etc.', File.read('tmp/foo/bar/baz/quux.txt'))
  end

end
