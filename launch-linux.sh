#!/bin/bash
cd "$(dirname "$0")"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:$PWD/bin/linux64
love ./src