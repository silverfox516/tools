#!/usr/bin/python3

import curses
import tui

class Item():
    def __init__(self, item):
        self.item = item
        self.sub_items = []
        self.expanded = False
        self.parent = None

    def addSubItem(self, item):
        self.sub_items.append(item)
        item.parent = self

    def expand(self, value):
        self.expanded = value

    def isExpanded(self):
        return self.expanded

    def toList(self, l):
        l.append(self)
        if self.isExpanded():
            for i in self.sub_items:
                l = i.toList(l)
        return l

class SpecScreen(tui.Screen):
    def display(self):
        """Display the items on window"""
        self.window.erase()
        for idx, item in enumerate(self.items[self.top:self.top + self.max_lines]):
            # Highlight the current cursor line
            if idx == self.current:
                self.window.addstr(idx, 0, item.item, curses.color_pair(2))
            else:
                self.window.addstr(idx, 0, item.item, curses.color_pair(1))
        self.window.refresh()

def main():
    root = Item("Root")
    root.expand(True)
    for i in range(0, 10):
        item = Item("%d" % i)
        if i % 2 == 0:
            item.expand(True)
        for j in range(11, 16):
            jtem = Item("\tsub %d:%d" % (i, j))
            if j % 2 == 1:
                jtem.expand(True)
            for k in range(17, 21):
                ktem = Item("\t\tsubsub %d:%d:%d" % (i, j, k))
                jtem.addSubItem(ktem)
            item.addSubItem(jtem)
        root.addSubItem(item)

    l = []
    screen = SpecScreen(root.toList(l))
    screen.run()

if __name__ == "__main__":
    main()
