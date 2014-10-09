filebucket { 'main':
  path   => false,
}

File { backup => 'main', }

include profile::base
