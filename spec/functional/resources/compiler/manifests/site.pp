node valid_node {
  class { "autofail" : fail => false }
}

node dupes_type {
  class { "duplicate::name::same_types": }
}

node fail_call {
  class { "autofail": }
}

node missing_dependency {
  class { "dependencies::missing": }
}

node circular_dependency {
  class { "dependencies::circular": }
}

node no_template {
  class { "missing::template": }
}

node dynamic_scope {
  class { "dynamic_scope::dynamic": }
}
