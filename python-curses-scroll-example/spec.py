#!/usr/bin/python3

import item_tree
import tui
import json

AIS = 'iap2_control_session_messages_r42.json'
AIS_CP = 'iap2_control_session_messages_carplay_addendum_r8.json'

class Root(item_tree.Item):
    TYPE = 1
    KEY = 'iAP2 Control Session Messages'
    DEPTH = 0

    def parse(self, item):
        self.groups = item['groups']
        self.enums = item['enums']

        self.item = self.KEY
        for f in item[self.KEY]:
            self.sub_items.append(Feature(f, self))


class Feature(item_tree.Item):
    TYPE = 2
    DEPTH = 1

    def parse(self, item):
        self.item = item['feature']
        for m in item['messages']:
            self.sub_items.append(Message(m, self))

class Message(item_tree.Item):
    TYPE = 3
    DEPTH = 2

    def parse(self, item):
        self.item = item

        for p in self.item['parameters']:
            self.sub_items.append(Parameter(p, self))

    def itemString(self):
        return 'id:%s source: %-9s %s ' % (self.item['id'], self.item['source'], self.item['name'])

class Parameter(item_tree.Item):
    TYPE = 4
    DEPTH = 3

    def parse(self, item):
        self.item = item
        
        if self.item['type'] == 'group':
            for i in self.getRoot().groups:
                if i['name'] == (self.item['see'] if 'see' in self.item else self.item['name']):
                    for p in i['parameters']:
                        tmp = Parameter(p, self)
                        tmp.TYPE += 1
                        tmp.DEPTH += 1
                        self.sub_items.append(tmp)
                    break
        elif self.item['type'] == 'enum':
            for i in self.getRoot().enums:
                if i['name'] == (self.item['see'] if 'see' in self.item else self.item['name']):
                    for p in i['values']:
                        self.sub_items.append(Enum(p, self))
                    break
        self.expand(False)

    def itemString(self):
        return 'id:%2s %-50s type:%-10s #:%s' % (self.item['id'], self.item['name'], self.item['type'], self.item['#'])

class Group(item_tree.Item):
    TYPE = 5
    DEPTH = 4

class Enum(item_tree.Item):
    TYPE = 6
    DEPTH = 5

    def parse(self, item):
        self.item = item
        self.expand(False)

    def itemString(self):
        return 'value:%2d description:%s' % (self.item['value'], self.item['desc'])

def main():
    ais = json.load(open(AIS))
    ais_cp = json.load(open(AIS))

    root_ais = Root(ais, None)

    screen = item_tree.ItemScreen(root_ais)
    screen.run()

if __name__ == "__main__":
    main()
