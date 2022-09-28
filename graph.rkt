#lang dssl2

# HW4: Graph

let eight_principles = ["Know your rights.",
    "Acknowledge your sources.",
    "Protect your work.",
    "Avoid suspicion.",
    "Do your own work.",
    "Never falsify a record or permit another person to do so.",
    "Never fabricate data, citations, or experimental results.",
    "Always tell the truth when discussing your work with your instructor."]

import cons
import 'hw4-lib/dictionaries.rkt'


###
### REPRESENTATION
###

# A Vertex is a natural number.
let Vertex? = nat?

# A VertexList is either
#  - None, or
#  - cons(v, vs), where v is a Vertex and vs is a VertexList
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a real number. (It’s a number, but it’s neither infinite
# nor not-a-number.)
let Weight? = AndC(num?, NotC(OrC(inf, -inf, nan)))

# An OptWeight is either
# - a Weight, or
# - None
let OptWeight? = OrC(Weight?, NoneC)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is either
#  - None, or
#  - cons(w, ws), where w is a WEdge and ws is a WEdgeList
let WEdgeList? = Cons.ListC[WEdge?]

# A weighted, undirected graph ADT.
interface WU_GRAPH:

    # Returns the number of vertices in the graph. (The vertices
    # are numbered 0, 1, ..., k - 1.)
    def len(self) -> nat?

    # Sets the weight of the edge between u and v to be w. Passing a
    # real number for w updates or adds the edge to have that weight,
    # whereas providing providing None for w removes the edge if
    # present. (In other words, this operation is idempotent.)
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC

    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?

    # Gets a list of all vertices adjacent to v. (The order of the
    # list is unspecified.)
    def get_adjacent(self, v: Vertex?) -> VertexList?

    # Gets a list of all edges in the graph, in an unspecified order.
    # This list only includes one direction for each edge. For
    # example, if there is an edge of weight 10 between vertices
    # 1 and 3, then exactly one of WEdge(1, 3, 10) or WEdge(3, 1, 10)
    # will be in the result list, but not both.
    def get_all_edges(self) -> WEdgeList?

class WuGraph (WU_GRAPH):
    let vertices
    let matrix
### ^ YOUR FIELDS HERE

    def __init__(self, size: nat?):
        self.vertices = None
        for i in range(size-1, -1, -1):
            self.vertices = cons(i, self.vertices)
        self.matrix = [None; size]
        for i in range(size):
            self.matrix[i] = [None; size]
### ^ YOUR CODE HERE

# Other methods you may need can go here.
            
    def len(self):
        return self.matrix.len()
        
    def set_edge(self, u : Vertex?, v : Vertex?, w : OptWeight?):
        self.matrix[u][v] = w
        self.matrix[v][u] = w
      
    def get_edge(self, u : Vertex?, v : Vertex?):
        return self.matrix[u][v]
        
    def get_adjacent(self, v : Vertex?):
        let ver = None
        for i in range(self.len()-1, -1, -1):
            if self.matrix[v][i] is not None:
                ver = cons(i, ver)
        return ver
        
    def get_all_edges(self):
        let edges = None
        for r in range(self.len()):
            #only scan the upper triangle of the matrix
            for c in range(r, self.len()):
                if self.matrix[r][c] is not None:
                    edges = cons(WEdge(r, c, self.matrix[r][c]), edges)
        return edges

###
### List helpers
###

# For testing functions that return lists, we provide a function for
# constructing a list from a vector, and functions for sorting (since
# the orders of returned lists are not determined).

# list : VecOf[X] -> ListOf[X]
# Makes a linked list from a vector.
def list(v: vec?) -> Cons.list?:
    return Cons.from_vec(v)

# sort_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def sort_vertices(lst: Cons.list?) -> Cons.list?:
    def vertex_lt?(u, v): return u < v
    return Cons.sort[Vertex?](vertex_lt?, lst)

# sort_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically
# ASSUMPTION: There's no need to compare weights because
# the same edge can’t appear with different weights.
def sort_edges(lst: Cons.list?) -> Cons.list?:
    def edge_lt?(e1, e2):
        return e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    return Cons.sort[WEdge?](edge_lt?, lst)

###
### BUILDING GRAPHS
###

def example_graph() -> WuGraph?:
    let result = WuGraph(6) # 6-vertex graph from the assignment
    result.set_edge(0, 1, 12)
    result.set_edge(1, 2, 31)
    result.set_edge(1, 3, 56)
    result.set_edge(2, 4, -2)
    result.set_edge(3, 5, 1)
    result.set_edge(2, 5, 7)
    result.set_edge(3, 4, 9)
    return result
### ^ YOUR CODE HERE

struct CityMap:
    let graph
    let city_name_to_node_id
    let node_id_to_city_name

def my_neck_of_the_woods():
    let cities_to_nodes = AssociationList()
    let nodes_to_cities = AssociationList()
    let cities = ["Commack", "Dix Hills", "Brentwood", \
    "Northport", "Smithtown"]
    for i in range(5):
        cities_to_nodes.put(cities[i], i)
        nodes_to_cities.put(i, cities[i])
    let graph = WuGraph(5)
    for i in range(1, 5):
        graph.set_edge(0, i, i)
    let map = CityMap(graph, cities_to_nodes, nodes_to_cities)
    return map
    ### ^ YOUR CODE HERE
    
def tree_graph():
    let tree = WuGraph(7)
    tree.set_edge(0, 1, 1)
    tree.set_edge(1, 2, 1)
    tree.set_edge(1, 3, 1)
    tree.set_edge(0, 4, 1)
    tree.set_edge(4, 5, 1)
    tree.set_edge(4, 6, 1)
    return tree

###
### DFS
###

# dfs : WU_GRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `f`
# to each vertex once as it is discovered by the search.
def dfs(graph: WU_GRAPH!, start: Vertex?, f: FunC[Vertex?, AnyC]) -> NoneC:
    if graph.len() == 0:
        return
    def helper(start_):
        if not visited[start_]:
            f(start_)
            visited[start_] = True
            let current = graph.get_adjacent(start_)
            while current is not None:
                if not visited[current.data]:
                    helper(current.data)
                current = current.next
    let visited = [False; graph.len()]
    helper(start)
### ^ YOUR CODE HERE

# dfs_to_list : WU_GRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
#
# This function uses your `dfs` function to build a list in the
# order of the search. It will pass the test below if your dfs visits
# each reachable vertex once, regardless of the order in which it calls
# `f` on them. However, you should test it more thoroughly than that
# to make sure it is calling `f` (and thus exploring the graph) in
# a correct order.
def dfs_to_list(graph: WU_GRAPH!, start: Vertex?) -> VertexList?:
    let builder = Cons.Builder()
    dfs(graph, start, builder.snoc)
    return builder.take()

###
### TESTING
###

## You should test your code thoroughly. Here is one test to get you started:

test 'dfs_to_list(example_graph())':
    assert sort_vertices(dfs_to_list(example_graph(), 0)) \
        == list([0, 1, 2, 3, 4, 5])
        
test 'dfs tests':
    # example graph searches in the correct order
    assert dfs_to_list(example_graph(), 0)\
        == list([0, 1, 2, 4, 3, 5])
    assert dfs_to_list(example_graph(), 1) == list([1, 0, 2, 4, 3, 5])
    # dfs works for my map thing
    assert dfs_to_list(my_neck_of_the_woods().graph, 0).data == 0
    assert sort_vertices(dfs_to_list(my_neck_of_the_woods().graph, 0)) \
        == list([0, 1, 2, 3, 4])
    # dfs works as expected for a tree structured graph
    assert dfs_to_list(tree_graph(), 0) == list([0,1,2,3,4,5,6])
    # dfs on a single node
    let single_node = WuGraph(1)
    assert dfs_to_list(single_node, 0) == list([0])
    assert_error dfs_to_list(single_node, 1)
    
test 'basic functional tests':
    # get adjacent works
    let current = example_graph().get_adjacent(0)
    assert current.data == 1
    assert current.next == None
    current = example_graph().get_all_edges()
    # length works
    let len = 0
    while current is not None:
        len = len + 1
        current = current.next
    assert len == 7

test 'empty list tests':
    # dfs 
    let none = WuGraph(0)
    assert dfs_to_list(none, 0) == list([])
    # graph methods
    assert none.len() == 0
    assert none.get_all_edges() == None
    assert_error(none.set_edge(1, 2))
    assert_error(none.get_edge(1, 2))
    assert none.get_adjacent(0) == None
    
test 'one element graph':
    # dfs 
    let one = WuGraph(1)
    one.set_edge(0, 0, 1)
    assert dfs_to_list(one, 0) == list([0])
    # graph methods
    assert one.len() == 1
    assert one.get_all_edges().data is not None
    assert one.get_all_edges().next is None
    assert one.get_edge(0, 0) == 1
    assert one.get_adjacent(0).data == 0
    assert one.get_adjacent(0).next is None