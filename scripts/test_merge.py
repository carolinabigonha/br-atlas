import unittest
import json
import merge

class TestMerge(unittest.TestCase):

    def test_merge_states(self):

        data = {}
        data[u"type"] = u"Topology"
        data[u"arcs"] = []
        data[u"transform"] = []
        data[u"objects"] = {}

        data[u"objects"][u"ac-state"] = {}
        data[u"objects"][u"ac-state"][u"type"] = u"GeometryCollection"
        data[u"objects"][u"ac-state"][u"geometries"] = []
        data[u"objects"][u"ac-state"][u"geometries"].append(
            {u"type":u"Polygon",u"properties":{u"name":u"ACRE",u"region":"NORTE"},u"id":u"12",u"arcs":[[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]]})

        data[u"objects"][u"al-state"] = {}
        data[u"objects"][u"al-state"][u"type"] = u"GeometryCollection"
        data[u"objects"][u"al-state"][u"geometries"] = []
        data[u"objects"][u"al-state"][u"geometries"].append(
            {u"type":u"Polygon",u"properties":{u"name":u"ALAGOAS",u"region":"NORDESTE"},u"id":u"27",u"arcs":[[15,16,17,18,19,20]]})

        result = merge.merge(data)

        self.assertEquals(len(result[u'objects'][u'states']), 2)
        self.assertEquals(result[u'objects'][u'states'][u'type'], u'GeometryCollection')
        self.assertEquals(len(result[u'objects'][u'states'][u'geometries']), 2)
        self.assertEquals(result[u'objects'][u'states'][u'geometries'][0][u'type'], u'Polygon')

    def test_merge_counties(self):

        data = {}
        data[u"type"] = u"Topology"
        data[u"arcs"] = []
        data[u"transform"] = []
        data[u"objects"] = {}

        data[u"objects"][u"ac-counties"] = {}
        data[u"objects"][u"ac-counties"][u"type"] = u"GeometryCollection"
        data[u"objects"][u"ac-counties"][u"geometries"] = []
        data[u"objects"][u"ac-counties"][u"geometries"].append({u"type":u"Polygon",u"properties":{}})

        result = merge.merge(data)

        self.assertEquals(len(result[u'objects'][u'counties']), 2)
        self.assertEquals(result[u'objects'][u'counties'][u'type'], u'GeometryCollection')
        self.assertEquals(len(result[u'objects'][u'counties'][u'geometries']), 1)

if __name__ == '__main__':
    unittest.main()
