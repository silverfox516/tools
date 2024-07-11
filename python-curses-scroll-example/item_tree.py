#!/usr/bin/python3

import curses
import tui
import uuid

class Item():
    TYPE = 1
    DEPTH = 0

    def __init__(self, item, parent, tag="0"):
        self.expanded = True
        self.uuid = uuid.uuid4()
        self.item = None
        self.sub_items = []
        self.parent = parent
        self.groups = []
        self.enums = []
        self.tag = tag
        self.parse(item)

    def addSubItem(self, item):
        self.sub_items.append(item)

    def getUUID(self):
        return self.uuid

    def expand(self, value):
        self.expanded = value

    def expandOfUUID(self, value, uuid):
        if self.uuid == uuid:
            self.expand(value)
        elif self.isExpanded():
            for i in self.sub_items:
                i.expandOfUUID(value, uuid)

    def isExpanded(self):
        return self.expanded

    def toList(self, l):
        l.append(self)
        if self.isExpanded():
            for i in self.sub_items:
                l = i.toList(l)
        return l

    def itemString(self):
        return '%s' % (self.item)

    def toString(self):
        return '%10s: %s%s %s' % (self.tag, '    ' * self.DEPTH, self.itemString(), '' if len(self.sub_items) == 0 else '<' if self.isExpanded() else '>')

    def parse(self, item):
        self.item = item

    def getRoot(self):
        if self.parent is None:
            return self
        else:
            return self.parent.getRoot()

class ItemScreen(tui.Screen):
    DEBUG = False

    def __init__(self, items):
        self.root_item = items
        self.items_list = []
        self.items_list = self.root_item.toList(self.items_list)
        super().__init__(self.items_list)

    def init_curses(self):
        super().init_curses()
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)
        curses.init_pair(3, curses.COLOR_CYAN, curses.COLOR_BLACK)
        curses.init_pair(4, curses.COLOR_MAGENTA, curses.COLOR_BLACK)
        curses.init_pair(5, curses.COLOR_WHITE, curses.COLOR_BLACK)
        curses.init_pair(6, curses.COLOR_WHITE, curses.COLOR_BLACK)
        curses.init_pair(1 + 7, curses.COLOR_BLACK, curses.COLOR_GREEN)
        curses.init_pair(2 + 7, curses.COLOR_BLACK, curses.COLOR_YELLOW)
        curses.init_pair(3 + 7, curses.COLOR_BLACK, curses.COLOR_CYAN)
        curses.init_pair(4 + 7, curses.COLOR_BLACK, curses.COLOR_MAGENTA)
        curses.init_pair(5 + 7, curses.COLOR_BLACK, curses.COLOR_WHITE)
        curses.init_pair(6 + 7, curses.COLOR_BLACK, curses.COLOR_WHITE)

        if self.DEBUG:
            self.debugwin = curses.newwin(10, 100, 0, self.width - 100)
            self.debugwin.bkgd(' ', curses.color_pair(13))
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
                i = self.items_list[self.top + self.current]
                if isinstance(i, Item):
                    self.root_item.expandOfUUID(False if i.isExpanded() else True, i.getUUID())

    def display(self):
        """Display the items on window"""

        self.items_list = []
        self.items_list = self.root_item.toList(self.items_list)
        self.bottom = len(self.items_list)
        self.page = self.bottom // self.max_lines

        self.window.erase()
        for idx, item in enumerate(self.items_list[self.top:self.top + self.max_lines]):
            # Highlight the current cursor line
            if idx == self.current:
                self.window.addstr(idx, 0, item.toString(), curses.color_pair(item.TYPE + 7))
            else:
                self.window.addstr(idx, 0, item.toString(), curses.color_pair(item.TYPE))
        self.window.refresh()

        if self.DEBUG:
            self.debugwin.erase()
            self.debugwin.addstr(0, 2, "top: %-4d, current: %-4d, max_lines: %-4d, bottom: %-4d"
                    % (self.top, self.current, self.max_lines, self.bottom))
            self.debugwin.addstr(1, 2, self.items_list[self.top + self.current].toString())
            self.debugwin.addstr(0, 100 - 6, "0x%-4x" % (self.last_ch))
            self.debugwin.addstr(2, 2, "groups: %d, enums: %d" % (len(self.root_item.getRoot().groups), len(self.root_item.getRoot().enums)))
            self.debugwin.refresh()

def main():
    root = Item("Root", None)
    root.expand(True)
    for i in range(0, 10):
        item = Item("%d" % i, root)
        item.DEPTH = 1
        for j in range(11, 16):
            jtem = Item("%d:%d" % (i, j), item)
            jtem.DEPTH = 2
            for k in range(17, 21):
                ktem = Item("%d:%d:%d" % (i, j, k), jtem)
                ktem.DEPTH = 3
                jtem.addSubItem(ktem)
            item.addSubItem(jtem)
        root.addSubItem(item)

    screen = ItemScreen(root)
    screen.run()

if __name__ == "__main__":
    main()
