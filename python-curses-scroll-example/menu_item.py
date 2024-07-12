#!/usr/bin/python3

import uuid

class Item():
    TYPE = 0
    DEPTH = 0

    def __init__(self, item):
        self.subitems = []
        self.uuid = uuid.uuid4()
        self.expand = True
        self.parent = None
        self.parse_item(item)

    def add_subitem(self, item):
        if not isinstance(item, Item):
            raise TypeError('Can not add item of type %s' % (type(item)))
        item.set_depth(self.get_depth() + 1)
        self.subitems.append(item)

    def set_depth(self, depth):
        self.DEPTH = depth

    def get_depth(self):
        return self.DEPTH

    def parse_item(self, item):
        self.item = item

    def get_uuid(self):
        return self.uuid

    def set_expand(self, expand):
        self.expand = expand

    def is_expanded(self):
        return self.expand

    def expand_of_uuid(self, expand, uuid):
        if self.uuid == uuid:
            self.set_expand(expand)
        else:
            for item in self.subitems:
                item.expand_of_uuid(expand, uuid)

    def display_string(self):
        return '%s%s' % ('    ' * self.DEPTH, self.item_string())

    def item_string(self):
        return '%s' % self.item

    def make_item_list(self, l):
        l.append(self.display_string())
        if self.is_expanded():
            for item in self.subitems:
                l = item.make_item_list(l)
        return l

def main():
    root = Item('Root')

    item1 = Item('Item 1')
    item2 = Item('Item 2')
    item3 = Item('Item 3')
    root.add_subitem(item1)
    root.add_subitem(item2)
    root.add_subitem(item3)

    item11 = Item('Item 1:1')
    item12 = Item('Item 1:2')
    item1.add_subitem(item11)
    item1.add_subitem(item12)

    item21 = Item('Item 2:2')
    item2.add_subitem(item21)

    item111 = Item('Item 1:1:1')
    item112 = Item('Item 1:1:2')
    item11.add_subitem(item111)
    item11.add_subitem(item112)

    print('all expanded --------------------')
    l = []
    for i in root.make_item_list(l):
        print(i)

    print('expand some ---------------------')
    root.expand_of_uuid(False, item1.get_uuid())
    l = []
    for i in root.make_item_list(l):
        print(i)

if __name__ == '__main__':
    main()
