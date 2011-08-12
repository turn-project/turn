# This is a "dirty trick" to load `test/unit` or `minitest/unit` if sought.
# Eventually a way to handle this more robustly (without autoreload) 
# should be worked out.
autoload "Test",     'test/unit'
autoload "MiniTest", 'minitest/unit'

