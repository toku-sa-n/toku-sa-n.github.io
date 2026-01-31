+++
title = "EbuildでGitのSubmoduleを扱う"
data = 2026-01-31
+++

GentooのEbuildを書く際、サブモジュールが入っていると、https://github.com/toku-sa-n/toku-sa-n.github.io/archive/${PV}.tar.gzのようなURLでソースコードをダウンロードした際に、サブモジュールに含まれているファイルが含まれず、正しくビルドできない。

既存のEbuildを確認してみたが、サブモジュールとして指定されているリポジトリは個別にソースコードをダウンロードし、ソースコードをコピーしている模様[^https://gitweb.gentoo.org/repo/gentoo.git/tree/media-plugins/vdr-fritzbox/vdr-fritzbox-1.5.8.ebuild]
