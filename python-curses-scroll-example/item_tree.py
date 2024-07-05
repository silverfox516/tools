#!/usr/bin/python3

class Item():
    def __init__(self, item):
        self.item = item
        self.sub_items = []
        self.expanded = False

    def addSubItem(self, item):
        self.sub_items.append(item)

    def dump(self):
        print(self.item)
        if self.isExpanded():
            for i in self.sub_items:
                i.dump()

    def expand(self, value):
        self.expanded = value

    def isExpanded(self):
        return self.expanded

def main():
    root = Item("Root")
    root.expand(True)
    for i in range(0, 10):
        item = Item(i)
        if i % 2 == 0:
            item.expand(True)
        for j in range(11, 16):
            item.addSubItem(Item("\tsub %d:%d" % (i, j)))
        root.addSubItem(item)

    root.dump()

if __name__ == "__main__":
    main()
