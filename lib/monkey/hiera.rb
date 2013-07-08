# MonkeyPatch of HieraPuppet for compilation to override the hiera lookup function and always return a value
module HieraPuppet
  def self.lookup key, default, scope, override, resolution_type
    return "foo"
  end
end
