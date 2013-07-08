class dependencies::missing() {

  file { "/etc/foo":
    require => File["/missing/dependency"],
  }
}
