#!/usr/bin/python3

import curses
import tui
import uuid

class Item():
    def __init__(self, item):
        self.item = item
        self.sub_items = []
        self.expanded = False
        self.parent = None
        self.uuid = uuid.uuid4()

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

    def toString(self):
        return "%s, isExpanded : %r" % (self.item, self.isExpanded())

class SpecScreen(tui.Screen):
    DEBUG = True

    def __init__(self, items):
        self.items_list = []
        self.items_list = items.toList(self.items_list)
        super().__init__(self.items_list)

    def init_curses(self):
        super().init_curses()

        if self.DEBUG:
            self.debugwin = curses.newwin(10, 100, 0, self.width - 100)
            self.debugwin.bkgd(' ', curses.color_pair(3))
            self.last_ch = 0

    def input_stream(self):
        """Waiting an input and run a proper method according to type of input"""
        while True:
            self.display()

            ch = self.window.getch()

            if self.DEBUG:
                self.last_ch = ch

            if ch == curses.KEY_UP:
                self.scroll(self.UP)
            elif ch == curses.KEY_DOWN:
                self.scroll(self.DOWN)
            elif ch == curses.KEY_LEFT:
                self.paging(self.UP)
            elif ch == curses.KEY_RIGHT:
                self.paging(self.DOWN)
            elif ch == 0x1b:
                break
            elif ch == 0x09:
                continue

    def display(self):
        """Display the items on window"""
        self.window.erase()
        for idx, item in enumerate(self.items_list[self.top:self.top + self.max_lines]):
            # Highlight the current cursor line
            if idx == self.current:
                self.window.addstr(idx, 0, item.toString(), curses.color_pair(2))
            else:
                self.window.addstr(idx, 0, item.toString(), curses.color_pair(1))
        self.window.refresh()

        if self.DEBUG:
            self.debugwin.erase()
            self.debugwin.addstr(0, 2, "top: %-4d, current: %-4d, max_lines: %-4d, bottom: %-4d"
                    % (self.top, self.current, self.max_lines, self.bottom))
            self.debugwin.addstr(1, 2, self.items_list[self.current].toString())
            self.debugwin.addstr(0, 100 - 6, "0x%-4x" % (self.last_ch))
            self.debugwin.refresh()

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

    screen = SpecScreen(root)
    screen.run()

if __name__ == "__main__":
    main()
