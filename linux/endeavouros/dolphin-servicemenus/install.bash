#!/bin/bash

mkdir -p ~/.local/share/kio/servicemenus/

for f in vlc.desktop; do
  cp ${f} ~/.local/share/kio/servicemenus/ || exit $?
  chmod a+x ~/.local/share/kio/servicemenus/${f} || exit $?
done

kbuildsycoca6