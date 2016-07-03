#!/bin/sh

mv nanoc.yaml nanoc.local.yaml
mv nanoc.gh-pages.yaml nanoc.yaml

nanoc

mv nanoc.yaml nanoc.gh-pages.yaml
mv nanoc.local.yaml nanoc.yaml
