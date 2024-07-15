#!/usr/bin/python3

import menu_item
import json
from enum import Enum

class Type(Enum):
    Root = 1
    Feature = 2
    Message = 3
    Parameter = 4
    Enum = 5
    GROUP = 6

class SpecItem(menu_item.Item):
    CSV_PREFIX = { 0:'', 1:',', 2:',,', 3:',,,,,', 4:',,,,,,,,,', 5:',,,,,,,,,,,,,' }

    def csv_string(self):
        pass

    def write_csv(self, f):
        f.write('%s%s\n' % (self.CSV_PREFIX[self.depth], self.csv_string()))
        for i in self.subitems:
            i.write_csv(f)

class Root(SpecItem):
    TYPE = Type.Root

    groups = []
    enums = []

    def parse_item(self, item):
        self.item = item['name']
        self.revision = item['revision']
        self.groups = item['groups']
        self.enums = item['enums']
        for i in item['features']:
            self.add_subitem(Feature(i, parent=self, tag=self.get_tag(), depth=(self.get_depth() + 1)))

    def item_string(self):
        return '%s, %s' % (self.item, self.revision)

    def csv_string(self):
        return '%s, %s' % (self.item, self.revision)

    def generate_csv(self, filename):
        with open(filename, 'w') as f:
            f.write('Feature, Feature\n')
            f.write('Message, Id, Source, Name\n')
            f.write('Parameter,,,,, Id, Name, Type, #\n')
            self.write_csv(f)

class Feature(SpecItem):
    TYPE = Type.Feature

    def parse_item(self, item):
        self.item = item['feature']
        for i in item['messages']:
            self.add_subitem(Message(i, parent=self, tag=self.get_tag(), depth=(self.get_depth() + 1)))

    def csv_string(self):
        return '%s' % (self.item)

class Message(SpecItem):
    TYPE = Type.Message

    def parse_item(self, item):
        self.id = item['id']
        self.source = item['source']
        self.name = item['name']
        self.item = self.name
        for i in item['parameters']:
            self.add_subitem(Parameter(i, parent=self, tag=self.get_tag(), depth=(self.get_depth() + 1)))

    def item_string(self):
        return 'id:%s source: %-9s %s ' % (self.id, self.source, self.name)

    def csv_string(self):
        return '%s,%s,%s' % (self.id, self.source, self.name)

class Parameter(SpecItem):
    TYPE = Type.Parameter

    def parse_item(self, item):
        self.id = item['id']
        self.name = item['name']
        self.type = item['type']
        self.sharp = item['#']
        self.see = ''
        self.item = self.name

        if self.type == 'group':
            self.see = item['see'] if 'see' in item else self.name
            for i in self.get_root().groups:
                if i['name'] == self.see:
                    for i in i['parameters']:
                        self.add_subitem(Parameter(i, parent=self, tag=self.get_tag(), depth=(self.get_depth() + 1)))
                    break
        elif self.type == 'enum':
            self.see = item['see'] if 'see' in item else self.name
            for i in self.get_root().enums:
                if i['name'] == self.see:
                    for i in i['values']:
                        self.add_subitem(Enum(i, parent=self, tag=self.get_tag(), depth=(self.get_depth() + 1)))
                    break
        self.expand(True)

    def item_string(self):
        return 'id:%2s %-50s type:%-10s #:%s' % (self.id, self.name, self.type, self.sharp)

    def csv_string(self):
        return '%s,%s,%s,%s,%s' % (self.id, self.name, self.type, self.sharp, self.see)

class Enum(SpecItem):
    TYPE = Type.Enum

    def parse_item(self, item):
        self.value = item['value']
        self.desc = item['desc']
        self.item = self.desc

        self.expand(True)

    def item_string(self):
        return 'value:%2d description:%s' % (self.value, self.desc)

    def csv_string(self):
        return '%s,%s' % (self.value, self.desc)

def main():
    file_ais = 'iap2_control_session_messages_r42.json'
    file_ais_cp_add = 'iap2_control_session_messages_carplay_addendum_r8.json'

    ais = json.load(open(file_ais))
    ais_cp_add = json.load(open(file_ais_cp_add))

    root_ais = Root(ais, parent=None, tag='ais_r42')
    root_ais_cp_add = Root(ais_cp_add, parent=None, tag='ais_cp_add_r8')

    #l = []
    #l = root_ais.make_item_list(l)
    #for t in l:
    #    print(t)

    root_ais.generate_csv('ais_r42.csv')
    root_ais_cp_add.generate_csv('ais_cp_add_r8.csv')

if __name__ == '__main__':
    main()
