#! /usr/bin/env python

# Merges the 'GeometryCollection' objects into the

import json
import sys
import re

def merge(data):

    objects = {}
    objects[u'type'] = u'GeometryCollection'
    objects[u'geometries'] = []

    base_type = re.match('\w\w-(\w+)', data[u'objects'].keys()[0]).group(1)

    if base_type == 'state':
        object_type = 'states'
    else:
        object_type = base_type

    for state_object in data[u'objects']:
        obj = data[u'objects'][state_object][u'geometries']
        objects[u'geometries'].append(obj[0])

    topo = {}
    topo[u'objects'] = {}
    topo[u'objects'][object_type] = objects
    topo[u'type'] = data[u'type']
    topo[u'transform'] = data[u'transform']
    topo[u'arcs'] = data[u'arcs']

    return topo

if __name__ == '__main__':
    in_file = open(sys.argv[1], 'r')
    data = json.loads(in_file.readline())
    print json.dumps(merge(data))
