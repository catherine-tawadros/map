#lang dssl2

# HW3: Dictionaries


let eight_principles = ["Know your rights.",
    "Acknowledge your sources.",
    "Protect your work.",
    "Avoid suspicion.",
    "Do your own work.",
    "Never falsify a record or permit another person to do so.",
    "Never fabricate data, citations, or experimental results.",
    "Always tell the truth when discussing your work with your instructor."]


import sbox_hash


struct node:
    let key
    let value
    let next
    

# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following method allows dictionaries to be printed
    def __print__(self, print)


class AssociationList[K, V] (DICT):

    let _head
    let _len

    def __init__(self):
        self._head = None
        self._len = 0
    
    def len(self):
        return self._len
        
    def mem?(self, key : K):
        let current = self._head
        while current != None:
            if current.key == key:
                return True
            current = current.next
        return False
        
    def get(self, key : K):
        let current = self._head
        while current != None:
            if current.key == key:
                return current.value
            current = current.next
        error("key is not present")
        
    def put(self, key : K, value : V):
        let current = self._head
        while current != None:
            if current.key == key:
                current.value = value
                return
            current = current.next
        self._head = node(key, value, self._head)
        self._len = self._len + 1
        
    def del(self, key : K):
        let current = self._head
        if current == None: return
        if current.key == key:
            self._head = self._head.next
            self._len = self._len - 1
            return
        while current.next != None:
            if current.next.key == key:
                current.next = current.next.next
                self._len = self._len - 1
                return
            current = current.next
        
    # See above.
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)

    # Other methods you may need can go here.


test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert not a.mem?('hello')
    a.put('hello', 5)
    assert a.len() == 1
    assert a.mem?('hello')
    assert a.get('hello') == 5
    
test 'i hAvE MorE tEsTs':
    let a = AssociationList()
    # a is empty
    assert a.len() == 0
    assert not a.mem?('anything')
    assert_error a.get('anything')
    # add an element to a
    a.put('a', 1)
    assert a.len() == 1
    assert a.mem?('a')
    assert a.get('a') == 1
    #delete an element from a
    a.del('a')
    assert a.len() == 0
    assert not a.mem?('a')
    assert_error a.get('a')
    
    #longer lists
    a.put('a', 0)
    a.put('b', 1)
    a.put('c', 2)
    a.put('d', 3)
    a.put('e', 4)
    
    let letters = ['a','b','c','d','e']
    let numbers = [0,1,2,3,4]
    for i in numbers:
        assert a.len() == 5
        assert a.mem?(letters[i])
        assert a.get(letters[i]) == i
        a.del(letters[i])
        assert not a.mem?(letters[i])
        assert_error a.get(letters[i])
        assert a.len() == 4
        a.put(letters[i], i)
        
    #modify value
    a.put('c', 72)
    assert a.mem?('c')
    assert a.get('c') == 72
    assert a.len() == 5
    
    let o = AssociationList()
    o.put(5, 'five')
    o.del(6)
    assert o.len() == 1


class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data
    let _total_len

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        self._size = nbuckets
        self._data = [None; self._size]
        self._total_len = 0

    def len(self):
        return self._total_len
        
    def mem?(self, key : K):
        let bucket = self._hash(key) % self._size
        let current = self._data[bucket]
        while current != None:
            if current.key == key:
                return True
            current = current.next
        return False
        
    def get(self, key : K):
        let bucket = self._hash(key) % self._size
        let current = self._data[bucket]
        while current != None:
            if current.key == key:
                return current.value
            current = current.next
        error("this value is not in the dictionary")
        
    def put(self, key : K, value : V):
        let bucket = self._hash(key) % self._size
        let current = self._data[bucket]
        while current != None:
            if current.key == key:
                current.value = value
                return
            current = current.next
        self._data[bucket] = node(key, value, self._data[bucket])
        self._total_len = self._total_len + 1
        
    def del(self, key : K):
        let bucket = self._hash(key) % self._size
        let current = self._data[bucket]
        if current == None: return
        if current.key == key:
            self._data[bucket] = current.next
            self._total_len = self._total_len - 1
            return
        while current.next != None:
            if current.next.key == key:
                current.next = current.next.next
                self._total_len = self._total_len - 1
                return
            current = current.next
        
    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)


# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')
    assert h.get('hello') == 5
    
test 'more tests':
    let a = HashTable(10, first_char_hasher)
    # a is empty
    assert a.len() == 0
    assert not a.mem?('anything')
    assert_error a.get('anything')
    # add an element to a
    a.put('a', 1)
    assert a.len() == 1
    assert a.mem?('a')
    assert a.get('a') == 1
    #delete an element from a
    a.del('a')
    assert a.len() == 0
    assert not a.mem?('a')
    assert_error a.get('a')
    
    #longer lists
    a.put('a', 0)
    a.put('b', 1)
    a.put('c', 2)
    a.put('d', 3)
    a.put('e', 4)
    
    let letters = ['a','b','c','d','e']
    let numbers = [0,1,2,3,4]
    for i in numbers:
        assert a.len() == 5
        assert a.mem?(letters[i])
        assert a.get(letters[i]) == i
        a.del(letters[i])
        assert not a.mem?(letters[i])
        assert_error a.get(letters[i])
        assert a.len() == 4
        a.put(letters[i], i)
        
    #modify value
    a.put('c', 72)
    assert a.mem?('c')
    assert a.get('c') == 72
    assert a.len() == 5
    
    #COLLISION
    a.put("aa", 11)
    a.put("aaa", 111)
    a.put("aaaa", 1111)
    assert a.len() == 8
    assert a.mem?("aa")
    assert a.get("aa") == 11
    a.del("aaa")
    assert not a.mem?("aaa")
    assert_error a.get("aaa")
    assert a.len() == 7
    a.del("aa")
    assert not a.mem?("aa")
    assert_error a.get("aa")
    assert a.len() == 6
    assert a.get("aaaa") == 1111
    a.del("a")
    assert_error a.get("a")
    assert a.len() == 5
    assert not a.mem?("a")
    assert a.get("aaaa") == 1111
    assert a.mem?("aaaa")
    
    let o = HashTable(5, make_sbox_hash())
    o.put(5, 'five')
    o.del(6)
    assert o.len() == 1

struct dish:
    let name
    let type
    
def compose_menu(d: DICT!) -> DICT?:
    d.put("stevie", dish("masala dosa", "indian"))
    d.put("branden", dish("apple pie", "american"))
    d.put("carole", dish("spaghetti", "italian"))
    d.put("sara", dish("channa masala", "indian"))
    d.put("iliana", dish("pupusas", "salvadoran"))
    return d

test "AssociationList menu":
    let menu = AssociationList()
    menu = compose_menu(menu)
    assert menu.get("branden").name == "apple pie"

test "HashTable menu":
    let menu = HashTable(10, make_sbox_hash())
    menu = compose_menu(menu)
    assert menu.get("branden").name == "apple pie"
