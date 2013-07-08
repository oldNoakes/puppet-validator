class duplicate::name::same_types() {
  file { "/etc/foo": }
  file { "/etc/foo": }
}
