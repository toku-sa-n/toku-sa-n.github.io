#!/bin/zsh -xe

# Do not use `find` with the `-exec` option because it will not fail even if a
# command fails. See
# https://apple.stackexchange.com/questions/49042/how-do-i-make-find-fail-if-exec-fails.
#
# The last `(/)` limits a grob to list only directories. See
# https://qiita.com/termoshtt/items/a99559dca654ff016b90.
for dir in content/blog/*/tests/
do
    # The commands are enclosed in parentheses to prevent `cd` from affecting
    # other successive test scripts.
    (cd $dir && ./run.sh)
done
