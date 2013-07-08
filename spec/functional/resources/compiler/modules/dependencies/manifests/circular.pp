class dependencies::circular {
  file { "/side/one":
    require => File["/side/two"],
  }

  file { "/side/two":
    require => File["/side/one"],
  }
}
