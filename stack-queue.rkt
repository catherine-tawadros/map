#lang dssl2

# HW2: Stacks and Queues

let eight_principles = ["Know your rights.",
    "Acknowledge your sources.",
    "Protect your work.",
    "Avoid suspicion.",
    "Do your own work.",
    "Never falsify a record or permit another person to do so.",
    "Never fabricate data, citations, or experimental results.",
    "Always tell the truth when discussing your work with your instructor."]
    
let eight_principles_version_2 = ["Know your rights.",
    "Acknowledge your sources.",
    "Protect your work.",
    "Avoid suspicion.",
    "Do your own work.",
    "Never falsify a record or permit another person to do so.",
    "Never fabricate data, citations, or experimental results.",
    "Always tell the truth when discussing your work with your instructor."]
    
test "principles":
    for i in range(7):
        assert eight_principles[i] == eight_principles_version_2[i]

import ring_buffer

interface STACK[T]:
    def push(self, element: T) -> NoneC
    def pop(self) -> T
    def empty?(self) -> bool?

# Defined in the `ring_buffer` library; copied here for reference:
# interface QUEUE[T]:
#     def enqueue(self, element: T) -> NoneC
#     def dequeue(self) -> T
#     def empty?(self) -> bool?

# Linked-list node struct (implementation detail):
struct _cons:
    let data
    let next: OrC(_cons?, NoneC)

###
### ListStack
###

class ListStack (STACK):
    let head
    let length

    # Any fields you may need can go here.

    # Constructs an empty ListStack.
    def __init__ (self):
        self.head = None
        self.length = 0
    #   ^ YOUR DEFINITION HERE

    # Other methods you may need can go here.
        
    def push(self, data):
        if (self.empty?()):
            self.head = _cons(data, None)
        else:
            self.head = _cons(data, self.head)
        self.length = self.length + 1
        
    def pop(self):
        if (self.empty?()):
            error("this stack is empty")
        let old_head = self.head
        self.head = self.head.next
        self.length = self.length - 1
        return old_head.data
        
    def empty?(self):
        return (self.length == 0)

test "woefully insufficient":
    let s = ListStack()
    s.push(2)
    assert s.pop() == 2

test "stack tests":
    let s = ListStack()
    assert s.empty?()
    assert_error(s.pop())
    s.push(1)
    assert not s.empty?()
    assert s.pop() == 1
    assert_error(s.pop())
    assert s.empty?()
    s.push(1)
    s.push(2)
    s.push(3)
    s.push(4)
    s.push(5)
    assert not s.empty?()
    assert s.pop() == 5
    assert s.pop() == 4
    assert s.pop() == 3
    assert s.pop() == 2
    assert s.pop() == 1
    assert_error(s.pop())
    assert s.empty?()

###
### ListQueue
###

class ListQueue (QUEUE):
    let head
    let length
    let tail

    # Any fields you may need can go here.

    # Constructs an empty ListQueue.
    def __init__ (self):
        self.head = None
        self.tail = None
        self.length = 0
    #   ^ YOUR DEFINITION HERE

    # Other methods you may need can go here.
        
    def enqueue(self, data):
        if (self.empty?()):
            self.head = _cons(data, None)
            self.tail = self.head
        else:
            let old_tail = self.tail
            old_tail.next = _cons(data, None)
            self.tail = old_tail.next
        self.length = self.length + 1
        
    def dequeue(self):
        if (self.empty?()):
            error("this queue is empty")
        let old_head_data = self.head.data
        if (self.length == 1):
            self.head = None
            self.tail = None
        else:
            self.head = self.head.next
        self.length = self.length - 1
        return old_head_data
        
    def empty?(self):
        return (self.length == 0)

test "woefully insufficient, part 2":
    let q = ListQueue()
    q.enqueue(2)
    assert q.dequeue() == 2
    
test "queue tests":
    let q = ListQueue()
    assert q.empty?()
    assert_error(q.dequeue())
    q.enqueue(1)
    assert not q.empty?()
    assert q.dequeue() == 1
    assert_error(q.dequeue())
    assert q.empty?()
    q.enqueue(1)
    q.enqueue(2)
    q.enqueue(3)
    q.enqueue(4)
    q.enqueue(5)
    assert not q.empty?()
    assert q.dequeue() == 1
    assert q.dequeue() == 2
    assert q.dequeue() == 3
    assert q.dequeue() == 4
    assert q.dequeue() == 5
    assert_error(q.dequeue())
    assert q.empty?()

###
### Playlists
###

struct song:
    let title: str?
    let artist: str?
    let album: str?

# Enqueue five songs of your choice to the given queue, then return the first
# song that should play.
def fill_playlist (q: QUEUE!):
    q.enqueue(song("40 Days", "Slowdive", "Souvlaki"))
    q.enqueue(song("Ici Paris", "Noir Désir", "Tostaky"))
    q.enqueue(song("Resurrection", "Moist", "Creature"))
    q.enqueue(song("The Raveonettes", "You Hit Me (I’m Down)", "Observator"))
    q.enqueue(song("Captain Beefheart and His Magic Band", "The Blimp", "Trout Mask Replica"))
    return q.dequeue()
#   ^ YOUR DEFINITION HERE

test "ListQueue playlist":
    let q = ListQueue()
    let result = fill_playlist(q)
    assert result.title == "40 Days"
    assert result.artist == "Slowdive"
    assert result.album == "Souvlaki"

# To construct a RingBuffer: RingBuffer(capacity)
test "RingBuffer playlist":
    let q = RingBuffer(5)
    let result = fill_playlist(q)
    assert result.title == "40 Days"
    assert result.artist == "Slowdive"
    assert result.album == "Souvlaki"
